import 'package:flutter/material.dart';
import '../models/subscription_exception.dart';
import 'plans_screen.dart';
import 'subscription_status_screen.dart';

class SubscriptionExpiredOverlay extends StatelessWidget {
  final SubscriptionExpiredException error;
  final VoidCallback? onDismiss;

  const SubscriptionExpiredOverlay({
    super.key,
    required this.error,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required SubscriptionExpiredException error,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionExpiredOverlay(error: error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  _buildMessage(context),
                  const SizedBox(height: 24),
                  _buildPlansSection(context),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.lock_rounded, color: Colors.red, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            error.planName ?? 'Subscription',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error.message,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(BuildContext context) {
    if (error.plans.isEmpty) {
      return const Center(
        child: Text('No plans available', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a plan to continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
        ...error.plans.map((plan) => _buildPlanCard(context, plan)),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, dynamic plan) {
    final price = plan['price'] as num? ?? 0;
    final name = plan['name']?.toString() ?? 'Plan';
    final period = plan['period']?.toString() ?? '';
    final description = plan['description']?.toString() ?? '';

    final Color schemeColor;
    switch (plan['id']?.toString() ?? '') {
      case 'basic_monthly':
      case 'basic_quarterly':
        schemeColor = const Color(0xFF2196F3);
        break;
      case 'premium_yearly':
        schemeColor = const Color(0xFF7C4DFF);
        break;
      default:
        schemeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withAlpha(40)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PlansScreen(initialPlanId: plan['id']?.toString()),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: schemeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    name.toLowerCase().contains('premium')
                        ? Icons.stars_rounded
                        : Icons.rocket_launch_rounded,
                    color: schemeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        child: Text(
                          '\u20B9${price.toInt()}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: schemeColor,
                          ),
                        ),
                      ),
                      Text(
                        period == 'monthly'
                            ? '/mo'
                            : period == 'quarterly'
                                ? '/qtr'
                                : '/yr',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionStatusScreen(),
                ),
              );
            },
            icon: const Icon(Icons.subscriptions_rounded, size: 20),
            label: const Text(
              'View Subscription Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: const Text(
            'Dismiss',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
