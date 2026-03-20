import '/config/api.dart';

class CustomerBalanceService {
  Future<List<dynamic>> fetchCustomers() async {
    final data = await Api.get("/api/customers");
    return List<dynamic>.from(data);
  }

  Future<Map<String, dynamic>> fetchCustomerBalance(String customerId) async {
    final data = await Api.get("/api/payments/customer-balance/$customerId");
    return Map<String, dynamic>.from(data);
  }
}
