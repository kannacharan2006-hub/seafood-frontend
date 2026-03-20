import '/config/api.dart';

class PaymentService {
  Future<void> recordCustomerPayment(String customerId, String amount) async {
    await Api.post("/api/payments/customer-payment", {
      "customer_id": customerId,
      "amount": amount,
    });
  }

  Future<List<dynamic>> fetchCustomerPaymentHistory(String customerId) async {
    final data = await Api.get(
      "/api/payments/customer-payment-history/$customerId",
    );

    return List<dynamic>.from(data);
  }
}
