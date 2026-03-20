import 'package:flutter/material.dart';
import '../../conversion/data/conversion_service.dart';
import 'conversion_details_screen.dart';
import 'package:intl/intl.dart';

class ConversionHistoryScreen extends StatefulWidget {
 const ConversionHistoryScreen({super.key});

  @override
  State<ConversionHistoryScreen> createState() => _ConversionHistoryScreenState();
}

class _ConversionHistoryScreenState extends State<ConversionHistoryScreen> {
  final ConversionService _service = ConversionService();
  List conversions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await _service.getConversions();
      setState(() {
        conversions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // A safer way to delete so village people don't make mistakes
  Future<void> _confirmDelete(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Record?"),
        content: const Text("Are you sure you want to delete this grade change record? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO, KEEP IT")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("YES, DELETE", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);
      await _service.deleteConversion(id);
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text("Past Grade Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: conversions.length,
                  itemBuilder: (context, index) {
                    final conv = conversions[index];
                    String formattedDate = "Unknown Date";
                    if (conv['date'] != null) {
                      DateTime parsedDate = DateTime.parse(conv['date']);
                      formattedDate = DateFormat('dd MMMM yyyy').format(parsedDate);
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: const Icon(Icons.sync_alt, color: Colors.teal),
                        ),
                        title: Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Staff: ${conv['created_by'] ?? 'Unknown'}", 
                                   style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text("Tap to see details", style: TextStyle(fontSize: 12, color: Colors.teal)),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversionDetailsScreen(conversion: conv),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(conv['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("No records found yet.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}