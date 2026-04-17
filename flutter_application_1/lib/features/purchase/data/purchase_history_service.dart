import '/config/api.dart';

class PurchaseHistoryService {
  static Future<Map<String, dynamic>> fetchHistory(
      {int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/purchase-history?page=$page&limit=$limit");
    final responseData = data["data"] ?? {};
    return {
      'data': List.from(responseData["data"] ?? []),
      'pagination': responseData["pagination"] ?? {},
    };
  }

  static Future<bool> deletePurchase(int id) async {
    await Api.delete("/api/purchases/$id");
    return true;
  }
}
