import '/config/api.dart';

class DashboardService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
    // Bypass cache when triggered by websocket update for real-time data
    final data =
        await Api.get("/api/dashboard/summary", cacheTtl: Duration.zero);
    if (data == null) {
      throw Exception("Dashboard data not available");
    }
    return data;
  }
}
