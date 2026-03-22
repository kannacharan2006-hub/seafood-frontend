import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  final String? userName;

  const DashboardScreen({super.key, this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool loading = true;
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Design Tokens
  static const Color kIndigo = Color(0xFF6366F1);
  static const Color kEmerald = Color(0xFF10B981);
  static const Color kSlateDark = Color(0xFF0F172A);
  static const Color kSlate = Color(0xFF64748B);
  static const Color kBackground = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await DashboardService.fetchDashboard();

      if (!mounted) return;

      setState(() {
        dashboardData = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        dashboardData = {};
      });

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: CircularProgressIndicator(color: kIndigo, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        color: kIndigo,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeroHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Quick Stats", "Your performance today"),
                    const SizedBox(height: 16),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildProfitAnalytics(),
                    const SizedBox(height: 32),
                    _sectionHeader("Business Health", "Cash and Stock status"),
                    const SizedBox(height: 16),
                    _buildBusinessHealth(),
                    const SizedBox(height: 32),
                    _sectionHeader("Recent Activity", "Latest 5 entries"),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 32),
                    _sectionHeader("Top Suppliers", "Best performing vendors"),
                    const SizedBox(height: 16),
                    _buildTopSuppliers(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 17
        ? "Good Afternoon"
        : "Good Evening";

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: kIndigo,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [kIndigo, Color(0xFF4F46E5), Color(0xFF818CF8)],
            ),
          ),
          child: const Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.analytics_outlined,
              size: 200,
              color: Colors.white,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$greeting, ${widget.userName ?? "Charan"}",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat('EEEE, dd MMM').format(DateTime.now()),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kSlateDark,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kSlate),
            ),
          ],
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: kSlate.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        _statCard(
          "Today Purchase",
          dashboardData?['today_purchase_cost'] ?? 0,
          Icons.shopping_basket_outlined,
          Colors.orange,
        ),
        _statCard(
          "Monthly Sales",
          dashboardData?['month_sales_revenue'] ?? 0,
          Icons.show_chart_rounded,
          Colors.blue,
        ),
        _statCard(
          "Today Profit",
          dashboardData?['today_profit'] ?? 0,
          Icons.account_balance_wallet_outlined,
          kEmerald,
        ),
        _statCard(
          "Month Profit",
          dashboardData?['month_profit'] ?? 0,
          Icons.savings_outlined,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _statCard(String title, dynamic val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kSlateDark.withOpacity(0.04),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Icon(Icons.more_vert_rounded, size: 16, color: kSlate),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: kSlate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              currencyFormat.format(num.tryParse(val.toString()) ?? 0),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kSlateDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitAnalytics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kSlateDark, Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: kEmerald, size: 20),
              const SizedBox(width: 8),
              Text(
                "MONTH PROFIT TREND",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(
              num.tryParse(dashboardData?['month_profit']?.toString() ?? '0') ?? 0,
            ),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 2),
                      FlSpot(3, 5),
                      FlSpot(4, 3),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: kEmerald,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kEmerald.withOpacity(0.3), Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHealth() {
    return Column(
      children: [
        Row(
          children: [
            _healthBarCard(
              "Vendor Payable",
              dashboardData?['vendor_payable'] ?? 0,
              Colors.redAccent,
              true,
            ),
            const SizedBox(width: 12),
            _healthBarCard(
              "Customer Receivable",
              dashboardData?['customer_receivable'] ?? 0,
              kEmerald,
              true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _healthBarCard(
              "Raw Stock",
              "${dashboardData?['total_raw_stock'] ?? 0} kg",
              Colors.teal,
              false,
            ),
            const SizedBox(width: 12),
            _healthBarCard(
              "Final Stock",
              "${dashboardData?['total_final_stock'] ?? 0} kg",
              Colors.indigo,
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _healthBarCard(String label, dynamic val, Color col, bool isAmount) {
    String valueText = isAmount
        ? currencyFormat.format(num.tryParse(val.toString()) ?? 0)
        : val.toString();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kSlate,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valueText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kSlateDark,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: col.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = (dashboardData?['recent_activity'] as List? ?? []);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, i) {
          final item = activities[i];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded, size: 18, color: kIndigo),
            ),
            title: Text(
              item['name'] ?? "",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: kSlateDark,
              ),
            ),
            subtitle: Text(
              item['type'] ?? "",
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kSlate),
            ),
            trailing: Text(
              currencyFormat.format(
                num.tryParse(item['amount'].toString()) ?? 0,
              ),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: kSlateDark,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSuppliers() {
    final suppliers = (dashboardData?['top_5_suppliers'] as List? ?? [])
        .take(3)
        .toList();
    return Row(
      children: List.generate(suppliers.length, (index) {
        final s = suppliers[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: kIndigo.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kIndigo.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(
                  ["🥇", "🥈", "🥉"][index],
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  s['name'] ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: kSlateDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(
                    num.tryParse(s['total_purchase'].toString()) ?? 0,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: kIndigo,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
