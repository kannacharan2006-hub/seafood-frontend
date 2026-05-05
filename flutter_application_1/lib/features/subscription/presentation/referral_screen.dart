import 'package:flutter/material.dart';
import '../data/subscription_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    } catch (e) {
      setState(() {
        _message = e.toString();
        _isSuccess = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apply Referral Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a referral code to get credits or discounts on your subscription.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Referral Code',
                        hintText: 'Enter code (e.g., ABC123)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_giftcard),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _applyReferral(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _applyReferral,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Apply Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error_outline,
                        color: _isSuccess ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _isSuccess
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'How it works:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoTile(
              Icons.people,
              'Share your referral code',
              'Invite friends to join Seafood ERP',
            ),
            _buildInfoTile(
              Icons.star,
              'Earn rewards',
              'Get credits when they subscribe',
            ),
            _buildInfoTile(
              Icons.subscriptions,
              'Use credits',
              'Apply credits to future subscriptions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
