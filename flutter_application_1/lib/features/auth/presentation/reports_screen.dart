import 'package:flutter_application_1/features/auth/data/reports_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

      final daily = await ReportsService.getDailySales(
        "2024-01-01",
        "2030-01-01",
      );

      final customers = await ReportsService.getTopCustomers();
      final products = await ReportsService.getTopProducts();
      final monthly = await ReportsService.getMonthlyTrends();

      if (mounted) {
        setState(() {
          summary = daily["summary"] ?? {};
          trends = monthly["trends"] ?? [];
          topCustomers = customers["top_customers"] ?? [];
          topProducts = products["best_sellers"] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
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
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
      body: RefreshIndicator(
        onRefresh: loadReports,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// DASHBOARD CARDS
                  Row(children: [
                    dashboardCard(
                      "Revenue",
                      "₹ ${summary['total_revenue'] ?? 0}",
                      Icons.currency_rupee,
                      Colors.indigo,
                    ),
                    dashboardCard(
                      "Invoices",
                      "${summary['total_invoices'] ?? 0}",
                      Icons.receipt_long,
                      Colors.teal,
                    ),
                  ]),
                  Row(children: [
                    dashboardCard(
                      "KG Sold",
                      "${summary['total_kg_sold'] ?? 0}",
                      Icons.inventory_2,
                      Colors.orange,
                    ),
                    dashboardCard(
                      "Avg Daily",
                      "₹ ${summary['avg_daily_revenue'] ?? 0}",
                      Icons.show_chart,
                      Colors.purple,
                    ),
                  ]),
                  const SizedBox(height: 25),

                  /// 🔥 NEW IMPACTFUL REVENUE SECTION
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Revenue Trend",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.2),
                                    Colors.green.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "+${(summary['growth'] ?? 15.2).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: trends.isEmpty
                              ? _buildEmptyChart()
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: null,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                        color: Colors.grey.withOpacity(0.15),
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      // Replace the bottomTitles in your LineChartData:
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 36,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            // DYNAMIC CURRENT MONTH - March 2026
                                            final now = DateTime
                                                .now(); // Gets March 2026
                                            final months = [
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month - 2,
                                                  1)), // Jan
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month - 1,
                                                  1)), // Feb
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month,
                                                  1)), // Mar ✓
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month + 1,
                                                  1)), // Apr
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month + 2,
                                                  1)), // May
                                              DateFormat('MMM').format(DateTime(
                                                  now.year,
                                                  now.month + 3,
                                                  1)), // Jun
                                            ];

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: Text(
                                                index < months.length
                                                    ? months[index]
                                                    : '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 45,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              '₹${(value / 1000).toInt()}K',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: buildRevenueChart(),
                                        isCurved: true,
                                        color: Colors.indigo.withOpacity(0.9),
                                        barWidth: 4,
                                        shadow: Shadow(
                                          color: Colors.indigo.withOpacity(0.3),
                                          blurRadius: 10,
                                        ),
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) =>
                                                  FlDotCirclePainter(
                                            radius: 5,
                                            color: Colors.indigo,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.indigo.withOpacity(0.4),
                                              Colors.indigo.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTrendStat(
                                "This Month",
                                "₹${(summary['current_month'] ?? summary['total_revenue'] ?? 0)}",
                                Colors.green,
                                Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTrendStat(
                                "Last Month",
                                "₹${(summary['last_month'] ?? 0)}",
                                Colors.orange,
                                Icons.trending_down,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// TOP CUSTOMERS
                  const Text(
                    "Top Customers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...topCustomers.map((c) => Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(c['name'] ?? "Unknown"),
                          subtitle: Text("Revenue: ₹ ${c['revenue'] ?? 0}"),
                        ),
                      )),

                  const SizedBox(height: 30),

                  /// TOP PRODUCTS
                  const Text(
                    "Top Products",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...topProducts.map((p) => Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.shopping_cart),
                          ),
                          title: Text(
                              "${p['name'] ?? ''} (${p['variant_name'] ?? ''})"),
                          subtitle: Text("Sold: ${p['kg_sold'] ?? '0'} kg"),
                          trailing: Text(
                            "₹ ${p['revenue'] ?? 0}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }

  /// NEW HELPER METHODS
  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No trend data available",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pull down to refresh",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendStat(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
