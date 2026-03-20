import '/config/api.dart';

class VendorPaymentService {
  Future<void> addVendorPayment(String vendorId, double amount) async {
    await Api.post("/api/payments/vendor-payment", {
      "vendor_id": vendorId,
      "amount": amount,
    });
  }
}
