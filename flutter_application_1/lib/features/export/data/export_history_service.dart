import '/config/api.dart';

class ExportHistoryService {
  // GET EXPORTS with pagination
  Future<Map<String, dynamic>> getExports({int page = 1, int limit = 20}) async {
    final data = await Api.get("/api/exports?page=$page&limit=$limit");
    return {
      'data': List.from(data['data'] ?? []),
      'pagination': data['pagination'] ?? {},
    };
  }

  // DELETE EXPORT
  Future<bool> deleteExport(int id) async {
    await Api.delete("/api/exports/$id");
    return true;
  }
}
