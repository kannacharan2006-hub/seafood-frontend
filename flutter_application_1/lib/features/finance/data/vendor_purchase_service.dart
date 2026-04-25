import '/config/api.dart';

class VendorPurchaseService {
  Future<List<dynamic>> fetchVendorPurchases(String vendorId) async {
    final data = await Api.get("/api/purchase-history/vendor/$vendorId");
    return List<dynamic>.from(data["data"] ?? data);
  }

  Future<void> updatePayment(int purchaseId, Map<String, dynamic> body) async {
    await Api.put("/api/purchases/$purchaseId/payment", body);
  }
}
