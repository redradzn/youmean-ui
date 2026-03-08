import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/stored_request.dart';
import '../screens/requests_control_center.dart';

class ScarabBadge extends StatefulWidget {
  const ScarabBadge({super.key});

  @override
  State<ScarabBadge> createState() => _ScarabBadgeState();
}

class _ScarabBadgeState extends State<ScarabBadge>
    with TickerProviderStateMixin {
  int _notificationCount = 0;
  Timer? _refreshTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Setup notification pulse animation
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

    // Always-on breathing animation
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );

    _breatheController.repeat(reverse: true);

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
    _breatheController.dispose();
    super.dispose();
  }

  void _onTap() async {
    // Navigate to Scarab Control Center (tabs: Mind Selfies + Request History)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestsControlCenter(),
      ),
    );

    // Refresh count after returning
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _breatheAnimation]),
          builder: (context, child) {
            final double scale;
            if (_notificationCount > 0) {
              scale = _pulseAnimation.value;
            } else if (_isHovered) {
              scale = 1.05;
            } else {
              scale = _breatheAnimation.value;
            }

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
                  boxShadow: [
                    BoxShadow(
                      color: _notificationCount > 0
                          ? const Color(0xFF008080).withOpacity(0.5)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: _notificationCount > 0 ? 20 : 10,
                      spreadRadius: _notificationCount > 0 ? 2 : 1,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Custom Scarab icon
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'ardet_assets/mind_ball.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // iOS-style notification badge - positioned at TOP RIGHT to avoid edge clipping
                    if (_notificationCount > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red[600],
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
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
    );
  }
}
