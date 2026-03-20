import '/config/api.dart';

class StockService {
  Future<List<dynamic>> getRawStock() async {
    final response = await Api.get("/api/stocks/raw-stock");
    return response;
  }

  Future<List<dynamic>> getFinalStock() async {
    final response = await Api.get("/api/stocks/final-stock");
    return response;
  }
}
