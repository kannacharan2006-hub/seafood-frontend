import '/config/api.dart';
import '/services/secure_storage.dart';

class CustomerBalanceService {
  Future<List<dynamic>> fetchCustomers() async {
    final companyId = await SecureStorage.getData("company_id");
    final endpoint = companyId != null
        ? "/api/customers?company_id=$companyId"
        : "/api/customers";
    final data = await Api.get(endpoint);
    return List<dynamic>.from(data["data"]);
  }

  Future<Map<String, dynamic>> fetchCustomerBalance(String customerId) async {
    final data = await Api.get("/api/payments/customer-balance/$customerId");
    return Map<String, dynamic>.from(data["data"] ?? data);
  }
}
