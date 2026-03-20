import '/config/api.dart';

class PurchaseService {
  /* ================= FETCH VENDORS ================= */

  Future<List<Map<String, dynamic>>> fetchVendors() async {
    final data = await Api.get("/api/vendors/vendors");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= FETCH CATEGORIES ================= */

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final data = await Api.get("/api/categories");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= FETCH ITEMS ================= */

  Future<List<Map<String, dynamic>>> fetchItems(String categoryId) async {
    final data = await Api.get("/api/items/$categoryId");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= FETCH VARIANTS ================= */

  Future<List<Map<String, dynamic>>> fetchVariants(String itemId) async {
    final data = await Api.get("/api/variants/$itemId");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= FETCH ALL VARIANTS ================= */

  Future<List<Map<String, dynamic>>> fetchAllVariants() async {
    final data = await Api.get("/api/variants");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= SAVE PURCHASE ================= */

  Future<Map<String, dynamic>> savePurchase(Map<String, dynamic> body) async {
    final data = await Api.post("/api/purchases", body);
    return data;
  }

  /* ================= GET PURCHASE HISTORY ================= */

  Future<List<Map<String, dynamic>>> fetchPurchases() async {
    final data = await Api.get("/api/purchases");
    return List<Map<String, dynamic>>.from(data);
  }

  /* ================= DELETE PURCHASE ================= */

  Future<void> deletePurchase(String id) async {
    await Api.delete("/api/purchases/$id");
  }

  /* ================= CREATE VENDOR ================= */

  Future<void> addVendor(Map<String, dynamic> body) async {
    await Api.post("/api/vendors/vendors", body);
  }
}
