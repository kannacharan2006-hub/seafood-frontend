import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart'; // Standard for date formatting
import '/features/purchase/data/purchase_history_service.dart';
import '/features/purchase/presentation/purchase_detail_screen.dart';


class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List purchases = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  int currentPage = 1;
  bool hasMoreData = true;

  // Figma "Studio" Design Tokens
  final Color kBase = const Color(0xFFFFFFFF);
  final Color kSurface = const Color(0xFFF1F5F9);
  final Color kTextPrimary = const Color(0xFF020617);
  final Color kTextSecondary = const Color(0xFF64748B);
  final Color kActionGreen = const Color(0xFF10B981);
  final Color kDanger = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // Improved Date Formatter: Mar 06, 2024
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> loadHistory({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
      });
    } else {
      setState(() => isFetchingMore = true);
    }

    try {
      // Fetching from service
      final List data = await PurchaseHistoryService.fetchHistory();

      setState(() {
        // Explicit Sort: Highest purchase_id first (Latest Record at top)
        List sortedData = List.from(data);
        sortedData.sort((a, b) {
          int idA = a['purchase_id'] ?? 0;
          int idB = b['purchase_id'] ?? 0;
          return idB.compareTo(idA); // Descending order
        });

        if (isRefresh) {
          purchases = sortedData;
        } else {
          purchases.addAll(sortedData);
        }

        // Mock Pagination Logic
        if (data.length < 10) {
          hasMoreData = false;
        }
        isLoading = false;
        isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  Future<void> deletePurchase(int id) async {
    final index = purchases.indexWhere((p) => p['purchase_id'] == id);
    if (index == -1) return;

    final deletedItem = purchases[index];

    setState(() => purchases.removeAt(index));

    try {
      final success = await PurchaseHistoryService.deletePurchase(id);

      if (!success) {
        setState(() => purchases.insert(index, deletedItem));
        _showStatusSnackBar("Failed to delete record", isError: true);
      } else {
        _showStatusSnackBar("Record deleted successfully");
      }
    } catch (e) {
      setState(() => purchases.insert(index, deletedItem));
      _showStatusSnackBar("Connection error", isError: true);
    }
  }

  void _showStatusSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: isError ? kDanger : kTextPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: kTextPrimary, strokeWidth: 1.5),
      );
    }

    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 48,
              color: kTextSecondary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              "No transactions yet",
              style: TextStyle(
                color: kTextSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => loadHistory(isRefresh: true),
      color: kTextPrimary,
      edgeOffset: 20,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
        itemCount: purchases.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == purchases.length) {
            return _buildPaginationTrigger();
          }
          final purchase = purchases[index];
          return _buildSwipeableRow(purchase, index);
        },
      ),
    );
  }

  Widget _buildPaginationTrigger() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: isFetchingMore
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kTextSecondary,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: () {
                currentPage++;
                loadHistory(isRefresh: false);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kSurface),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "VIEW OLDER TRANSACTIONS",
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
    );
  }

  Widget _buildSwipeableRow(dynamic purchase, int index) {
    return Dismissible(
      key: Key("purchase_${purchase['purchase_id']}"),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => deletePurchase(purchase['purchase_id']),
      confirmDismiss: (direction) =>
          _showConfirmDialog(purchase['vendor_name']),
      background: _buildDeleteBackground(),
      child: _buildStudioRowContent(purchase, index),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 32),
      color: kDanger,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            "REMOVE",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioRowContent(dynamic purchase, int index) {
    return Container(
      color: kBase,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PurchaseDetailScreen(purchaseId: purchase['purchase_id']),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase['vendor_name']?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStudioBadge(
                              "TXN-${purchase['purchase_id'].toString().padLeft(4, '0')}",
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(purchase['date']),
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${purchase['total_amount']}",
                        style: TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "COMPLETED",
                        style: TextStyle(
                          color: kActionGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: kTextSecondary.withOpacity(0.2),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: kSurface,
            indent: 24,
            endIndent: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStudioBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: kTextSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String? vendor) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: kBase,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Confirm Deletion",
            style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Permanently delete purchase record for ${vendor ?? 'vendor'}?",
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "CANCEL",
                style: TextStyle(
                  color: kTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDanger,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "DELETE",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
