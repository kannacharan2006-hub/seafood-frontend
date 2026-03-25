import 'package:flutter/material.dart';
import 'export_details_screen.dart';
import '../data/export_history_service.dart';
import '../../../core/widgets/skeleton_loader.dart';

class ExportHistoryScreen extends StatefulWidget {
  const ExportHistoryScreen({super.key});

  @override
  State<ExportHistoryScreen> createState() => _ExportHistoryScreenState();
}

class _ExportHistoryScreenState extends State<ExportHistoryScreen> {
  final ExportHistoryService _historyService = ExportHistoryService();

  List exports = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    fetchExports();
  }

  Future<void> fetchExports() async {
    try {
      final result = await _historyService.getExports(page: 1);

      if (!mounted) return;

      final pagination = result['pagination'] as Map<String, dynamic>;
      
      setState(() {
        exports = List.from(result['data']);
        currentPage = 1;
        hasMoreData = pagination['hasNextPage'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar("Error fetching history", isError: true);
    }
  }

  Future<void> loadMoreExports() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() => isLoadingMore = true);

    try {
      final result = await _historyService.getExports(
        page: currentPage + 1,
        limit: limit,
      );

      if (!mounted) return;

      final pagination = result['pagination'] as Map<String, dynamic>;
      final newData = List.from(result['data']);

      setState(() {
        exports.addAll(newData);
        currentPage++;
        hasMoreData = pagination['hasNextPage'] ?? false;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingMore = false);
    }
  }

  Future<void> deleteExport(int id) async {
    bool confirm = await _showDeleteDialog();
    if (!confirm) return;

    final success = await _historyService.deleteExport(id);

    if (success) {
      fetchExports();
      _showSnackBar("Invoice deleted successfully");
    } else {
      _showSnackBar("Failed to delete invoice", isError: true);
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Delete Invoice?"),
            content: const Text(
              "This action cannot be undone. Are you sure you want to remove this export record?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 5,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonLoader();
    }

    if (exports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 80,
              color: Colors.blueGrey.shade100,
            ),
            const SizedBox(height: 16),
            Text(
              "No export history found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchExports,
      displacement: 20,
      color: Theme.of(context).primaryColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            loadMoreExports();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: exports.length + (hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == exports.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final exp = exports[index];
            final dateStr = (exp['date'] ?? '').toString().split('T')[0];
            final theme = Theme.of(context);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateToDetails(exp),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exp['invoice_no'] ?? 'INV-N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exp['customer_name'] ?? 'Unknown Customer',
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: Colors.blueGrey.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade400,
                                    fontSize: 12,
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
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.blueGrey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onSelected: (value) {
                              if (value == 'view') _navigateToDetails(exp);
                              if (value == 'delete') deleteExport(exp['id']);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility_outlined, size: 20),
                                    SizedBox(width: 10),
                                    Text("View Details"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (exp['total_amount'] != null)
                            Text(
                              "₹${exp['total_amount']}",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetails(Map exp) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExportDetailsScreen(exportData: exp)),
    );
  }
}
