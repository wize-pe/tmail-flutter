class SentryContextData {
  final String? feature;          // Feature/module name (e.g., "MailSync")
  final String? endpoint;         // API endpoint (e.g., "/messages")
  final String? method;           // HTTP method (e.g., "GET", "POST")
  final int? statusCode;          // Response status code
  final String? userAction;       // User action (e.g., "Clicked send button")
  final Map<String, dynamic>? additionalInfo; // Extra contextual info
  final DateTime timestamp;       // Auto-added when created always UTC

  SentryContextData({
    this.feature,
    this.endpoint,
    this.method,
    this.statusCode,
    this.userAction,
    this.additionalInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toMap() {
    return {
      if (feature != null) 'feature': feature,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (statusCode != null) 'statusCode': statusCode,
      if (userAction != null) 'userAction': userAction,
      if (additionalInfo != null && additionalInfo!.isNotEmpty)
        'additionalInfo': additionalInfo,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  SentryContextData copyWith({
    String? feature,
    String? endpoint,
    String? method,
    int? statusCode,
    String? userAction,
    Map<String, dynamic>? additionalInfo,
  }) {
    return SentryContextData(
      feature: feature ?? this.feature,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      statusCode: statusCode ?? this.statusCode,
      userAction: userAction ?? this.userAction,
      additionalInfo: {
        ...?this.additionalInfo,
        ...?additionalInfo,
      },
      timestamp: timestamp,
    );
  }
}
