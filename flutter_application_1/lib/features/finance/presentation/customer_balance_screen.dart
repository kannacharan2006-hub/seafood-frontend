import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/customer_service.dart';
import '../data/customer_balance_service.dart';
import '../data/payment_service.dart';

class CustomerBalanceScreen extends StatefulWidget {
  const CustomerBalanceScreen({super.key});

  @override
  State<CustomerBalanceScreen> createState() => _CustomerBalanceScreenState();
}

class _CustomerBalanceScreenState extends State<CustomerBalanceScreen> {

  Future<Map<String, dynamic>>? futureBalance;
  String selectedCustomerId = "";
  List<dynamic> customers = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  void loadBalance() {
    if (selectedCustomerId.isNotEmpty) {
      setState(() {
        futureBalance = CustomerBalanceService()
            .fetchCustomerBalance(selectedCustomerId);
      });
    }
  }

  void recordPaymentDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        title: const Text("Receive Money"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the amount received from customer:"),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: "₹ ",
                labelText: "Amount",
                border: OutlineInputBorder(),
                hintText: "0.00",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (amountController.text.isEmpty) return;

              await PaymentService().recordCustomerPayment(
                selectedCustomerId,
                amountController.text,
              );
if (mounted) {
                Navigator.pop(context);
                loadBalance();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Payment Saved Successfully")),
                );
              }
            },
            child: const Text("SAVE PAYMENT"),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCustomers() async {
    try {
        final data = await CustomerService().fetchCustomers();
      if (!mounted) return;
      if (data.isNotEmpty) {
        setState(() {
          customers = data;
          selectedCustomerId = data[0]['id'].toString();
          loadBalance();
        });
      }
    } catch (e) {
      debugPrint("Error fetching customers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),

      appBar: AppBar(
        title: const Text("Customer Khata"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<String>(
              initialValue: customers.isEmpty ? null : selectedCustomerId,
              decoration: InputDecoration(
                labelText: "Select Customer Name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              items: customers.map<DropdownMenuItem<String>>((customer) {
                return DropdownMenuItem<String>(
                  value: customer['id'].toString(),
                  child: Text(customer['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCustomerId = value!;
                  loadBalance();
                });
              },
            ),
          ),
/// BALANCE SECTION
          Expanded(
            child: futureBalance == null
                ? const Center(
                    child: Text("Please select a customer"))
                : FutureBuilder<Map<String, dynamic>>(
                    future: futureBalance,
                    builder: (context, snapshot) {

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                            child: Text("Unable to load balance"));
                      }

                      final data = snapshot.data!;
                      final double balance =
                          (data["balance"] as num).toDouble();

                      Color statusColor = Colors.red;
                      String statusText = "DUE PAYMENT";
                      IconData statusIcon = Icons.warning;

                      if (balance == 0) {
                        statusColor = Colors.green;
                        statusText = "ALL CLEAR";
                        statusIcon = Icons.check_circle;
                      } else if (balance < 0) {
                        statusColor = Colors.blue;
                        statusText = "ADVANCE";
                        statusIcon = Icons.stars;
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [

                          /// STATUS CARD
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Icon(statusIcon,
                                    color: Colors.white, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  statusText,
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                Text(
                                  "₹ ${balance.abs().toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryBox(
                                    "Total Bill",
                                    data["totalSales"].toString(),
                                    Colors.black,
                                    Icons.receipt_long),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryBox(
                                    "Total Paid",
                                    data["totalPaid"].toString(),
                                    Colors.green,
                                    Icons.payments),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "LAST PAYMENTS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          const Divider(),

                         FutureBuilder<List<dynamic>>(
                            future: PaymentService()
                                .fetchCustomerPaymentHistory(
                                    selectedCustomerId),
                            builder: (context, historySnapshot) {

                              if (!historySnapshot.hasData ||
                                  historySnapshot.data!.isEmpty) {
                                return const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                      child: Text(
                                          "No payments recorded yet.")),
                                );
                              }

                              final payments =
                                  historySnapshot.data!;

                              return Column(
                                children: payments.map((p) {
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green),
                                      title: Text("₹ ${p["amount"]}"),
                                      subtitle: Text(formatDate(
                                          p["date"]?.toString())),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 80),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: recordPaymentDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("RECORD PAYMENT"),
      ),
    );
  }

  Widget _buildSummaryBox(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 8),
          Text(title),
          Text(
            "₹ $amount",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}