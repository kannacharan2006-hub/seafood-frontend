import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '/features/purchase/data/purchase_history_service.dart';
import '/features/purchase/presentation/purchase_detail_screen.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/utils/date_format_util.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

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

  // Date Formatters - Using utility class for consistency
  String _formatDate(String? dateStr) =>
      DateFormatUtil.formatDateMMMddyyyy(dateStr);
  String _formatDateTime(String? dateStr) =>
      DateFormatUtil.formatDateTimeMMMddyyyyHHmm(dateStr);

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
      final result = await PurchaseHistoryService.fetchPurchases(
        page: currentPage,
        limit: 20,
      );

      final List data = List.from(result['data']);
      final pagination = result['pagination'] as Map<String, dynamic>;

      setState(() {
        if (isRefresh) {
          purchases = data;
        } else {
          purchases.addAll(data);
        }

        hasMoreData = pagination['hasNextPage'] ?? false;
        isLoading = false;
        isFetchingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  Future<void> deletePurchase(String id) async {
    final index =
        purchases.indexWhere((p) => p['purchase_id'].toString() == id);
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
      return ListView.builder(
        itemCount: 6, // Show 6 skeleton items
        itemBuilder: (context, index) => _buildSkeletonItem(),
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
              color: kTextSecondary.withValues(alpha: 0.2),
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
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await loadHistory(isRefresh: true);
      },
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

  Widget _buildSkeletonItem() {
    return Container(
      color: kBase,
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 100,
                        height: 16,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SkeletonLoader(
                            width: 80,
                            height: 12,
                            borderRadius: 4,
                          ),
                          SizedBox(width: 8),
                          SkeletonLoader(
                            width: 60,
                            height: 12,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonLoader(
                      width: 80,
                      height: 16,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 4),
                    SkeletonLoader(
                      width: 60,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 24,
            endIndent: 24,
          ),
        ],
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
      background: _buildDeleteBackground(),
      // Increased touch target for better accessibility
      child: Semantics(
        label:
            'Purchase from ${purchase['vendor_name'] ?? 'unknown vendor'}. Tap to view details. Swipe to delete.',
        button: true,
        child: Container(
          width: double.infinity,
          color: kBase,
          child: _buildStudioRowContent(purchase, index),
        ),
      ),
      onDismissed: (_) => deletePurchase(purchase['purchase_id'].toString()),
      confirmDismiss: (direction) =>
          _showConfirmDialog(purchase['vendor_name']),
    );
  }

  Widget _buildDeleteBackground() {
    return Semantics(
      label: 'Delete',
      button: true,
      child: Container(
        alignment: Alignment.centerRight,
        width: 80, // Fixed width for touch target
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
                            Flexible(
                              child: Text(
                                purchase['created_at'] != null
                                    ? _formatDateTime(purchase['created_at'])
                                    : _formatDate(purchase['date']),
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                  Semantics(
                    label: 'View details',
                    button: true,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
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
