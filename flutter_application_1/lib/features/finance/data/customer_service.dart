import '/config/api.dart';
import '/services/secure_storage.dart';

class CustomerService {
  Future<List<dynamic>> fetchCustomers() async {
    final companyId = await SecureStorage.getData("company_id");
    final endpoint = companyId != null
        ? "/api/customers?company_id=$companyId"
        : "/api/customers";
    final data = await Api.get(endpoint,
        cacheTtl: const Duration(minutes: 30));
    return List<dynamic>.from(data["data"]);
  }

  Future<void> addCustomer(String name, String? phone, String? address) async {
    final companyId = await SecureStorage.getData("company_id");
    final Map<String, dynamic> body = {
      "name": name,
      "phone": phone,
      "address": address,
    };
    if (companyId != null) {
      body["company_id"] = int.tryParse(companyId);
    }
    await Api.post("/api/customers", body);
  }
}
