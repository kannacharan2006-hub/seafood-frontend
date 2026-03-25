import 'package:flutter_application_1/features/auth/data/reports_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {

  Map summary = {};
  List trends = [];
  List topCustomers = [];
  List topProducts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {

    try {

      setState(() => loading = true);

      final daily =
          await ReportsService.getDailySales("2024-01-01", "2030-01-01");

      final customers = await ReportsService.getTopCustomers();
      final products = await ReportsService.getTopProducts();
      final monthly = await ReportsService.getMonthlyTrends();

      setState(() {
        summary = daily["summary"] ?? {};
        trends = monthly["trends"] ?? [];
        topCustomers = customers["top_customers"] ?? [];
        topProducts = products["best_sellers"] ?? [];
      });

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error loading reports")));

    } finally {

      setState(() => loading = false);

    }
  }

  List<FlSpot> buildRevenueChart() {

    List<FlSpot> spots = [];

    for (int i = 0; i < trends.length; i++) {

      spots.add(
        FlSpot(
          i.toDouble(),
          double.tryParse(trends[i]['revenue'].toString()) ?? 0.0,
        ),
      );
    }

    return spots;
  }

  Widget dashboardCard(String title, String value, IconData icon, Color color) {

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon, color: Colors.white, size: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        elevation: 0,
        title: const Text("Business Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadReports,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(

              padding: const EdgeInsets.all(16),

              children: [

                /// DASHBOARD CARDS
                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [

                    dashboardCard(
                        "Revenue",
                        "₹ ${summary['total_revenue'] ?? 0}",
                        Icons.currency_rupee,
                        Colors.indigo),

                    dashboardCard(
                        "Invoices",
                        "${summary['total_invoices'] ?? 0}",
                        Icons.receipt_long,
                        Colors.teal),

                    dashboardCard(
                        "KG Sold",
                        "${summary['total_kg_sold'] ?? 0}",
                        Icons.inventory,
                        Colors.orange),

                    dashboardCard(
                        "Avg Daily",
                        "₹ ${summary['avg_daily_revenue'] ?? 0}",
                        Icons.show_chart,
                        Colors.purple),
                  ],
                ),

                const SizedBox(height: 30),

                /// REVENUE TREND
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Revenue Trend",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 200,

                        child: trends.isEmpty
                            ? const Center(child: Text("No trend data"))
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  borderData: FlBorderData(show: false),

                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: buildRevenueChart(),
                                      isCurved: true,
                                      color: Colors.indigo,
                                      barWidth: 4,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.indigo.withValues(alpha: 0.15),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// TOP CUSTOMERS
                const Text(
                  "Top Customers",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),

                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topCustomers.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {

                      final c = topCustomers[index];

                      return ListTile(

                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          c['name'] ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Text(
                          "Revenue ₹ ${c['revenue'] ?? 0}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// TOP PRODUCTS
                const Text(
                  "Top Products",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),

                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topProducts.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {

                      final p = topProducts[index];

                      return ListTile(

                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.orange,
                          ),
                        ),

                        title: Text(
                          "${p['name']} (${p['variant_name']})",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Text(
                          "Sold ${p['kg_sold']} kg",
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        trailing: Text(
                          "₹ ${p['revenue']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}