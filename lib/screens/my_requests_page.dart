import 'package:flutter/material.dart';
import '../models/stored_request.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../main.dart'; // For ResultsPage

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<StoredRequest> _requests = [];
  bool _isLoading = true;
  Set<String> _checkingIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final requests = await StorageService.getAllRequests();
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkRequest(StoredRequest request) async {
    setState(() => _checkingIds.add(request.requestId));

    try {
      final result = await ApiService.pollResults(request.requestId);

      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        // Update status to ready
        await StorageService.updateRequestStatus(
          request.requestId,
          RequestStatus.ready,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Results ready for "${request.label}"!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _loadRequests();
      } else if (result != null && result['status'] == 'failed') {
        await StorageService.updateRequestStatus(
          request.requestId,
          RequestStatus.completed,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request failed: ${result['error'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }

        await _loadRequests();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Still processing...'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingIds.remove(request.requestId));
      }
    }
  }

  Future<void> _checkAll() async {
    final pendingRequests = _requests.where((r) => r.isPending).toList();

    if (pendingRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending requests to check')),
      );
      return;
    }

    for (final request in pendingRequests) {
      await _checkRequest(request);
    }
  }

  Future<void> _viewResults(StoredRequest request) async {
    try {
      final result = await ApiService.pollResults(request.requestId);

      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        final calcResult = CalculationResult.fromJson(result['result']);

        // Mark as viewed
        await StorageService.markAsViewed(request.requestId);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                result: calcResult,
                requestId: request.requestId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _renameRequest(StoredRequest request) async {
    final controller = TextEditingController(text: request.label);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Request'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'e.g., Mom, John, Me',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != request.label) {
      await StorageService.updateRequestLabel(request.requestId, result);
      await _loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Label updated')),
        );
      }
    }
  }

  Future<void> _deleteRequest(StoredRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Delete "${request.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteRequest(request.requestId);
      await _loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted')),
        );
      }
    }
  }

  Widget _buildStatusChip(RequestStatus status, bool hasNotification) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case RequestStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        label = 'Pending';
        break;
      case RequestStatus.ready:
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Ready';
        break;
      case RequestStatus.completed:
        icon = Icons.done;
        color = const Color(0xFF008080);
        label = 'Viewed';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(StoredRequest request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecking = _checkingIds.contains(request.requestId);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: request.isReady ? () => _viewResults(request) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Label + Status
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(request.status, request.hasNotification),
                ],
              ),
              const SizedBox(height: 12),

              // Details
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    request.birthDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  if (request.birthTime != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.access_time,
                        size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      request.birthTime!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.birthPlace,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  if (request.isPending)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isChecking ? null : () => _checkRequest(request),
                        icon: isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh, size: 18),
                        label: Text(isChecking ? 'Checking...' : 'Check Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (request.isReady)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewResults(request),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Results'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (request.isCompleted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewResults(request),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _renameRequest(request),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Rename',
                  ),
                  IconButton(
                    onPressed: () => _deleteRequest(request),
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Requests'),
        actions: [
          if (_requests.any((r) => r.isPending))
            TextButton.icon(
              onPressed: _checkAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Check All'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No requests yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit a request from the home page',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_requests[index]);
                    },
                  ),
                ),
    );
  }
}
