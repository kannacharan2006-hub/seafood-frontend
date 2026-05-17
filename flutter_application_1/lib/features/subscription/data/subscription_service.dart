import '../../../config/api.dart';

class SubscriptionService {
  static Future<List<dynamic>> getPlans() async {
    try {
      final response = await Api.get('/api/subscriptions/plans');
      if (response['success'] == true) {
        return response['data'] ?? [];
      }
      throw Exception(response['message'] ?? 'Failed to load plans');
    } catch (e) {
      throw Exception('Failed to load plans: $e');
    }
  }

  static Future<Map<String, dynamic>> createSubscription(
    String planId, {
    String? couponCode,
  }) async {
    try {
      final body = {
        'planId': planId,
        if (couponCode != null) 'couponCode': couponCode,
      };

      final response = await Api.post('/api/subscriptions/create', body);
      if (response['success'] == true) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to create subscription');
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await Api.get('/api/subscriptions/status');
      if (response['success'] == true) {
        return response['data'] ?? {};
      }
      throw Exception(response['message'] ?? 'Failed to get status');
    } catch (e) {
      throw Exception('Failed to get subscription status: $e');
    }
  }

  static Future<void> applyReferralCode(String referralCode) async {
    try {
      final response = await Api.post('/api/subscriptions/referral', {
        'referralCode': referralCode,
      });
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to apply referral');
      }
    } catch (e) {
      throw Exception('Failed to apply referral: $e');
    }
  }

  static Future<void> cancelSubscription() async {
    try {
      final response = await Api.post('/api/subscriptions/cancel', {});
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to cancel subscription');
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  static Future<Map<String, dynamic>> getReferralInfo() async {
    try {
      final response = await Api.get('/api/subscriptions/referral-info');
      if (response['success'] == true) {
        return response['data'] ?? {};
      }
      throw Exception(response['message'] ?? 'Failed to get referral info');
    } catch (e) {
      throw Exception('Failed to get referral info: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(
    String paymentId,
    String orderId,
    String signature,
  ) async {
    try {
      final response = await Api.post('/api/subscriptions/verify', {
        'payment_id': paymentId,
        'order_id': orderId,
        'signature': signature,
      });
      return response;
    } catch (e) {
      throw Exception('Payment verification failed: $e');
    }
  }
}
