import '/config/api.dart';

class ManageEmployeesService {
  static Future<void> createEmployee({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Api.post("/api/users", {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "role": "EMPLOYEE",
    });
  }

  static Future<List<dynamic>> getEmployees() async {
    final response = await Api.get("/api/users");
    return List<dynamic>.from(response["data"]);
  }

  static Future deleteEmployee(int id) async {
    await Api.delete("/api/users/$id");
  }

  static Future updateEmployee({
    required int id,
    required String name,
    required String email,
    required String phone,
  }) async {
    await Api.put("/api/users/$id", {
      "name": name,
      "email": email,
      "phone": phone,
    });
  }
}
