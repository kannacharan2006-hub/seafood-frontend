import 'dart:math';
import 'package:flutter/material.dart';

class NotificationService {
  static final List<String> _morningNotifications = [
    "!, అన్నా, నిన్నటి లాభం చూసారా? 📊",
    "!, నిన్నటి రిపోర్ట్ రెడీ ఉంది 📊",
    "!, నిన్నటి లెక్కలు క్లియర్ అయ్యాయా? 🤔",
    "!, నిన్నటి డేటా మీ కోసం సిద్ధంగా ఉంది 📈",
    "!, నిన్నటి డేటా ఒక్కసారి చెక్ చేయండి 🔍",
    "!, మీ లెక్కలు మీ కోసం వేచి ఉన్నాయి 📱",
    "!, నిన్న ఎంత లాభం వచ్చిందో తెలుసా? 💸",
  ];

  static final List<String> _eveningNotifications = [
    "!, మీ రోజు బిజినెస్ ఫలితం చూడండి 📊",
    "!, మీ లెక్కలు మీ కోసం సిద్ధంగా ఉన్నాయి 📈",
    "!, మీ స్నేహితులతో షేర్ చేయండి 👍",
    "!, ఈరోజు స్టాక్ ఎంత మిగిలిందో చూడండి 📦",
  ];

  static final Random _random = Random();
  static int _weeklyShowCount = 0;
  static String _lastWeek = '';

  static Future<void> showDailyNotification(BuildContext context) async {
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
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
