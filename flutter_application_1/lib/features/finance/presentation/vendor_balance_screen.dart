import 'package:flutter/material.dart';
import '../data/vendor_balance_service.dart';

class VendorBalanceScreen extends StatefulWidget {
  const VendorBalanceScreen({super.key});

  @override
  State<VendorBalanceScreen> createState() => _VendorBalanceScreenState();
}

class _VendorBalanceScreenState extends State<VendorBalanceScreen>
    with SingleTickerProviderStateMixin {

  final VendorBalanceService _service = VendorBalanceService();
  late TabController _tabController;

  List<dynamic> pendingVendors = [];
  List<dynamic> completedVendors = [];
  double totalPendingAmount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {

      final vendors = await _service.fetchVendors();

      List<dynamic> pending = [];
      List<dynamic> completed = [];
      double pendingSum = 0;

      for (var v in vendors) {

        final detail = await _service.fetchVendorBalance(
          v['id'].toString(),
        );

        double balance = (detail['balance'] ?? 0).toDouble();

        var fullData = {
          ...v,
          'balance': balance,
          'totalPurchase': detail['totalPurchase'] ?? 0,
          'totalPaid': detail['totalPaid'] ?? 0,
        };

        if (balance > 0) {
          pending.add(fullData);
          pendingSum += balance;
        } else {
          completed.add(fullData);
        }
      }
setState(() {
        pendingVendors = pending;
        completedVendors = completed;
        totalPendingAmount = pendingSum;
        isLoading = false;
      });

    } catch (e) {

      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading vendors"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          "Vendor Accounts",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          indicatorWeight: 3,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,

          tabs: const [
            Tab(text: "Pending Pay"),
            Tab(text: "Settled"),
          ],
        ),
      ),

    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [

              /// SUMMARY HEADER
              _buildSummaryHeader(),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(pendingVendors, true),
                    _buildList(completedVendors, false),
                  ],
                ),
              ),
            ],
          ),
  );
}

Widget _buildSummaryHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      children: [

        _statItem(
          "Pending",
          "₹${totalPendingAmount.toStringAsFixed(0)}",
          Colors.orange,
        ),

        const SizedBox(width: 10),

        _statItem(
          "Vendors",
          "${pendingVendors.length + completedVendors.length}",
          Colors.blueGrey,
        ),
      ],
    ),
  );
}

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),

        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildList(List<dynamic> list, bool isPending) {

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              isPending
                  ? Icons.thumb_up_outlined
                  : Icons.check_circle_outline,
              size: 48,
              color: Colors.grey[300],
            ),

            const SizedBox(height: 12),

            Text(
              isPending
                  ? "No pending payments"
                  : "All accounts settled",

              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,

        separatorBuilder: (_, __) => const SizedBox(height: 8),

        itemBuilder: (context, index) {

          final vendor = list[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: IntrinsicHeight(
              child: Row(
                children: [
/// STATUS STRIPE
                  Container(
                    width: 4,

                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.orange
                          : Colors.green,

                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListTile(

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      title: Text(
                        vendor['name'] ?? "Unknown Vendor",

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),

                        child: Text(
                          "Total: ₹${vendor['totalPurchase'] ?? 0}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [

                          Text(
                            "₹${vendor['balance'] ?? 0}",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isPending
                                  ? Colors.redAccent
                                  : Colors.green,
                            ),
                          ),

                          Text(
                            isPending
                                ? "Outstanding"
                                : "Settled",

                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}