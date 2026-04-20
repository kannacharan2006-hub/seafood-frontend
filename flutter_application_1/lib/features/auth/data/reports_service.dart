import '/config/api.dart';

class ReportsService {
  static Future getDailySales(String from, String to) async {
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

  static Future getRevenuePerformance({String? from, String? to}) async {
    final queryParams = <String>[];
    if (from != null && to != null) {
      queryParams.add('from=$from');
      queryParams.add('to=$to');
    }
    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    return await Api.get("/api/reports/revenue-performance$query");
  }

  static Future getPriceTrends() async {
    return await Api.get("/api/reports/price-trends");
  }

  static Future getPurchaseVsSales() async {
    return await Api.get("/api/reports/purchase-vs-sales");
  }

  static Future getYesterdayProfit() async {
    return await Api.get("/api/reports/yesterday-profit");
  }
}
