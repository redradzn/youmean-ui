import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/stored_request.dart';
import '../screens/my_requests_page.dart';

class ScarabBadge extends StatefulWidget {
  const ScarabBadge({super.key});

  @override
  State<ScarabBadge> createState() => _ScarabBadgeState();
}

class _ScarabBadgeState extends State<ScarabBadge>
    with SingleTickerProviderStateMixin {
  int _notificationCount = 0;
  Timer? _refreshTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Load initial count
    _loadCount();

    // Refresh count every 10 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadCount(),
    );
  }

  void _loadCount() async {
    // First, check backend for any pending requests that might be ready
    await _checkPendingRequests();

    // Then get the notification count from localStorage
    final count = await StorageService.getNotificationCount();
    if (mounted) {
      setState(() {
        _notificationCount = count;
      });

      // Start/stop pulse animation based on count
      if (count > 0 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (count == 0 && _pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  Future<void> _checkPendingRequests() async {
    try {
      // Get all pending requests from localStorage
      final pendingRequests = await StorageService.getPendingRequests();

      // Poll backend for each pending request
      for (final request in pendingRequests) {
        final result = await ApiService.pollResults(request.requestId);

        if (result != null && result['status'] == 'completed' && result['result'] != null) {
          // Update localStorage status to "ready" with notification
          await StorageService.updateRequestStatus(
            request.requestId,
            RequestStatus.ready,
          );
        } else if (result != null && result['status'] == 'failed') {
          // Mark as completed even if failed
          await StorageService.updateRequestStatus(
            request.requestId,
            RequestStatus.completed,
          );
        }
      }
    } catch (e) {
      // Silently fail - don't disrupt the UI
      print('Error checking pending requests: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() async {
    // Navigate to My Requests page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRequestsPage(),
      ),
    );

    // Refresh count after returning from My Requests page
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = _notificationCount > 0
                  ? _pulseAnimation.value
                  : (_isHovered ? 1.05 : 1.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _notificationCount > 0
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF008080), // Teal
                              Color(0xFFFFD700), // Gold
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _notificationCount == 0
                        ? const Color(0xFF008080) // Teal
                        : null,
                    boxShadow: _notificationCount > 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF008080).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Stack(
                    children: [
                      // Scarab icon
                      Center(
                        child: Icon(
                          Icons.bug_report,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      // Notification count badge
                      if (_notificationCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[700],
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            child: Center(
                              child: Text(
                                '$_notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
