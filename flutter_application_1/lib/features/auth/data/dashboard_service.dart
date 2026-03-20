import '/config/api.dart';

class DashboardService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
    final data = await Api.get("/api/dashboard/summary");

    if (data == null) {
      throw Exception("Dashboard data not available");
    }

    return data;
  }
}
