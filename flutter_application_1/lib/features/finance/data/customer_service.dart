import '/config/api.dart';

class CustomerService {
  Future<List<dynamic>> fetchCustomers() async {
    final data = await Api.get("/api/customers");

    return List<dynamic>.from(data);
  }
}
