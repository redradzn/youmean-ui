import 'package:flutter/material.dart';
import '../models/stored_request.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../main.dart';

class MindSelfiesPage extends StatefulWidget {
  const MindSelfiesPage({super.key});

  @override
  State<MindSelfiesPage> createState() => _MindSelfiesPageState();
}

class _MindSelfiesPageState extends State<MindSelfiesPage> {
  List<StoredRequest> _readyRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadyResults();
  }

  Future<void> _loadReadyResults() async {
    setState(() => _isLoading = true);

    final allRequests = await StorageService.getAllRequests();
    final ready = allRequests.where((r) => r.isReady).toList();

    if (mounted) {
      setState(() {
        _readyRequests = ready;
        _isLoading = false;
      });
    }
  }

  Future<void> _viewResult(StoredRequest request) async {
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
          ).then((_) => _loadReadyResults());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading result: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getBeliefSystemLabel(String birthDate) {
    // Try to infer from stored requests or use a placeholder
    return "Science"; // Default
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.bug_report, color: const Color(0xFF008080), size: 24),
            const SizedBox(width: 8),
            const Text('Mind Selfies'),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _readyRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bug_report,
                        size: 80,
                        color: const Color(0xFF008080).withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Mind Selfies Ready',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Submit a request and wait for results',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReadyResults,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _readyRequests.length,
                    itemBuilder: (context, index) {
                      return _buildResultCard(_readyRequests[index], isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildResultCard(StoredRequest request, bool isDark) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: InkWell(
        onTap: () => _viewResult(request),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF008080), Color(0xFF20B2AA)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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
                        Text(
                          'Ready',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Birth Data Section
              _buildInfoSection(
                icon: Icons.cake,
                title: 'Birth Data',
                items: [
                  _buildInfoRow('Date', request.birthDate, isDark),
                  if (request.birthTime != null)
                    _buildInfoRow('Time', request.birthTime!, isDark),
                  _buildInfoRow('Location', request.birthPlace, isDark),
                ],
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewResult(request),
                  icon: const Icon(Icons.visibility, size: 20),
                  label: const Text(
                    'View Mind Selfie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008080),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> items,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF008080)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
