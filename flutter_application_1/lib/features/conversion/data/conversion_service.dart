import '/config/api.dart';

class ConversionService {
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

  Future<Map<String, dynamic>> getConversions(
      {int page = 1, int limit = 20}) async {
    final data =
        await Api.get("/api/conversions/convert?page=$page&limit=$limit");
    final responseData = data["data"] ?? {};
    return {
      'data': List.from(responseData["data"] ?? []),
      'pagination': responseData["pagination"] ?? {},
    };
  }

  Future<void> deleteConversion(int id) async {
    await Api.delete("/api/conversions/convert/$id");
  }
}
