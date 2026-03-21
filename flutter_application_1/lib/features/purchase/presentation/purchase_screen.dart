import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter_application_1/features/purchase/presentation/purchase_history_screen.dart';
import '../data/purchase_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class PurchaseItem {
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

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  final PurchaseService purchaseService = PurchaseService();
  late TabController _tabController;
  List vendors = [];
  List categories = [];
  Map<String, List> itemsMap = {};
  Map<String, List> variantsMap = {};
  String? selectedVendor;
  List<PurchaseItem> items = [PurchaseItem()];
  bool isSaving = false;
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController vendorPhoneController = TextEditingController();
  final TextEditingController vendorAddressController = TextEditingController();

  // Figma Design Tokens - Lightly Enhanced for Visibility
  final Color kPrimary = const Color(0xFF0F172A); // Midnight Slate
  final Color kAccent = const Color(
    0xFF059669,
  ); // Slightly darker Emerald for better contrast
  final Color kCanvas = const Color(0xFFF8FAFC); // Crisp Off-White
  final Color kSubtle = const Color(
    0xFF64748B,
  ); // Darker Slate for improved text legibility

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchVendors();
    fetchCategories();
  }

  /* ================= Logic (Preserved) ================= */
  Future<void> fetchVendors() async {
    final data = await purchaseService.fetchVendors();

    setState(() {
      vendors = data;
    });
  }

  Future<void> showAddVendorDialog() async {
    vendorNameController.clear();
    vendorPhoneController.clear();
    vendorAddressController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Vendor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vendorNameController,
                decoration: const InputDecoration(labelText: "Vendor Name"),
              ),

              TextField(
                controller: vendorPhoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

              TextField(
                controller: vendorAddressController,
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
                final body = {
                  "name": vendorNameController.text,
                  "phone": vendorPhoneController.text,
                  "address": vendorAddressController.text,
                };

                try {
                  await purchaseService.addVendor(body);

                  if (!mounted) return;
                  Navigator.pop(context);

                  await fetchVendors();

                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Vendor Added")));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add vendor")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCategories() async {
    final data = await purchaseService.fetchCategories();

    setState(() {
      categories = data;
    });
  }

  Future<void> fetchItems(String categoryId) async {
    final data = await purchaseService.fetchItems(categoryId);

    setState(() {
      itemsMap[categoryId] = data;
    });
  }

  Future<void> fetchVariants(String itemId) async {
    final data = await purchaseService.fetchVariants(itemId);

    setState(() {
      variantsMap[itemId] = data;
    });
  }

  Future<void> savePurchase() async {
    if (isSaving || selectedVendor == null) return;

    setState(() => isSaving = true);

    try {
      List purchaseItems = [];

      for (var item in items) {
        if (item.variantId == null ||
            item.qtyController.text.isEmpty ||
            item.priceController.text.isEmpty) {
          continue;
        }

        purchaseItems.add({
          "variant_id": int.parse(item.variantId!),
          "quantity": double.tryParse(item.qtyController.text) ?? 0,
          "price_per_kg": double.tryParse(item.priceController.text) ?? 0,
        });
      }

      final body = {
        "vendor_id": int.parse(selectedVendor!),
        "date": DateTime.now().toString().split(' ')[0],
        "items": purchaseItems,
      };

      print("PURCHASE BODY:");
      print(jsonEncode(body));

      final response = await purchaseService.savePurchase(body);

      print("PURCHASE RESPONSE:");
      print(response);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Saved Successfully")),
      );
    } catch (e) {
      print("ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error saving purchase")));
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kCanvas,
        centerTitle: false,
        title: Text(
          "Log Purchase",
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: kPrimary),
            insets: const EdgeInsets.symmetric(horizontal: 40),
          ),
          labelColor: kPrimary,
          unselectedLabelColor: kSubtle,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: "EDITOR"),
            Tab(text: "RECENT"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEditor(), const PurchaseHistoryScreen()],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("VENDOR / SHOP"),
                _buildVendorSelector(),
                const SizedBox(height: 32),
                _label("PURCHASE ITEMS"),
                ...items.asMap().entries.map(
                  (entry) => _buildFigmaItemRow(entry.key, entry.value),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => items.add(PurchaseItem())),
                    icon: Icon(Icons.add_rounded, size: 20, color: kAccent),
                    label: Text(
                      "Add another line",
                      style: TextStyle(
                        color: kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Buffer for bottom panel
              ],
            ),
          ),
        ),
        _buildFloatingSummary(),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: kSubtle,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildVendorSelector() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),

            child: DropdownSearch<String>(
              selectedItem: selectedVendor,

              items: vendors.map<String>((v) => v['id'].toString()).toList(),

              itemAsString: (id) {
                final vendor = vendors.firstWhere(
                  (v) => v['id'].toString() == id,
                  orElse: () => {'name': ''},
                );
                return vendor['name'];
              },

              popupProps: const PopupProps.menu(showSearchBox: true),

              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: "Select supplier",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  selectedVendor = value;
                });
              },
            ),
          ),
        ),

        const SizedBox(width: 10),

        /// ADD VENDOR BUTTON
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
          onPressed: () {
            showAddVendorDialog();
          },
        ),
      ],
    );
  }

  Widget _buildFigmaItemRow(int index, PurchaseItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernDropdown(
                  hint: "Select Category",
                  value: item.categoryId,
                  items: categories.map((c) => c['id'].toString()).toList(),
                  onChanged: (val) async {
                    setState(() {
                      item.categoryId = val;
                      item.itemId = null;
                      item.variantId = null;
                    });
                    await fetchItems(val!);
                  },
                  itemLabel: (id) => categories.firstWhere(
                    (c) => c['id'].toString() == id,
                  )['name'],
                ),
              ),
              if (items.length > 1)
                IconButton(
                  onPressed: () => setState(() => items.removeAt(index)),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          if (item.categoryId != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: _buildModernDropdown(
                    hint: "Product",
                    value: item.itemId,
                    items: (itemsMap[item.categoryId] ?? [])
                        .map<String>((i) => i['id'].toString())
                        .toList(),
                    onChanged: (val) async {
                      setState(() {
                        item.itemId = val;
                        item.variantId = null;
                      });
                      await fetchVariants(val!);
                    },
                    itemLabel: (id) => (itemsMap[item.categoryId] ?? [])
                        .firstWhere((i) => i['id'].toString() == id)['name'],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModernDropdown(
                    hint: "Variant",
                    value: item.variantId,
                    items: (variantsMap[item.itemId] ?? [])
                        .map<String>((v) => v['id'].toString())
                        .toList(),
                    onChanged: (val) => setState(() => item.variantId = val),
                    itemLabel: (id) =>
                        (variantsMap[item.itemId] ?? []).firstWhere(
                          (v) => v['id'].toString() == id,
                        )['variant_name'],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: _buildInlineInput("Quantity", item.qtyController),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInlineInput("Rate/Unit", item.priceController),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "SUBTOTAL",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: kSubtle,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "₹${item.total.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kPrimary,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(indent: 40, thickness: 0.8),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String Function(String) itemLabel,
  }) {
    return DropdownSearch<String>(
      selectedItem: value,
      items: items,
      onChanged: onChanged,
      itemAsString: itemLabel,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        menuProps: const MenuProps(elevation: 4),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kSubtle.withOpacity(0.6), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kPrimary, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildInlineInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: kSubtle,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kPrimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildFloatingSummary() {
    double total = items.fold(0, (sum, item) => sum + item.total);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GRAND TOTAL",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "₹ ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 58,
              width: 150,
              child: ElevatedButton(
                onPressed: isSaving ? null : savePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: kAccent.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "CONFIRM",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
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
