import '/config/api.dart';

class ExportHistoryService {
  Future<Map<String, dynamic>> getExports(
      {int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/exports?page=$page&limit=$limit");
    final responseData = data["data"] ?? {};
    return {
      'data': List.from(responseData["data"] ?? []),
      'pagination': responseData["pagination"] ?? {},
    };
  }

  Future<bool> deleteExport(int id) async {
    await Api.delete("/api/exports/$id");
    return true;
  }
}
