import 'package:flutter/material.dart';
import '../data/stock_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StockService _service = StockService();

  List<dynamic> rawStock = [];
  List<dynamic> finalStock = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadStock();
  }

  Future<void> loadStock() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        _service.getRawStock(),
        _service.getFinalStock(),
      ]);

      setState(() {
        rawStock = results[0];
        finalStock = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Map<String, List<dynamic>> _groupByCategory(List<dynamic> stock) {
    Map<String, List<dynamic>> grouped = {};

    for (var item in stock) {
      String category = item['category_name'] ?? 'Uncategorized';

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }

      grouped[category]!.add(item);
    }

    return grouped;
  }

  Widget buildStockList(List<dynamic> stock) {
    if (stock.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No stock items found",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }
final groupedData = _groupByCategory(stock);
    final categories = groupedData.keys.toList();

    return RefreshIndicator(
      onRefresh: loadStock,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, catIndex) {
          final categoryName = categories[catIndex];
          final items = groupedData[categoryName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(indent: 10)),
                  ],
                ),
              ),
              ...items.map((item) => _buildStockItemCard(item)).toList(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
  Widget _buildStockItemCard(dynamic item) {
    double qty = double.tryParse(item['available_qty'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child:
              const Icon(Icons.layers_outlined, color: Colors.blue, size: 20),
        ),
        title: Text(
          "${item['item_name']}",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          "Grade: ${item['variant_name']}",
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                qty > 5 ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$qty KG",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: qty > 5
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ),
      ),
    );
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
          "Inventory Stock",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Raw Stock"),
            Tab(text: "Final Stock"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                buildStockList(rawStock),
                buildStockList(finalStock),
              ],
            ),
    );
  }
}