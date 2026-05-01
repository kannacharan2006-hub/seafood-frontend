import '/config/api.dart';

class CustomerService {
  Future<List<dynamic>> fetchCustomers() async {
    final data =
        await Api.get("/api/customers", cacheTtl: const Duration(minutes: 30));
    return List<dynamic>.from(data["data"]);
  }

  Future<void> addCustomer(String name, String? phone, String? address) async {
    await Api.post("/api/customers", {
      "name": name,
      "phone": phone,
      "address": address,
    });
  }
}
