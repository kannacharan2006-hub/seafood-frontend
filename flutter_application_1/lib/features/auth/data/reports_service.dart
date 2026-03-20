import '/config/api.dart';

class ReportsService {
  static Future getDailySales(String from, String to) async {
    print("Calling daily sales...");
    return await Api.get("/api/reports/daily-sales?from=$from&to=$to");
  }

  static Future getTopCustomers() async {
    return await Api.get("/api/reports/top-customers");
  }

  static Future getTopProducts() async {
    return await Api.get("/api/reports/top-products");
  }

  static Future getMonthlyTrends() async {
    return await Api.get("/api/reports/monthly-trends");
  }

  static Future getInvoiceStatus() async {
    return await Api.get("/api/reports/invoice-status");
  }

  static Future getCustomerLTV() async {
    return await Api.get("/api/reports/customer-ltv");
  }

  static Future getPriceTrends() async {
    return await Api.get("/api/reports/price-trends");
  }
}
