import 'package:flutter_application_1/features/auth/data/reports_service.dart';
import 'package:flutter/material.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  Map summary = {};
  List topCustomers = [];
  List topProducts = [];
  Map profitAnalysis = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      setState(() => loading = true);

      // Load data with individual try-catch for each API call
      Map<String, dynamic> daily = {};
      Map<String, dynamic> customers = {};
      Map<String, dynamic> products = {};
      Map<String, dynamic> profit = {};

      try {
        daily = await ReportsService.getDailySales("2024-01-01", "2030-01-01");
      } catch (_) {}

      try {
        customers = await ReportsService.getTopCustomers();
      } catch (_) {}

      try {
        products = await ReportsService.getTopProducts();
      } catch (_) {}

      try {
        profit = await ReportsService.getPurchaseVsSales();
      } catch (_) {}

      setState(() {
        summary = daily["summary"] ?? {};
        topCustomers = customers["top_customers"] ?? [];
        topProducts = products["best_sellers"] ?? [];
        profitAnalysis = profit["profit_analysis"] ?? {};
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error loading reports")));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildHealthScore() {
    // Calculate health score based on profit margin and business metrics
    final profitMargin =
        double.tryParse(profitAnalysis['profit_margin']?.toString() ?? '0') ??
            0;
    final totalRevenue =
        double.tryParse(summary['total_revenue']?.toString() ?? '0') ?? 0;
    final totalInvoices =
        int.tryParse(summary['total_invoices']?.toString() ?? '0') ?? 0;

    // Calculate score (0-100)
    int score = 0;

    // Profit margin contributes 50 points (ideal: 20%+)
    if (profitMargin >= 20) {
      score += 50;
    } else if (profitMargin >= 15) {
      score += 40;
    } else if (profitMargin >= 10) {
      score += 30;
    } else if (profitMargin >= 5) {
      score += 20;
    } else {
      score += 10;
    }

    // Revenue volume contributes 30 points
    if (totalRevenue >= 1000000) {
      score += 30;
    } else if (totalRevenue >= 500000) {
      score += 25;
    } else if (totalRevenue >= 100000) {
      score += 20;
    } else if (totalRevenue >= 50000) {
      score += 15;
    } else {
      score += 10;
    }

    // Order volume contributes 20 points
    if (totalInvoices >= 100) {
      score += 20;
    } else if (totalInvoices >= 50) {
      score += 15;
    } else if (totalInvoices >= 20) {
      score += 10;
    } else {
      score += 5;
    }

    // Determine status and color
    String status;
    Color statusColor;
    IconData statusIcon;

    if (score >= 80) {
      status = "Excellent";
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.emoji_events;
    } else if (score >= 60) {
      status = "Good";
      statusColor = const Color(0xFF3B82F6);
      statusIcon = Icons.thumb_up;
    } else if (score >= 40) {
      status = "Fair";
      statusColor = const Color(0xFFFF9800);
      statusIcon = Icons.trending_up;
    } else {
      status = "Needs Attention";
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: statusColor.withValues(alpha: 0.3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$score",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "/ 100",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Business Health Score",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Profit: ${profitMargin.toStringAsFixed(1)}% • Orders: $totalInvoices",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    dashboardCard("KG Sold", "${summary['total_kg_sold'] ?? 0}",
                        Icons.inventory, Colors.orange),
                    dashboardCard(
                        "Avg Daily",
                        "₹ ${summary['avg_daily_revenue'] ?? 0}",
                        Icons.show_chart,
                        Colors.purple),
                  ],
                ),

                const SizedBox(height: 30),

                /// PROFIT ANALYSIS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.indigo.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Profit Analysis",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Main profit display
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Gross Profit",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹ ${double.tryParse(profitAnalysis['gross_profit']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${profitAnalysis['profit_margin'] ?? 0}% Margin",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sales vs Purchases comparison
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.trending_up,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Sales",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹ ${double.tryParse(profitAnalysis['total_sales']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${double.tryParse(profitAnalysis['kg_sold']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'} kg",
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.compare_arrows,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.shopping_cart,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Purchases",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹ ${double.tryParse(profitAnalysis['total_purchases']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${double.tryParse(profitAnalysis['kg_purchased']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'} kg",
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// BUSINESS HEALTH SCORE
                _buildHealthScore(),

                const SizedBox(height: 30),

                /// TOP CUSTOMERS
                const Text(
                  "Top Customers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
