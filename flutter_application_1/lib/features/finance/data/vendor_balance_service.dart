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

  Future<void> updateVendor(
      int vendorId, String name, String phone, String address) async {
    await Api.put("/api/vendors/vendors/$vendorId", {
      "name": name,
      "phone": phone,
      "address": address,
    });
  }
}
