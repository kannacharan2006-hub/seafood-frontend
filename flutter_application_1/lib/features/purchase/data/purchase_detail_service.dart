import '/config/api.dart';

class PurchaseDetailService {
  static Future<Map<String, dynamic>?> fetchDetails(int purchaseId) async {
    final data = await Api.get("/api/purchase-history/$purchaseId");

    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    return null;
  }
}
