import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../data/subscription_service.dart';
import 'package:shimmer/shimmer.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _isPageLoading = true;
  String? _myReferralCode;
  int _myCredits = 0;
  String? _referralError;
  bool _isCopied = false;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _loadReferralInfo();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralInfo() async {
    try {
      setState(() {
        _isPageLoading = true;
        _referralError = null;
      });
      final info = await SubscriptionService.getReferralInfo();
      if (!mounted) return;
      setState(() {
        _myReferralCode = info['referralCode']?.toString();
        _myCredits = (info['credits'] ?? 0) as int;
        _isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _referralError = e.toString();
        _isPageLoading = false;
      });
    }
  }

  Future<void> _applyReferral() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      _showMessage('Please enter a referral code', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await SubscriptionService.applyReferralCode(code);
      setState(() {
        _isSuccess = true;
        _message = 'Referral applied successfully!';
      });
      _celebrationController.forward();
      HapticFeedback.mediumImpact();
      _controller.clear();
      _loadReferralInfo();
    } catch (e) {
      setState(() {
        _message = e.toString();
        _isSuccess = false;
      });
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyReferralCode() {
    if (_myReferralCode == null) return;
    Clipboard.setData(ClipboardData(text: _myReferralCode!));
    HapticFeedback.lightImpact();
    setState(() => _isCopied = true);
    _showMessage('Referral code copied!');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _shareReferralCode() {
    if (_myReferralCode == null) return;
    HapticFeedback.lightImpact();
    Share.share(
      'Join me on OceanSync - Seafood Trading ERP!\n\n'
      'Referral Code: $_myReferralCode\n\n'
      'With OceanSync, you can manage:\n'
      '\u2022 Fish purchases & sales\n'
      '\u2022 Inventory & stock tracking\n'
      '\u2022 Export management\n'
      '\u2022 Business analytics\n\n'
      'Download the app and use my code to get started!',
      subject: 'Join me on OceanSync!',
    );
  }

  void _showMessage(String message, {bool isError = false}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Program'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadReferralInfo,
            child: _isPageLoading
                ? _buildShimmerLoading()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_referralError != null && _myReferralCode == null)
                          _buildErrorCard(),
                        if (_myReferralCode != null) ...[
                          _buildReferralCodeCard(),
                          const SizedBox(height: 16),
                          _buildStatsCard(),
                        ],
                        const SizedBox(height: 20),
                        _buildApplyCard(),
                        if (_message != null && !_isSuccess) ...[
                          const SizedBox(height: 12),
                          _buildMessageCard(),
                        ],
                        const SizedBox(height: 20),
                        _buildHowItWorks(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
          if (_isSuccess && _celebrationController.isAnimating)
            _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) => IgnorePointer(
        child: Container(
          color:
              Colors.black.withValues(alpha: 0.3 * _celebrationAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _celebrationAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Referral Applied!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You earned referral credits.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              _referralError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadReferralInfo,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard_rounded,
                    color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Your Referral Code',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Container(
                key: ValueKey(_isCopied),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCopied
                        ? Colors.greenAccent.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isCopied ? 'Copied!' : _myReferralCode!,
                      style: TextStyle(
                        color: _isCopied ? Colors.greenAccent : Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: _isCopied ? 2 : 4,
                      ),
                    ),
                    if (_isCopied) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_rounded,
                          color: Colors.greenAccent, size: 24),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                  icon: _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                  label: _isCopied ? 'Copied' : 'Copy',
                  onTap: _copyReferralCode,
                ),
                const SizedBox(width: 24),
                _buildIconButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _shareReferralCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: Colors.amber, size: 28),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: _myCredits),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) => Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Credits Earned',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                const Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.people_rounded, color: Colors.blue, size: 28),
                      SizedBox(height: 8),
                      Text(
                        '--',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'People Referred',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_myCredits > 0) ...[
              const SizedBox(height: 14),
              _buildRewardProgress(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardProgress() {
    const milestone = 100;
    final progress = (_myCredits / milestone).clamp(0.0, 1.0);
    final remaining = milestone - (_myCredits % milestone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '$remaining credits until 1 month free!',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.amber.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyCard() {
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
                Icon(Icons.local_offer_rounded,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Apply Referral Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter a referral code to earn credits and discounts.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Referral Code',
                hintText: 'Enter code (e.g., ABC123)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.card_giftcard),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _applyReferral(),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyReferral,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Apply Code', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _isSuccess ? Icons.check_circle : Icons.error_outline,
              color: _isSuccess ? Colors.green : Colors.red,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _message!,
                style: TextStyle(
                  color:
                      _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      {
        'icon': Icons.share_rounded,
        'title': 'Share Your Code',
        'desc': 'Share your unique referral code with friends and colleagues.',
        'color': const Color(0xFF7C4DFF),
      },
      {
        'icon': Icons.person_add_rounded,
        'title': 'They Sign Up',
        'desc': 'Your friends sign up for OceanSync using your referral code.',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.monetization_on_rounded,
        'title': 'Earn Credits',
        'desc': 'Earn credits when they subscribe to a paid plan.',
        'color': const Color(0xFF43A047),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.help_outline_rounded, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'How It Works',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (step['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: step['color'] as Color,
                        size: 20,
                      ),
                    ),
                    if (idx < steps.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step['desc'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
