import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  late final Razorpay _razorpay;
  int? _selectedPlanIndex;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
        return const Color(0xFF2196F3);
      case 'premium':
        return const Color(0xFF7C4DFF);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null
              ? _buildErrorView()
              : _buildPlansList(),
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              ...List.generate(
                  3,
                  (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200])),
                            const SizedBox(width: 8),
                            Container(
                                height: 14,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      )),
            ],
          ),
        ),
      ),
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
          ElevatedButton(onPressed: _loadPlans, child: const Text('Retry')),
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
        final isSelected = _selectedPlanIndex == index;
        return _buildPlanCard(plan, planColor, isFree, isSelected, index);
      },
    );
  }

  Widget _buildPlanCard(
      dynamic plan, Color color, bool isFree, bool isSelected, int index) {
    final price = plan['price'] as num;
    final features = plan['features'] as List<dynamic>? ?? [];
    final yearlyPrice = price * 10;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withValues(alpha: 0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: (isSelected ? color : Colors.black)
                  .withValues(alpha: isSelected ? 0.2 : 0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          plan['id'] == 'premium'
                              ? Icons.stars_rounded
                              : plan['id'] == 'basic'
                                  ? Icons.rocket_launch_rounded
                                  : Icons.person_rounded,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        plan['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (plan['id'] == 'premium')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle, color: color, size: 24),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    isFree ? 'Free' : '\u20B9$price',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isFree ? Colors.grey : color,
                    ),
                  ),
                  if (!isFree) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('/month',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '\u20B9$yearlyPrice/year',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'SAVE 17%',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFree ? Colors.grey[300] : color,
                    foregroundColor: isFree ? Colors.black54 : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isSelected ? 4 : 0,
                    shadowColor: color.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    isFree ? 'Get Started Free' : 'Subscribe Now',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(dynamic plan) async {
    if (plan['price'] == 0) {
      _showSnackBar('Free plan activated!');
      return;
    }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.local_offer_rounded,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Have a coupon?'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Coupon Code',
            hintText: 'Enter coupon code',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.discount_rounded),
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
    if (paymentLink == null) {
      _showSnackBar('Payment link not available', isError: true);
      return;
    }

    var options = {
      'external': {'url': paymentLink}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Error in opening Razorpay: $e', isError: true);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showSnackBar('Payment successful: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.code} - ${response.message}',
        isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External wallet: ${response.walletName}');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
