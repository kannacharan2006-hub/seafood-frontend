import '/config/api.dart';

class ExportHistoryService {
  // GET EXPORTS
  Future<List> getExports() async {
    final data = await Api.get("/api/exports");
    return List.from(data);
  }

  // DELETE EXPORT
  Future<bool> deleteExport(int id) async {
    await Api.delete("/api/exports/$id");
    return true;
  }
}
