import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          'phone': detail['vendor_phone'] ?? v['phone'] ?? '',
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
              isPending ? Icons.thumb_up_outlined : Icons.check_circle_outline,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              isPending ? "No pending payments" : "All accounts settled",
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
                      color: isPending ? Colors.orange : Colors.green,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () => _showVendorOptions(context, vendor),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                vendor['name'] ?? "Unknown Vendor",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (vendor['phone'] != null &&
                                vendor['phone'].toString().isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: vendor['phone'].toString()));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Phone copied: ${vendor['phone']}"),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        vendor['phone'].toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.copy,
                                          size: 12, color: Colors.green),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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
                                color:
                                    isPending ? Colors.redAccent : Colors.green,
                              ),
                            ),
                            Text(
                              isPending ? "Outstanding" : "Settled",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
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

  void _showVendorOptions(BuildContext context, Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Vendor"),
              onTap: () {
                Navigator.pop(context);
                _showEditVendorDialog(context, vendor);
              },
            ),
            if (vendor['phone'] != null &&
                vendor['phone'].toString().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Copy Phone Number"),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: vendor['phone'].toString()));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Phone copied: ${vendor['phone']}")),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditVendorDialog(
      BuildContext context, Map<String, dynamic> vendor) {
    final nameController = TextEditingController(text: vendor['name']);
    final phoneController = TextEditingController(text: vendor['phone'] ?? '');
    final addressController =
        TextEditingController(text: vendor['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Vendor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.updateVendor(
                  vendor['id'],
                  nameController.text,
                  phoneController.text,
                  addressController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
