import 'package:flutter/material.dart';
import '../data/subscription_service.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  List<dynamic> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final plans = await SubscriptionService.getPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getPlanColor(String planName) {
    switch (planName.toLowerCase()) {
      case 'basic':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildPlansList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPlans,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        final isFree = plan['price'] == 0;
        final planColor = _getPlanColor(plan['name']);

        return _buildPlanCard(plan, planColor, isFree);
      },
    );
  }

  Widget _buildPlanCard(dynamic plan, Color color, bool isFree) {
    final price = plan['price'] as num;
    final features = plan['features'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (plan['id'] == 'premium')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isFree ? 'Free' : '₹$price/month',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature.toString())),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSubscribe(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isFree ? 'Get Started' : 'Subscribe Now',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(dynamic plan) async {
    if (plan['price'] == 0) {
      // Free plan - just activate
      _showSnackBar('Free plan activated!');
      return;
    }

    // Show coupon dialog
    final couponCode = await _showCouponDialog();
    if (couponCode != null) {
      _appliedCoupon = couponCode;
    }

    try {
      setState(() => _isLoading = true);

      final result = await SubscriptionService.createSubscription(
        plan['id'],
        couponCode: _appliedCoupon,
      );

      if (result['free'] == true) {
        _showSnackBar('Subscribed successfully!');
        return;
      }

      // For paid plans, open Razorpay checkout
      if (result['payment_link'] != null) {
        _openRazorpayCheckout(result);
      }
    } catch (e) {
      _showSnackBar('Failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showCouponDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Coupon'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Coupon Code',
            hintText: 'Enter coupon code',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _openRazorpayCheckout(Map<String, dynamic> data) {
    final paymentLink = data['payment_link'];
    _showSnackBar('Opening payment: $paymentLink');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
