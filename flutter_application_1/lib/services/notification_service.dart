import 'dart:math';
import 'package:flutter/material.dart';

class NotificationService {
  static final List<String> _morningNotifications = [
    "Good morning! Yesterday's profit report is ready 📊",
    "Your daily business summary is waiting for you 📈",
    "Mistakes are proof that you are trying. Keep going! 💪",
    "Success is the sum of small efforts repeated day in and day out 🔥",
    "Don't watch the clock; do what it does. Keep going ⏰",
    "The secret of getting ahead is getting started 🚀",
    "Your stock levels are updated — review them today ✅",
  ];

  static final List<String> _eveningNotifications = [
    "Great work today! Check your daily results 📊",
    "Your business reports are ready for review 📈",
    "Success is not final, failure is not fatal. It's the courage to continue that counts ✨",
    "The harder you work, the luckier you get 🎯",
    "Take time to review today's numbers — knowledge is power 💡",
    "Stock updates are live — see what's moving 📦",
  ];

  static final Random _random = Random();
  static int _weeklyShowCount = 0;
  static String _lastWeek = '';

  static Future<void> showDailyNotification(BuildContext context,
      {String? userName}) async {
    final now = DateTime.now();
    final weekNum = (now.day / 7).ceil();
    final currentWeek = '${now.year}-W$weekNum';

    if (_lastWeek != currentWeek) {
      _weeklyShowCount = 0;
      _lastWeek = currentWeek;
    }

    if (_weeklyShowCount >= 3) {
      return;
    }

    _weeklyShowCount++;

    final notifications =
        now.hour < 14 ? _morningNotifications : _eveningNotifications;

    final shuffled = List<String>.from(notifications)..shuffle(_random);
    final selectedNotifications = shuffled.take(1).toList();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        _showSnackBar(context, selectedNotifications[0]);
      }
    });
  }

  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
