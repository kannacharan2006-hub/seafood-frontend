import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../data/subscription_service.dart';
import 'plans_screen.dart';
import 'referral_screen.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _subscription;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCancelling = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final status = await SubscriptionService.getSubscriptionStatus();
      if (!mounted) return;
      setState(() {
        _subscription = status;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Cancel Subscription'),
          ],
        ),
        content: const Text(
          'Your subscription will remain active until the current billing period ends. You will not be charged again. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Plan'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Anyway',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      await SubscriptionService.cancelSubscription();
      _showSnackBar('Subscription cancelled successfully');
      _loadStatus();
    } catch (e) {
      _showSnackBar('Failed to cancel: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Status'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStatus,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatus,
        child: _isLoading
            ? _buildShimmerLoading()
            : _errorMessage != null
                ? _buildErrorView()
                : _buildStatusView(),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                  3,
                  (_) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusView() {
    final planId = _subscription?['plan_id']?.toString() ?? 'free';
    final status = _subscription?['status']?.toString() ?? 'inactive';
    final periodStart = _subscription?['current_period_start'];
    final periodEnd = _subscription?['current_period_end'];
    final now = DateTime.now();

    DateTime? startDt;
    DateTime? endDt;
    if (periodStart is String) startDt = DateTime.tryParse(periodStart);
    if (periodEnd is String) endDt = DateTime.tryParse(periodEnd);

    int daysRemaining = 0;
    int totalDays = 30;
    double progress = 0.0;

    if (startDt != null && endDt != null) {
      totalDays = endDt.difference(startDt).inDays;
      final daysElapsed = now.difference(startDt).inDays;
      daysRemaining = endDt.difference(now).inDays;
      if (daysRemaining < 0) daysRemaining = 0;
      progress = (daysElapsed / totalDays).clamp(0.0, 1.0);
    }

    final isActive = status.toLowerCase() == 'active';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(planId, status, isActive),
        const SizedBox(height: 16),
        if (isActive)
          _buildProgressCard(daysRemaining, totalDays, progress, endDt),
        if (isActive) const SizedBox(height: 16),
        _buildPlanInfoCard(planId, status),
        const SizedBox(height: 16),
        _buildActionCards(isActive),
        const SizedBox(height: 16),
        _buildNavigationCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeaderCard(String planId, String status, bool isActive) {
    final Color statusColor = isActive ? Colors.green : Colors.orange;
    final String statusLabel = isActive ? 'Active' : 'Inactive';
    final IconData statusIcon =
        isActive ? Icons.check_circle : Icons.pause_circle;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
                : [const Color(0xFF757575), const Color(0xFF9E9E9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Plan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(
                                    alpha: 0.3 * _pulseAnimation.value),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon,
                            size: 18,
                            color: statusColor,
                            grade: isActive ? 200 : 0),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    planId == 'premium'
                        ? Icons.stars_rounded
                        : planId == 'basic'
                            ? Icons.rocket_launch_rounded
                            : Icons.person_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  planId.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return DateFormat('MMM dd, yyyy').format(parsed);
      } catch (_) {
        return date.toString();
      }
    }
    if (date is DateTime) {
      return DateFormat('MMM dd, yyyy').format(date);
    }
    return date.toString();
  }

  Widget _buildProgressCard(
      int daysRemaining, int totalDays, double progress, DateTime? endDt) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Billing Cycle Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$daysRemaining/$totalDays days',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started ${_formatDate(_subscription?['current_period_start'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Ends ${_formatDate(_subscription?['current_period_end'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (endDt != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.autorenew_rounded,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Auto-renewal enabled. Next payment: ${DateFormat('MMM dd, yyyy').format(endDt)}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 18),
                    onPressed: () {},
                    tooltip: 'Manage auto-renewal',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfoCard(String planId, String status) {
    final features = planId == 'premium'
        ? [
            'Unlimited purchases',
            'Unlimited sales',
            'Advanced analytics',
            'Export reports',
            'Priority support',
            'Multi-user access'
          ]
        : [
            'Up to 100 purchases',
            'Up to 100 sales',
            'Basic analytics',
            'Export reports',
            'Email support',
            'Single user'
          ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt_rounded,
                    size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Plan Features',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  status.toLowerCase() == 'active' ? 'Included' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 12,
                    color: status.toLowerCase() == 'active'
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        status.toLowerCase() == 'active'
                            ? Icons.check_circle_rounded
                            : Icons.remove_circle_outline_rounded,
                        size: 18,
                        color: status.toLowerCase() == 'active'
                            ? Colors.green
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: TextStyle(
                          fontSize: 14,
                          color: status.toLowerCase() == 'active'
                              ? Colors.grey[800]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(bool isActive) {
    return Column(
      children: [
        if (isActive)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCancelling ? null : _cancelSubscription,
              icon: _isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cancel_outlined, color: Colors.red),
              label: Text(
                _isCancelling ? 'Cancelling...' : 'Cancel Subscription',
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlansScreen()),
                  ).then((_) => _loadStatus());
                },
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Change Plan'),
              ),
            ),
            Container(height: 30, width: 1, color: Colors.grey[300]),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReferralScreen()),
                  );
                },
                icon: const Icon(Icons.card_giftcard_rounded),
                label: const Text('Referral'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
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
