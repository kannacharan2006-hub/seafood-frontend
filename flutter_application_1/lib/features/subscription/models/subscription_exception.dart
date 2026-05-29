class SubscriptionExpiredException implements Exception {
  final String message;
  final String? planName;
  final String? endedAt;
  final List<dynamic> plans;
  final String code;

  SubscriptionExpiredException({
    required this.message,
    this.planName,
    this.endedAt,
    required this.plans,
    this.code = 'SUBSCRIPTION_EXPIRED',
  });

  @override
  String toString() => message;
}
