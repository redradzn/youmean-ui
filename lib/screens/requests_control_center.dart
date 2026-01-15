import 'package:flutter/material.dart';
import '../models/stored_request.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../main.dart';

class RequestsControlCenter extends StatefulWidget {
  const RequestsControlCenter({super.key});

  @override
  State<RequestsControlCenter> createState() => _RequestsControlCenterState();
}

class _RequestsControlCenterState extends State<RequestsControlCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StoredRequest> _readyRequests = [];
  List<StoredRequest> _allRequests = [];
  bool _isLoading = true;
  Set<String> _checkingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final allRequests = await StorageService.getAllRequests();
    final ready = allRequests.where((r) => r.isReady).toList();

    if (mounted) {
      setState(() {
        _readyRequests = ready;
        _allRequests = allRequests;
        _isLoading = false;
      });
    }
  }

  Future<void> _viewResult(StoredRequest request) async {
    try {
      final result = await ApiService.pollResults(request.requestId);

      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        final calcResult = CalculationResult.fromJson(result['result']);
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
          ).then((_) => _loadRequests());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading result: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _checkRequest(StoredRequest request) async {
    setState(() => _checkingIds.add(request.requestId));

    try {
      final result = await ApiService.pollResults(request.requestId);

      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        await StorageService.updateRequestStatus(request.requestId, RequestStatus.ready);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Results ready for "${request.label}"!'), backgroundColor: Colors.green),
          );
        }
        await _loadRequests();
      } else if (result != null && result['status'] == 'failed') {
        await StorageService.updateRequestStatus(request.requestId, RequestStatus.completed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request failed: ${result['error'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
          );
        }
        await _loadRequests();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Still processing...')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingIds.remove(request.requestId));
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
          decoration: const InputDecoration(labelText: 'Label', hintText: 'e.g., Mom, John, Me'),
          maxLength: 30,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != request.label) {
      await StorageService.updateRequestLabel(request.requestId, result);
      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Label updated')));
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'ardet_assets/mind_ball.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Mind Selfies'),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF008080),
          labelColor: const Color(0xFF008080),
          unselectedLabelColor: isDark ? const Color(0xFFC9A961) : const Color(0xFF705C45),
          tabs: const [
            Tab(icon: Icon(Icons.stars), text: 'Mind Selfies'),
            Tab(icon: Icon(Icons.history), text: 'Request History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMindSelfiesTab(isDark),
                _buildRequestHistoryTab(isDark),
              ],
            ),
    );
  }

  Widget _buildMindSelfiesTab(bool isDark) {
    if (_readyRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 80, color: const Color(0xFF008080).withOpacity(0.3)),
            const SizedBox(height: 24),
            Text('No Mind Selfies Ready', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 12),
            Text('Submit a request and wait for results', style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black54)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _readyRequests.length,
        itemBuilder: (context, index) => _buildMindSelfieCard(_readyRequests[index], isDark),
      ),
    );
  }

  Widget _buildRequestHistoryTab(bool isDark) {
    if (_allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No requests yet', style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allRequests.length,
        itemBuilder: (context, index) => _buildHistoryCard(_allRequests[index], isDark),
      ),
    );
  }

  Widget _buildMindSelfieCard(StoredRequest request, bool isDark) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: InkWell(
        onTap: () => _viewResult(request),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF008080), Color(0xFF20B2AA)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(request.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text('Ready', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${request.birthDate} • ${request.birthPlace}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewResult(request),
                  icon: const Icon(Icons.visibility, size: 20),
                  label: const Text('View Mind Selfie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008080),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(StoredRequest request, bool isDark) {
    final isChecking = _checkingIds.contains(request.requestId);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(request.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                _buildStatusChip(request.status, isDark),
              ],
            ),
            const SizedBox(height: 8),
            Text('${request.birthDate} • ${request.birthPlace}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (request.isPending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isChecking ? null : () => _checkRequest(request),
                      icon: isChecking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh, size: 18),
                      label: Text(isChecking ? 'Checking...' : 'Check Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008080), foregroundColor: Colors.white),
                    ),
                  ),
                if (request.isReady || request.isCompleted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewResult(request),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(request.isReady ? 'View Results' : 'View Again'),
                      style: ElevatedButton.styleFrom(backgroundColor: request.isReady ? Colors.green : const Color(0xFF008080), foregroundColor: Colors.white),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _renameRequest(request), icon: const Icon(Icons.edit), tooltip: 'Rename'),
                IconButton(onPressed: () => _deleteRequest(request), icon: const Icon(Icons.delete), color: Colors.red, tooltip: 'Delete'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(RequestStatus status, bool isDark) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}
