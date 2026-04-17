import '/config/api.dart';

class VendorBalanceService {
  Future<List<dynamic>> fetchVendors() async {
    final data = await Api.get("/api/vendors/vendors");
    return List<dynamic>.from(data["data"]);
  }

  Future<Map<String, dynamic>> fetchVendorBalance(String vendorId) async {
    final data = await Api.get("/api/payments/vendor-balance/$vendorId");
    return Map<String, dynamic>.from(data["data"] ?? data);
  }
}
