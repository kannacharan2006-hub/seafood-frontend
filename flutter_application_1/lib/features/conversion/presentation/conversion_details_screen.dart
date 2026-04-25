import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversionDetailsScreen extends StatelessWidget {
  final Map conversion;

  const ConversionDetailsScreen({super.key, required this.conversion});

  @override
  Widget build(BuildContext context) {
    final rawItems = conversion['raw_items'] ?? [];
    final finalItems = conversion['final_items'] ?? [];

    String formattedDate = "Unknown Date";
    final dateStr = conversion['created_at'] ?? conversion['date'];
    if (dateStr != null) {
      DateTime parsedDate = DateTime.parse(dateStr.toString());
      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text("Stock Change Details"),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card: Who and When
            _buildInfoCard(formattedDate),

            const SizedBox(height: 24),

            // SECTION 1: Items Taken Out (RAW)
            _buildSectionHeader(
              title: "Items Used / Taken Out",
              icon: Icons.remove_circle_outline,
              color: Colors.orange.shade800,
            ),
            _buildItemsList(rawItems, isRaw: true),

            const SizedBox(height: 15),
            const Center(
                child:
                    Icon(Icons.arrow_downward, color: Colors.grey, size: 30)),
            const SizedBox(height: 15),

            // SECTION 2: Items Produced (FINAL)
            _buildSectionHeader(
              title: "New Items Produced",
              icon: Icons.add_circle_outline,
              color: Colors.green.shade700,
            ),
            _buildItemsList(finalItems, isRaw: false),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
              const SizedBox(width: 10),
              Text(date,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 25),
          Text("Performed by: ${conversion['created_by'] ?? 'Unknown Staff'}",
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Notes: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  conversion['notes'] == null ||
                          conversion['notes'].toString().isEmpty
                      ? "No notes added"
                      : conversion['notes'],
                  style: TextStyle(
                      color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List items, {required bool isRaw}) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Text("No items listed"),
      );
    }

    return Column(
      children: items.map<Widget>((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(
              item['variant_name'] ?? 'Unknown Item',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRaw ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Qty: ${item['quantity']}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isRaw ? Colors.orange.shade900 : Colors.green.shade900),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
