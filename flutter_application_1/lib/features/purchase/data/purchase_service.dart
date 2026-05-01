import '/config/api.dart';

class PurchaseService {
  Future<List<Map<String, dynamic>>> fetchVendors() async {
    final data = await Api.get("/api/vendors/vendors",
        cacheTtl: const Duration(minutes: 30));
    return List<Map<String, dynamic>>.from(data["data"]);
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final data =
        await Api.get("/api/categories", cacheTtl: const Duration(minutes: 30));
    return List<Map<String, dynamic>>.from(data["data"]);
  }

  Future<List<Map<String, dynamic>>> fetchItems(String categoryId) async {
    final data = await Api.get("/api/items/$categoryId",
        cacheTtl: const Duration(minutes: 15));
    return List<Map<String, dynamic>>.from(data["data"]);
  }

  Future<List<Map<String, dynamic>>> fetchVariants(String itemId) async {
    final data = await Api.get("/api/variants/by-item/$itemId",
        cacheTtl: const Duration(minutes: 15));
    return List<Map<String, dynamic>>.from(data["data"]);
  }

  Future<List<Map<String, dynamic>>> fetchAllVariants() async {
    final data =
        await Api.get("/api/variants", cacheTtl: const Duration(minutes: 15));
    return List<Map<String, dynamic>>.from(data["data"]);
  }

  Future<Map<String, dynamic>> savePurchase(Map<String, dynamic> body) async {
    final data = await Api.post("/api/purchases", body);
    return data;
  }

  Future<Map<String, dynamic>> fetchPurchases(
      {int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/purchase-history?page=$page&limit=$limit");
    return {
      'data': List<Map<String, dynamic>>.from(data["data"] ?? []),
      'pagination': data["pagination"] ?? {},
    };
  }

  Future<void> deletePurchase(String id) async {
    await Api.delete("/api/purchases/$id");
  }

  Future<void> addVendor(Map<String, dynamic> body) async {
    await Api.post("/api/vendors/vendors", body);
  }

  Future<void> updateVendor(
      int vendorId, String name, String phone, String address) async {
    await Api.put("/api/vendors/vendors/$vendorId", {
      "name": name,
      "phone": phone,
      "address": address,
    });
  }
}
