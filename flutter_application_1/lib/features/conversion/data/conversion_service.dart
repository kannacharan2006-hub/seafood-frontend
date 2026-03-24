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

  /* ================= GET HISTORY (Paginated) ================= */

  Future<Map<String, dynamic>> getConversions({int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/conversions/convert?page=$page&limit=$limit");
    return {
      'data': List.from(data['data'] ?? []),
      'pagination': data['pagination'] ?? {},
    };
  }

  /* ================= DELETE ================= */

  Future<void> deleteConversion(int id) async {
    await Api.delete("/api/conversions/convert/$id");
  }
}
