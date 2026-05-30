import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../conversion/data/conversion_service.dart';
import '../../purchase/data/purchase_service.dart';
import '../presentation/conversion_history_screen.dart';
import '../../../utils/error_handler.dart';

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class ConversionItem {
  String? variantId;
  TextEditingController qtyController = TextEditingController();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final ConversionService _service = ConversionService();
  final PurchaseService _purchaseService = PurchaseService();

  List variants = [];
  Map<String, dynamic> _rawStockMap = {};
  List<ConversionItem> rawItems = [ConversionItem()];
  List<ConversionItem> finalItems = [ConversionItem()];
  TextEditingController notesController = TextEditingController();

  bool isSaving = false;
  bool isLoadingVariants = true;

  @override
  void initState() {
    super.initState();
    loadVariants();
    _loadRawStock();
  }

  Future<void> _loadRawStock() async {
    try {
      final stock = await _service.fetchRawStock();
      if (!mounted) return;
      setState(() {
        _rawStockMap = {for (var s in stock) s['variant_id'].toString(): s};
      });
    } catch (_) {}
  }

  Future<void> loadVariants() async {
    try {
      final data = await _purchaseService.fetchAllVariants();
      if (!mounted) return;
      setState(() {
        variants = data;
        isLoadingVariants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingVariants = false);
      ErrorHandler.showError(context, e, onRetry: loadVariants);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          "Grade Change (Convert)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConversionHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: isLoadingVariants
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // --- SECTION 1: TAKING OUT ---
                  _buildSectionCard(
                    title: "1. TAKE OUT OLD STOCK",
                    subtitle: "What are you removing?",
                    icon: Icons.remove_circle,
                    iconColor: Colors.red,
                    items: rawItems,
                    stockMap: _rawStockMap,
                    buttonText: "+ Add More Old Items",
                    trailing: IconButton(
                      icon: const Icon(Icons.inventory_2_rounded,
                          size: 20, color: Colors.teal),
                      tooltip: "View available stock",
                      onPressed: _showStockPopup,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 40,
                      color: Colors.teal,
                    ),
                  ),

                  // --- SECTION 2: BRINGING IN ---
                  _buildSectionCard(
                    title: "2. BRING IN NEW GRADE",
                    subtitle: "What did it become?",
                    icon: Icons.add_circle,
                    iconColor: Colors.green,
                    items: finalItems,
                    buttonText: "+ Add More New Items",
                  ),

                  const SizedBox(height: 20),

                  // Notes
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: "Short Note (Why are you changing?)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BIG SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _handleSave();
                            },
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SAVE CHANGE",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<ConversionItem> items,
    required String buttonText,
    Widget? trailing,
    Map<String, dynamic>? stockMap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            ConversionItem item = entry.value;
            final double? availQty = stockMap != null && item.variantId != null
                ? double.tryParse(
                    (stockMap[item.variantId]?['available_qty'] ?? '')
                        .toString())
                : null;
            final double? enteredQty = double.tryParse(item.qtyController.text);
            final bool exceedsStock =
                availQty != null && enteredQty != null && enteredQty > availQty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownSearch<String>(
                          key: ValueKey('conv_${title}_${item.hashCode}'),
                          items: variants
                              .map<String>((v) => v['id'].toString())
                              .toList(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "Select Item",
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          itemAsString: (id) {
                            final v = variants.firstWhere(
                              (v) => v['id'].toString() == id,
                            );
                            return "${v['item_name']} (${v['grade']})";
                          },
                          onChanged: (val) =>
                              setState(() => item.variantId = val),
                          popupProps:
                              const PopupProps.menu(showSearchBox: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: item.qtyController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText:
                                availQty != null ? "Kg / $availQty" : "Kg",
                            errorText: exceedsStock
                                ? "Only $availQty kg available"
                                : null,
                            errorStyle: const TextStyle(
                                fontSize: 11, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (items.length > 1)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => setState(() => items.removeAt(idx)),
                        ),
                    ],
                  ),
                  if (availQty != null && item.variantId != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        "Available: $availQty kg",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => items.add(ConversionItem()));
            },
            icon: const Icon(Icons.add),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _showStockPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StockViewer(service: _service),
    );
  }

  void _handleSave() async {
    if (rawItems.any((e) => e.variantId == null) ||
        finalItems.any((e) => e.variantId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select items first!")),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      List raw = rawItems
          .map(
            (e) => {
              "variant_id": int.parse(e.variantId!),
              "quantity": double.parse(e.qtyController.text),
            },
          )
          .toList();
      List finalList = finalItems
          .map(
            (e) => {
              "variant_id": int.parse(e.variantId!),
              "quantity": double.parse(e.qtyController.text),
            },
          )
          .toList();

      await _service.createConversion(
        raw,
        finalList,
        DateTime.now().toString().split(" ")[0],
        notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Saved Successfully!")));
      setState(() {
        rawItems = [ConversionItem()];
        finalItems = [ConversionItem()];
        notesController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }
}

class _StockViewer extends StatefulWidget {
  final ConversionService service;
  const _StockViewer({required this.service});

  @override
  State<_StockViewer> createState() => _StockViewerState();
}

class _StockViewerState extends State<_StockViewer> {
  List? _stock;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.service.fetchRawStock();
      if (!mounted) return;
      setState(() {
        _stock = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.inventory_2_rounded,
                      color: Colors.teal, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "Available Raw Stock",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_stock != null)
                    Text(
                      "${_stock!.length} items",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _stock == null || _stock!.isEmpty
                        ? Center(
                            child: Text(
                              "No stock available",
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 15),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _stock!.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final s = _stock![i];
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.teal.withAlpha(25),
                                  child: const Icon(Icons.inventory,
                                      size: 16, color: Colors.teal),
                                ),
                                title: Text(
                                  "${s['item_name']} (${s['variant_name']})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  s['category_name'] ?? '',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${s['available_qty']} kg",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
