import 'package:flutter/material.dart';
import '../data/vendor_balance_service.dart';
import '../data/vendor_payment_service.dart';

class VendorPaymentScreen extends StatefulWidget {
  const VendorPaymentScreen({super.key});

  @override
  State<VendorPaymentScreen> createState() => _VendorPaymentScreenState();
}

class _VendorPaymentScreenState extends State<VendorPaymentScreen> {
  final VendorBalanceService _balanceService = VendorBalanceService();
  final VendorPaymentService _paymentService = VendorPaymentService();

  List vendors = [];
  String? selectedVendorId;
  String? selectedVendorName;

  final TextEditingController amountController = TextEditingController();

  bool isSubmitting = false;
  bool isLoadingVendors = true;

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadVendors() async {
    try {
      final data = await _balanceService.fetchVendors();

      setState(() {
        vendors = data;
        isLoadingVendors = false;
      });
    } catch (e) {
      setState(() => isLoadingVendors = false);

      _showFeedback("Failed to load vendors", isError: true);
    }
  }

  Future<void> submitPayment() async {
    if (selectedVendorId == null || amountController.text.isEmpty) {
      _showFeedback("Please pick vendor and enter amount", isError: true);
      return;
    }

    double? amount = double.tryParse(amountController.text);

    if (amount == null) {
      _showFeedback("Invalid amount", isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await _paymentService.addVendorPayment(
        selectedVendorId!,
        amount,
      );

      if (!mounted) return;

      _showSuccessDialog();

      amountController.clear();

      setState(() {
        selectedVendorId = null;
        selectedVendorName = null;
      });

    } catch (e) {
_showFeedback("Payment failed. Try again.", isError: true);

    } finally {

      setState(() => isSubmitting = false);

    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Money Sent!",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Successfully paid to $selectedVendorName"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Give Money to Vendor",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: isLoadingVendors
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// STEP 1
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "1",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Who are you paying?",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 10)
                      ],
                    ),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedVendorId,
                        hint:
                            const Text("Select vendor"),

                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),

                        items: vendors.map((vendor) {
                          return DropdownMenuItem<String>(
                            value: vendor['id'].toString(),

                            child: Row(
                              children: [
                                const Icon(Icons.person,
                                    color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(
                                  vendor['name'],
                                  style:
                                      const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {

                          setState(() {
selectedVendorId = value;

                            selectedVendorName =
                                vendors.firstWhere(
                              (v) =>
                                  v['id'].toString() ==
                                  value,
                            )['name'];

                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// STEP 2
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "2",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "How much money?",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 10)
                      ],
                    ),

                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),

                      decoration: InputDecoration(
                        hintText: "0.00",
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                          color: Colors.green,
                          size: 30,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets.symmetric(
                                vertical: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 65,

                    child: ElevatedButton(

                      onPressed:
                          isSubmitting ? null : submitPayment,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),

                      child: isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "FINISH PAYMENT",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "Double-check the vendor name and amount",
                      style: TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  )
                ],
              ),
          ),
);
  }
}