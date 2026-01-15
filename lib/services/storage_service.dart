import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stored_request.dart';

class StorageService {
  static const String _storageKey = 'youmean_requests';
  static const int _maxRequests = 50;

  static SharedPreferences? _prefs;
  static List<StoredRequest>? _cachedRequests;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedRequests = null; // Clear cache on init
  }

  /// Load all requests from storage
  static Future<List<StoredRequest>> getAllRequests() async {
    if (_cachedRequests != null) {
      return List.from(_cachedRequests!);
    }

    if (_prefs == null) await init();

    try {
      final String? jsonString = _prefs!.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        _cachedRequests = [];
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final List<StoredRequest> requests = jsonList
          .map((json) => StoredRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedRequests = requests;
      return List.from(requests);
    } catch (e) {
      print('Error loading requests: $e');
      _cachedRequests = [];
      return [];
    }
  }

  /// Save all requests to storage
  static Future<bool> _saveAllRequests(List<StoredRequest> requests) async {
    try {
      if (_prefs == null) await init();

      final String jsonString = json.encode(
        requests.map((r) => r.toJson()).toList(),
      );

      final success = await _prefs!.setString(_storageKey, jsonString);
      if (success) {
        _cachedRequests = List.from(requests);
      }
      return success;
    } catch (e) {
      print('Error saving requests: $e');
      return false;
    }
  }

  /// Save a new request
  static Future<bool> saveRequest(StoredRequest request) async {
    final List<StoredRequest> requests = await getAllRequests();

    // Check if request already exists
    final existingIndex =
        requests.indexWhere((r) => r.requestId == request.requestId);
    if (existingIndex != -1) {
      // Update existing request
      requests[existingIndex] = request;
    } else {
      // Add new request
      requests.insert(0, request); // Add to beginning (most recent first)
    }

    // Auto-cleanup: Keep max 50 requests
    await _cleanupOldRequests(requests);

    return await _saveAllRequests(requests);
  }

  /// Update request status
  static Future<bool> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    final List<StoredRequest> requests = await getAllRequests();
    final index = requests.indexWhere((r) => r.requestId == requestId);

    if (index == -1) return false;

    final updatedRequest = requests[index].copyWith(
      status: status,
      lastCheckedAt: DateTime.now(),
      hasNotification: status == RequestStatus.ready,
    );

    requests[index] = updatedRequest;
    return await _saveAllRequests(requests);
  }

  /// Update request label
  static Future<bool> updateRequestLabel(
    String requestId,
    String newLabel,
  ) async {
    final List<StoredRequest> requests = await getAllRequests();
    final index = requests.indexWhere((r) => r.requestId == requestId);

    if (index == -1) return false;

    final updatedRequest = requests[index].copyWith(label: newLabel);
    requests[index] = updatedRequest;
    return await _saveAllRequests(requests);
  }

  /// Delete a request
  static Future<bool> deleteRequest(String requestId) async {
    final List<StoredRequest> requests = await getAllRequests();
    final initialLength = requests.length;

    requests.removeWhere((r) => r.requestId == requestId);

    if (requests.length == initialLength) return false; // Nothing deleted

    return await _saveAllRequests(requests);
  }

  /// Get recent requests (limited count)
  static Future<List<StoredRequest>> getRecentRequests(int count) async {
    final List<StoredRequest> requests = await getAllRequests();
    return requests.take(count).toList();
  }

  /// Get notification count (ready requests with hasNotification=true)
  static Future<int> getNotificationCount() async {
    final List<StoredRequest> requests = await getAllRequests();
    return requests.where((r) => r.hasNotification && r.isReady).length;
  }

  /// Get pending requests
  static Future<List<StoredRequest>> getPendingRequests() async {
    final List<StoredRequest> requests = await getAllRequests();
    return requests.where((r) => r.isPending).toList();
  }

  /// Mark a request as viewed (clear notification, set to completed)
  static Future<bool> markAsViewed(String requestId) async {
    final List<StoredRequest> requests = await getAllRequests();
    final index = requests.indexWhere((r) => r.requestId == requestId);

    if (index == -1) return false;

    final updatedRequest = requests[index].copyWith(
      status: RequestStatus.completed,
      hasNotification: false,
      lastCheckedAt: DateTime.now(),
    );

    requests[index] = updatedRequest;
    return await _saveAllRequests(requests);
  }

  /// Clean up old requests (keep max 50, remove oldest completed)
  static Future<void> _cleanupOldRequests(List<StoredRequest> requests) async {
    if (requests.length <= _maxRequests) return;

    // Sort by: pending first, then ready, then completed
    // Within each group, sort by submittedAt (newest first)
    requests.sort((a, b) {
      // Priority: pending > ready > completed
      final statusPriority = {
        RequestStatus.pending: 0,
        RequestStatus.ready: 1,
        RequestStatus.completed: 2,
      };

      final aPriority = statusPriority[a.status]!;
      final bPriority = statusPriority[b.status]!;

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // Same status, sort by date (newest first)
      return b.submittedAt.compareTo(a.submittedAt);
    });

    // Keep only the first _maxRequests items
    if (requests.length > _maxRequests) {
      requests.removeRange(_maxRequests, requests.length);
    }
  }

  /// Clear all requests (for debugging)
  static Future<bool> clearAll() async {
    if (_prefs == null) await init();
    _cachedRequests = [];
    return await _prefs!.remove(_storageKey);
  }

  /// Get request by ID
  static Future<StoredRequest?> getRequestById(String requestId) async {
    final List<StoredRequest> requests = await getAllRequests();
    try {
      return requests.firstWhere((r) => r.requestId == requestId);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache (force reload from storage next time)
  static void clearCache() {
    _cachedRequests = null;
  }
}
