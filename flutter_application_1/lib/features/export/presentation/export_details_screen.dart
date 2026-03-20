import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/invoice_service.dart';

class ExportDetailsScreen extends StatelessWidget {
  final Map exportData;

  const ExportDetailsScreen({super.key, required this.exportData});

  // Calm & Modern Design Tokens
  static const Color kPrimary = Color(0xFF4F46E5); // Soft Indigo
  static const Color kHeaderBg = Colors.white;
  static const Color kPageBg = Color(0xFFF1F5F9); // Very light slate
  static const Color kTextDark = Color(0xFF1E293B);
  static const Color kTextLight = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE2E8F0);
  static const Color kSuccess = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final items = exportData['items'] ?? [];
    double grandTotal = 0;
    for (var item in items) {
      grandTotal += double.tryParse(item['total'].toString()) ?? 0;
    }

    String formattedDate = "N/A";
    if (exportData['date'] != null) {
      DateTime parsedDate = DateTime.parse(exportData['date']).toLocal();
      formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
    }

    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Export Details",
          style: GoogleFonts.plusJakartaSans(
            color: kTextDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _handleShare(context),
            icon: const Icon(Icons.share_outlined, size: 18, color: kPrimary),
            label: Text(
              "Share",
              style: GoogleFonts.plusJakartaSans(
                color: kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSummary(formattedDate, grandTotal),
            _buildItemsList(items),
            _buildSecurityNotice(),
            const SizedBox(height: 100), // Space for bottom of screen
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(String date, double total) {
    return Container(
      width: double.infinity,
      color: kHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: kSuccess, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Export Successful",
                  style: GoogleFonts.plusJakartaSans(
                    color: kSuccess,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            exportData['customer_name']?.toString() ?? "General Customer",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: kTextDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Transaction on $date",
            style: GoogleFonts.plusJakartaSans(
              color: kTextLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "TOTAL AMOUNT",
            style: GoogleFonts.plusJakartaSans(
              color: kTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${NumberFormat("#,##,###.##").format(total)}",
            style: GoogleFonts.plusJakartaSans(
              color: kPrimary,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            exportData['invoice_no'] ?? 'ID: INV-0000',
            style: GoogleFonts.plusJakartaSans(
              color: kTextLight.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List items) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kTextDark.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              "Products Exported",
              style: GoogleFonts.plusJakartaSans(
                color: kTextDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: kBorder,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              final String itemName = item['item_name'] ?? '';
              final String variant = item['variant_name'] ?? '';

              String displayName = variant;
              if (itemName.isNotEmpty && variant.isNotEmpty) {
                displayName = "$itemName – $variant ";
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.plusJakartaSans(
                              color: kTextDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${item['quantity']} kg × ₹${item['price_per_kg']}",
                            style: GoogleFonts.plusJakartaSans(
                              color: kTextLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "₹${item['total']}",
                      style: GoogleFonts.plusJakartaSans(
                        color: kTextDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Grand Total",
                  style: GoogleFonts.plusJakartaSans(
                    color: kTextDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "₹${NumberFormat("#,##,###.##").format(double.tryParse(exportData['total_amount']?.toString() ?? '0') ?? 0)}",
                  style: GoogleFonts.plusJakartaSans(
                    color: kPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Icon(Icons.verified_user_rounded, color: kTextLight, size: 24),
          const SizedBox(height: 12),
          Text(
            "This export was authorized by ${exportData['created_by'] ?? 'System'}. This serves as an official digital voucher.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: kTextLight,
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      final service = InvoiceService();

      await service.shareInvoice(exportData['id']);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Voucher shared successfully"),
            backgroundColor: kTextDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not share at this time")),
        );
      }
    }
  }
}
