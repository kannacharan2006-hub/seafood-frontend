import '/config/api.dart';

class StockService {
  Future<List<dynamic>> getRawStock() async {
    final response = await Api.get("/api/stocks/raw-stock");
    return List<dynamic>.from(response["data"]);
  }

  Future<List<dynamic>> getFinalStock() async {
    final response = await Api.get("/api/stocks/final-stock");
    return List<dynamic>.from(response["data"]);
  }
}
