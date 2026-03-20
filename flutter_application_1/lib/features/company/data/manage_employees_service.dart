import '/config/api.dart';

class ManageEmployeesService {
  /* ================= CREATE EMPLOYEE ================= */

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

  /* ================= GET EMPLOYEES ================= */

  static Future<List<dynamic>> getEmployees() async {
    final response = await Api.get("/api/users");

    return response;
  }

  /* ================= DELETE EMPLOYEE ================= */

  static Future deleteEmployee(int id) async {
    await Api.delete("/api/users/$id");
  }

  /* ================= UPDATE EMPLOYEE ================= */

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
