enum RequestStatus {
  pending,
  ready,
  completed,
}

class StoredRequest {
  final String requestId;
  final String label;
  final String birthDate;
  final String birthPlace;
  final String? birthTime;
  final RequestStatus status;
  final DateTime submittedAt;
  final DateTime? lastCheckedAt;
  final bool hasNotification;

  StoredRequest({
    required this.requestId,
    required this.label,
    required this.birthDate,
    required this.birthPlace,
    this.birthTime,
    required this.status,
    required this.submittedAt,
    this.lastCheckedAt,
    required this.hasNotification,
  });

  // Helper getters
  bool get isReady => status == RequestStatus.ready;
  bool get isPending => status == RequestStatus.pending;
  bool get isCompleted => status == RequestStatus.completed;
  bool get needsPolling => status == RequestStatus.pending;

  // Create from JSON
  factory StoredRequest.fromJson(Map<String, dynamic> json) {
    return StoredRequest(
      requestId: json['requestId'] as String,
      label: json['label'] as String,
      birthDate: json['birthDate'] as String,
      birthPlace: json['birthPlace'] as String,
      birthTime: json['birthTime'] as String?,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      lastCheckedAt: json['lastCheckedAt'] != null
          ? DateTime.parse(json['lastCheckedAt'] as String)
          : null,
      hasNotification: json['hasNotification'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'label': label,
      'birthDate': birthDate,
      'birthPlace': birthPlace,
      'birthTime': birthTime,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'lastCheckedAt': lastCheckedAt?.toIso8601String(),
      'hasNotification': hasNotification,
    };
  }

  // Create a copy with updated fields
  StoredRequest copyWith({
    String? requestId,
    String? label,
    String? birthDate,
    String? birthPlace,
    String? birthTime,
    RequestStatus? status,
    DateTime? submittedAt,
    DateTime? lastCheckedAt,
    bool? hasNotification,
  }) {
    return StoredRequest(
      requestId: requestId ?? this.requestId,
      label: label ?? this.label,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      birthTime: birthTime ?? this.birthTime,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      hasNotification: hasNotification ?? this.hasNotification,
    );
  }

  @override
  String toString() {
    return 'StoredRequest(id: $requestId, label: $label, status: ${status.name})';
  }
}
