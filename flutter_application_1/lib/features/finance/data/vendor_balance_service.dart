import '/config/api.dart';
import '/services/secure_storage.dart';

class VendorBalanceService {
  Future<List<dynamic>> fetchVendors() async {
    final companyId = await SecureStorage.getData("company_id");
    final endpoint = companyId != null
        ? "/api/vendors?company_id=$companyId"
        : "/api/vendors";
    final data = await Api.get(endpoint, cacheTtl: const Duration(minutes: 30));
    return List<dynamic>.from(data["data"]);
  }

  Future<Map<String, dynamic>> fetchVendorBalance(String vendorId) async {
    final data = await Api.get("/api/payments/vendor-balance/$vendorId");
    return Map<String, dynamic>.from(data["data"] ?? data);
  }

  Future<List<dynamic>> fetchVendorPaymentHistory(String vendorId) async {
    final data =
        await Api.get("/api/payments/vendor-payment-history/$vendorId");
    return List<dynamic>.from(data["data"] ?? data);
  }

  Future<void> updateVendor(
      int vendorId, String name, String phone, String address) async {
    final companyId = await SecureStorage.getData("company_id");
    final Map<String, dynamic> body = {
      "name": name,
      "phone": phone,
      "address": address,
    };
    if (companyId != null) {
      body["company_id"] = int.tryParse(companyId);
    }
    await Api.put("/api/vendors/$vendorId", body);
  }
}
