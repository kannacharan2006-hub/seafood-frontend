import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'export_history_screen.dart';
import '../data/export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class ExportItem {
  String? categoryId;
  String? itemId;
  String? variantId;

  TextEditingController qtyController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  double get total {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }
}

class _ExportScreenState extends State<ExportScreen>
    with SingleTickerProviderStateMixin {
  final ExportService _exportService = ExportService();
  late TabController _tabController;

  List customers = [];
  List categories = [];
  Map<String, List> itemsMap = {};
  Map<String, List> variantsMap = {};

  String? selectedCustomer;
  DateTime selectedDate = DateTime.now();

  List<ExportItem> items = [];
  bool isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    fetchCustomers();
    fetchCategories();
    items.add(ExportItem());
  }

  @override
  void dispose() {
    for (var item in items) {
      item.qtyController.dispose();
      item.priceController.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  /* ================= FETCH DATA (Logic Unchanged) ================= */

  Future<void> fetchCustomers() async {
    try {
      final data = await _exportService.getCustomers();

      setState(() {
        customers = data;

        if (customers.isNotEmpty) {
          selectedCustomer = customers.first['id'].toString();
        }
      });
    } catch (e) {
      debugPrint("Customer fetch error: $e");
    }
  }

  void showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Customer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Customer Name"),
              ),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

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
                await _exportService.addCustomer(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                );

                Navigator.pop(context);

                nameController.clear();
                phoneController.clear();
                addressController.clear();

                fetchCustomers();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _exportService.getCategories();
      setState(() {
        categories = data;
      });
    } catch (_) {}
  }

  Future<void> fetchItems(String categoryId) async {
    try {
      final data = await _exportService.getItems(categoryId);

      itemsMap[categoryId] = data;

      setState(() {});
    } catch (_) {}
  }

  Future<void> fetchVariants(String itemId) async {
    try {
      final data = await _exportService.getVariants(itemId);

      variantsMap[itemId] = data;

      setState(() {});
    } catch (_) {}
  }

  /* ================= SAVE EXPORT (Logic Unchanged) ================= */

  Future<void> saveExport() async {
    if (isSaving) return;

    if (selectedCustomer == null) {
      _showSnackBar("Please select customer", isError: true);
      return;
    }

    for (var item in items) {
      if (item.categoryId == null ||
          item.itemId == null ||
          item.variantId == null ||
          item.qtyController.text.isEmpty ||
          item.priceController.text.isEmpty) {
        _showSnackBar("Complete all item fields", isError: true);
        return;
      }
    }

    setState(() => isSaving = true);

    final formattedItems = items.map((item) {
      return {
        "variant_id": int.parse(item.variantId!),
        "quantity": double.parse(item.qtyController.text),
        "price_per_kg": double.parse(item.priceController.text),
      };
    }).toList();

    try {
      await _exportService.createExport(
        customerId: int.parse(selectedCustomer!),
        date: selectedDate.toString().split(' ')[0],
        items: formattedItems,
      );

      _showSnackBar("Export Saved Successfully");

      setState(() {
        selectedCustomer = null;
        items.clear();
        items.add(ExportItem());
      });
    } catch (e) {
      _showSnackBar("Failed to save export", isError: true);
    }

    setState(() => isSaving = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /* ================= UI ENHANCEMENTS ================= */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light Slate Background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Export Management",
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.blueGrey.shade300,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(
              child: Text(
                "Entry",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "History",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildExportEntry(), const ExportHistoryScreen()],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => items.add(ExportItem())),
              icon: const Icon(Icons.add_rounded),
              label: const Text("New Item"),
              elevation: 4,
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }

  Widget buildExportEntry() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer & Date
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownSearch<String>(
                        selectedItem: selectedCustomer,

                        items: customers
                            .map<String>((c) => c['id'].toString())
                            .toList(),

                        popupProps: const PopupProps.menu(showSearchBox: true),

                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: _inputDecoration(
                            "Customer",
                            Icons.person_rounded,
                          ),
                        ),

                        itemAsString: (id) {
                          final customer = customers.firstWhere(
                            (c) => c['id'].toString() == id,
                            orElse: () => {'name': ''},
                          );
                          return customer['name'];
                        },

                        onChanged: (value) {
                          setState(() {
                            selectedCustomer = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: showAddCustomerDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: theme.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Billing Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.edit_calendar_rounded,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "Order Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => buildItemCard(items[index], index),
          ),

          const SizedBox(height: 10),

          // Grand Total Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Summary",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Payable Amount",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹ ${calculateGrandTotal().toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveExport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A), // Deep Slate/Black
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save & Finalize",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemCard(ExportItem item, int index) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "#${index + 1}",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Product Selection",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
                const Spacer(),
                if (items.length > 1)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    onPressed: () => setState(() => items.removeAt(index)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category Selector
                DropdownSearch<String>(
                  selectedItem: item.categoryId,
                  items: categories.map((c) => c['id'].toString()).toList(),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    menuProps: MenuProps(
                      borderRadius: BorderRadius.circular(20),
                      elevation: 8,
                    ),
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: _inputDecoration(
                      "Category",
                      Icons.grid_view_rounded,
                    ),
                  ),
                  itemAsString: (id) => categories.firstWhere(
                    (c) => c['id'].toString() == id,
                  )['name'],
                  onChanged: (value) async {
                    setState(() {
                      item.categoryId = value;
                      item.itemId = null;
                      item.variantId = null;
                    });
                    await fetchItems(value!);
                  },
                ),
                const SizedBox(height: 12),

                // Item & Variant Logic
                if (item.categoryId != null) ...[
                  DropdownSearch<String>(
                    selectedItem: item.itemId,
                    items: (itemsMap[item.categoryId] ?? [])
                        .map<String>((i) => i['id'].toString())
                        .toList(),
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: _inputDecoration(
                        "Select Item",
                        Icons.shopping_bag_outlined,
                      ),
                    ),
                    itemAsString: (id) => (itemsMap[item.categoryId] ?? [])
                        .firstWhere((i) => i['id'].toString() == id)['name'],
                    onChanged: (value) async {
                      setState(() {
                        item.itemId = value;
                        item.variantId = null;
                      });
                      await fetchVariants(value!);
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                if (item.itemId != null)
                  DropdownSearch<String>(
                    selectedItem: item.variantId,
                    items: (variantsMap[item.itemId] ?? [])
                        .map<String>((v) => v['id'].toString())
                        .toList(),
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: _inputDecoration(
                        "Variant",
                        Icons.tune_rounded,
                      ),
                    ),
                    itemAsString: (id) =>
                        (variantsMap[item.itemId] ?? []).firstWhere(
                          (v) => v['id'].toString() == id,
                        )['variant_name'],
                    onChanged: (value) =>
                        setState(() => item.variantId = value),
                  ),

                const SizedBox(height: 16),

                // Quantitative Inputs
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: item.qtyController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          "Weight (KG)",
                          Icons.fitness_center_rounded,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: item.priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          "Rate / KG",
                          Icons.currency_rupee_rounded,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Subtotal Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Item Total",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "₹ ${item.total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade400),
      labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
      filled: true,
      fillColor: Colors.blueGrey.shade50.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blueGrey.shade50),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  double calculateGrandTotal() {
    double total = 0;
    for (var item in items) {
      total += item.total;
    }
    return total;
  }
}
