import '/config/api.dart';
import '/services/secure_storage.dart';

class ExportService {
  Future<dynamic> createExport({
    required int customerId,
    required String date,
    required List items,
  }) async {
    final body = {"customer_id": customerId, "date": date, "items": items};
    final data = await Api.post("/api/exports", body);
    return data;
  }

  Future<List<dynamic>> getExports({int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/exports?page=$page&limit=$limit");
    return List<dynamic>.from(data["data"] ?? []);
  }

  Future<void> deleteExport(int id) async {
    await Api.delete("/api/exports/$id");
  }

  Future<List<dynamic>> getCustomers() async {
    final companyId = await SecureStorage.getData("company_id");
    final endpoint = companyId != null
        ? "/api/customers?company_id=$companyId"
        : "/api/customers";
    final data = await Api.get(endpoint,
        cacheTtl: const Duration(minutes: 30));
    return List<dynamic>.from(data["data"]);
  }

  Future<List<dynamic>> getCategories() async {
    final data =
        await Api.get("/api/categories", cacheTtl: const Duration(minutes: 30));
    return List<dynamic>.from(data["data"]);
  }

  Future<List<dynamic>> getItems(String categoryId) async {
    final data = await Api.get("/api/items/$categoryId",
        cacheTtl: const Duration(minutes: 15));
    return List<dynamic>.from(data["data"]);
  }

  Future<List<dynamic>> getVariants(String itemId) async {
    final data = await Api.get("/api/variants/by-item/$itemId",
        cacheTtl: const Duration(minutes: 15));
    return List<dynamic>.from(data["data"]);
  }

  Future<dynamic> addCustomer({
    required String name,
    String? phone,
    String? address,
  }) async {
    final companyId = await SecureStorage.getData("company_id");
    final Map<String, dynamic> body = {
      "name": name,
      "phone": phone,
      "address": address,
    };
    if (companyId != null) {
      body["company_id"] = int.tryParse(companyId);
    }
    final data = await Api.post("/api/customers", body);
    return data;
  }
}
