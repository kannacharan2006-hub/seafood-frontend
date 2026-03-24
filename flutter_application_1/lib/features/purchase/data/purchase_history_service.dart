import '/config/api.dart';

class PurchaseHistoryService {
  /* ================= FETCH HISTORY (Paginated) ================= */

  static Future<Map<String, dynamic>> fetchHistory({int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/purchase-history?page=$page&limit=$limit");
    return {
      'data': List.from(data['data'] ?? []),
      'pagination': data['pagination'] ?? {},
    };
  }

  /* ================= DELETE PURCHASE ================= */

  static Future<bool> deletePurchase(int id) async {
    await Api.delete("/api/purchases/$id");
    return true;
  }
}
