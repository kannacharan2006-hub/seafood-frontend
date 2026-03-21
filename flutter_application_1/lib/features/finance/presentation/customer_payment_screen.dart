import 'package:flutter/material.dart';
import '../data/payment_service.dart';
import '../data/customer_service.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  String? selectedCustomerId;
  List<dynamic> customers = [];

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      final data = await CustomerService().fetchCustomers();

      print("CUSTOMERS DATA:");
      print(data);

      setState(() {
        customers = data;

        if (customers.isNotEmpty) {
          selectedCustomerId = customers.first['id'].toString();
        }
      });
    } catch (e) {
      print("CUSTOMER ERROR: $e");
    }
  }

  Future<void> savePayment() async {
    if (selectedCustomerId == null) return;

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter amount")));
      return;
    }

    try {
      await PaymentService().recordCustomerPayment(
        selectedCustomerId!,
        amountController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Saved Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save payment")));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Payment"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// CUSTOMER DROPDOWN
            DropdownButtonFormField<String>(
              initialValue: customers.isEmpty ? null : selectedCustomerId,

              decoration: const InputDecoration(
                labelText: "Select Customer",
                border: OutlineInputBorder(),
              ),

              items: customers.map<DropdownMenuItem<String>>((customer) {
                return DropdownMenuItem(
                  value: customer['id'].toString(),
                  child: Text(customer['name']),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCustomerId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Payment Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            /// NOTE
            TextField(
              controller: noteController,

              decoration: const InputDecoration(
                labelText: "Note (Optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: savePayment,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                child: const Text(
                  "Save Payment",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
