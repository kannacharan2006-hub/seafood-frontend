import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../conversion/data/conversion_service.dart';
import '../../purchase/data/purchase_service.dart';
import '../presentation/conversion_history_screen.dart';

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
  List<ConversionItem> rawItems = [ConversionItem()];
  List<ConversionItem> finalItems = [ConversionItem()];
  TextEditingController notesController = TextEditingController();

  bool isSaving = false;
  bool isLoadingVariants = true;

  @override
  void initState() {
    super.initState();
    loadVariants();
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
                    buttonText: "+ Add More Old Items",
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
                      onPressed: isSaving ? null : _handleSave,
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Column(
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            ConversionItem item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownSearch<String>(
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
                      onChanged: (val) => setState(() => item.variantId = val),
                      popupProps: const PopupProps.menu(showSearchBox: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: item.qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Kg",
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
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => items.add(ConversionItem())),
            icon: const Icon(Icons.add),
            label: Text(buttonText),
          ),
        ],
      ),
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
