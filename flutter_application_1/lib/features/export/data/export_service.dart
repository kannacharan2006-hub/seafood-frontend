import '/config/api.dart';

class ExportService {
  /* ================= CREATE EXPORT ================= */

  Future<dynamic> createExport({
    required int customerId,
    required String date,
    required List items,
  }) async {
    final body = {"customer_id": customerId, "date": date, "items": items};

    final data = await Api.post("/api/exports", body);

    return data;
  }

  /* ================= GET EXPORT HISTORY ================= */

  Future<List<dynamic>> getExports() async {
    final data = await Api.get("/api/exports");

    return List<dynamic>.from(data);
  }

  /* ================= DELETE EXPORT ================= */

  Future<void> deleteExport(int id) async {
    await Api.delete("/api/exports/$id");
  }

  /* ================= GET CUSTOMERS ================= */

  Future<List<dynamic>> getCustomers() async {
    final data = await Api.get("/api/customers");

    return List<dynamic>.from(data);
  }

  /* ================= GET CATEGORIES ================= */

  Future<List<dynamic>> getCategories() async {
    final data = await Api.get("/api/categories");

    return List<dynamic>.from(data);
  }

  /* ================= GET ITEMS ================= */

  Future<List<dynamic>> getItems(String categoryId) async {
    final data = await Api.get("/api/items/$categoryId");

    return List<dynamic>.from(data);
  }

  /* ================= GET VARIANTS ================= */

  Future<List<dynamic>> getVariants(String itemId) async {
    final data = await Api.get("/api/variants/$itemId");

    return List<dynamic>.from(data);
  }

  /* ================= ADD CUSTOMER ================= */

  Future<dynamic> addCustomer({
    required String name,
    String? phone,
    String? address,
  }) async {
    final body = {"name": name, "phone": phone, "address": address};

    final data = await Api.post("/api/customers", body);

    return data;
  }
}
