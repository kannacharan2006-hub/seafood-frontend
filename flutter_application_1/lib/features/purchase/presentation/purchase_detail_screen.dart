import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:ui';

import '/features/purchase/data/purchase_detail_service.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailScreen({Key? key, required this.purchaseId})
    : super(key: key);

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  Map<String, dynamic>? purchaseData;
  bool isLoading = true;

  // Figma "Studio" Design Tokens
  final Color kBase = const Color(0xFFFFFFFF);
  final Color kSurface = const Color(0xFFF8FAFC);
  final Color kTextPrimary = const Color(0xFF0F172A);
  final Color kTextSecondary = const Color(0xFF64748B);
  final Color kBorder = const Color(0xFFE2E8F0);
  final Color kAccent = const Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final data = await PurchaseDetailService.fetchDetails(
          widget.purchaseId,
          );

      setState(() {
        purchaseData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: kBase,
        body: Center(
          child: CircularProgressIndicator(
            color: kTextPrimary,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (purchaseData == null) {
      return Scaffold(
        backgroundColor: kBase,
        appBar: AppBar(
          backgroundColor: kBase,
          elevation: 0,
          leading: const BackButton(color: Color(0xFF0F172A)),
        ),
        body: Center(
          child: Text(
            "Transaction not found",
            style: TextStyle(color: kTextSecondary),
          ),
        ),
      );
    }

    String formattedDate = "N/A";
    if (purchaseData!['date'] != null) {
      DateTime parsedDate = DateTime.parse(purchaseData!['date']).toLocal();
      formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
    }

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kBase,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: kTextPrimary),
        title: Text(
          "PURCHASE RECEIPT",
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: kTextPrimary, size: 20),
            onPressed: () {}, // Optional: Share functionality
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildReceiptHeader(formattedDate),
            _buildVendorSummary(),
            _buildItemsList(),
            _buildTotalBreakdown(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(String date) {
    return Container(
      color: kBase,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kSurface, shape: BoxShape.circle),
            child: Icon(
              Icons.receipt_long_rounded,
              color: kTextPrimary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "₹${purchaseData!['total_amount']}",
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                "TXN-${widget.purchaseId.toString().padLeft(6, '0')}",
              ),
              const SizedBox(width: 8),
              _buildBadge(date.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: kTextSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVendorSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kAccent.withOpacity(0.1),
            child: Icon(Icons.business_rounded, color: kAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SUPPLIER",
                  style: TextStyle(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  purchaseData!['vendor_name'] ?? 'Unknown Vendor',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user_rounded, color: kAccent, size: 18),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final List items = purchaseData?['items'] ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: kBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "ORDER BREAKDOWN",
              style: TextStyle(
                color: kTextSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
          ...items.map((item) => _buildItemRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    final String itemName = item['item_name'] ?? '';
    final String variant = item['variant_name'] ?? '';

    // Build clearer label
    String displayName = variant;
    if (variant.isNotEmpty && itemName.isNotEmpty) {
      displayName = "$itemName – $variant ";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kSurface, width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item['quantity'] ?? 0} kg × ₹${item['price_per_kg'] ?? 0}",
                  style: TextStyle(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹${item['total']?? 0}",
            style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBreakdown() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kTextPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryLine(
            "Subtotal",
            "₹${purchaseData?['total_amount'] ?? 0}",
            Colors.white70,
          ),
          const SizedBox(height: 12),
          _buildSummaryLine("Taxes & Fees", "₹0.00", Colors.white70),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24),
          ),
          _buildSummaryLine(
            "Grand Total",
            "₹${purchaseData?['total_amount'] ?? 0}",
            Colors.white,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 14 : 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold ? 18 : 13,
          ),
        ),
      ],
    );
  }
}
