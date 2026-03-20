import '/config/api.dart';

class PurchaseHistoryService {
  /* ================= FETCH HISTORY ================= */

  static Future<List<dynamic>> fetchHistory() async {
    final data = await Api.get("/api/purchase-history");
    return List<dynamic>.from(data);
  }

  /* ================= DELETE PURCHASE ================= */

  static Future<bool> deletePurchase(int id) async {
    await Api.delete("/api/purchases/$id");
    return true;
  }
}
