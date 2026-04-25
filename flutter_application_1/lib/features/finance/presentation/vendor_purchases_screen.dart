import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/vendor_purchase_service.dart';

class VendorPurchasesScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const VendorPurchasesScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<VendorPurchasesScreen> createState() => _VendorPurchasesScreenState();
}

class _VendorPurchasesScreenState extends State<VendorPurchasesScreen> {
  final VendorPurchaseService _service = VendorPurchaseService();
  List purchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchVendorPurchases(widget.vendorId);
      setState(() {
        purchases = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
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
        title: Column(
          children: [
            Text(
              widget.vendorName.toUpperCase(),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Purchase History',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "No purchases yet",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];
                    final isPaid = purchase['payment_status'] == 'PAID';
                    final paymentMode = purchase['payment_mode'] ?? 'NONE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPaid ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Row(
                          children: [
                            Text(
                              "₹${purchase['total_amount']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPaid ? "PAID" : "PENDING",
                                style: TextStyle(
                                  color: isPaid ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date: ${_formatDate(purchase['date'])}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (paymentMode != 'NONE' &&
                                  paymentMode != 'CASH')
                                Text(
                                  "Mode: $paymentMode",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PurchasePaymentScreen(
                                purchaseId: purchase['purchase_id'],
                                vendorName: widget.vendorName,
                                vendorId: widget.vendorId,
                              ),
                            ),
                          ).then((_) => loadPurchases());
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class PurchasePaymentScreen extends StatefulWidget {
  final int purchaseId;
  final String vendorName;
  final String vendorId;

  const PurchasePaymentScreen({
    super.key,
    required this.purchaseId,
    required this.vendorName,
    required this.vendorId,
  });

  @override
  State<PurchasePaymentScreen> createState() => _PurchasePaymentScreenState();
}

class _PurchasePaymentScreenState extends State<PurchasePaymentScreen> {
  final VendorPurchaseService _service = VendorPurchaseService();
  Map<String, dynamic>? purchase;
  bool isLoading = true;

  String selectedMode = 'CASH';
  final phoneController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadPurchase();
  }

  Future<void> loadPurchase() async {
    try {
      final data = await _service.fetchVendorPurchases(widget.vendorId);
      final found = data.firstWhere(
        (p) => p['purchase_id'] == widget.purchaseId,
        orElse: () => {},
      );
      setState(() {
        purchase = found;
        isLoading = false;
        if (found.isNotEmpty) {
          selectedMode = found['payment_mode'] ?? 'CASH';
          phoneController.text = found['payment_phone'] ?? '';
          referenceController.text = found['payment_reference'] ?? '';
          notesController.text = found['payment_notes'] ?? '';
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> savePayment() async {
    setState(() => isSaving = true);
    try {
      await _service.updatePayment(widget.purchaseId, {
        "payment_status":
            purchase?['payment_status'] == 'PAID' ? 'PENDING' : 'PAID',
        "payment_mode": selectedMode,
        "payment_phone":
            phoneController.text.isNotEmpty ? phoneController.text : null,
        "payment_reference": referenceController.text.isNotEmpty
            ? referenceController.text
            : null,
        "payment_notes":
            notesController.text.isNotEmpty ? notesController.text : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment updated")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || purchase == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Payment Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isPaid = purchase!['payment_status'] == 'PAID';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "PAYMENT DETAILS",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "₹${purchase!['total_amount']}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPaid ? "PAID" : "PENDING",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Date: ${_formatDate(purchase!['date'])}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "PAYMENT MODE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                'CASH',
                'UPI',
                'BANK_TRANSFER',
                'NONE',
              ].map((mode) {
                final isSelected = selectedMode == mode;
                return ChoiceChip(
                  label: Text(mode.replaceAll('_', ' ')),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedMode = mode);
                    }
                  },
                  selectedColor: Colors.blue.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Payment Phone (optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(
                labelText: "Reference No. (optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? Colors.orange : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isPaid ? "MARK AS PENDING" : "MARK AS PAID",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
