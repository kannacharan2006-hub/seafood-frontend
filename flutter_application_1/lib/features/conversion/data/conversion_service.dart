import '/config/api.dart';

class ConversionService {
  /* ================= CREATE CONVERSION ================= */

  Future<void> createConversion(
    List rawItems,
    List finalItems,
    String date,
    String notes,
  ) async {
    await Api.post("/api/conversions/convert", {
      "raw_items": rawItems,
      "final_items": finalItems,
      "date": date,
      "notes": notes,
    });
  }

  /* ================= GET HISTORY ================= */

  Future<List<dynamic>> getConversions() async {
    final data = await Api.get("/api/conversions/convert");
    return data;
  }

  /* ================= DELETE ================= */

  Future<void> deleteConversion(int id) async {
    await Api.delete("/api/conversions/convert/$id");
  }
}
