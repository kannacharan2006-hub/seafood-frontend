import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/secure_storage.dart';

class AppLocalizations {
  static const String _storageKey = 'app_language';
  static Locale _currentLocale = const Locale('en');

  static Map<String, String> _strings = {};
  static final _changeNotifier = ValueNotifier<Locale>(const Locale('en'));

  static Locale get currentLocale => _currentLocale;
  static ValueNotifier<Locale> get changeNotifier => _changeNotifier;

  static Future<void> init() async {
    final savedLang = await SecureStorage.getData(_storageKey);
    if (savedLang != null) {
      await loadLanguage(savedLang);
    }
  }

  static Future<void> loadLanguage(String langCode) async {
    try {
      String jsonString;
      switch (langCode) {
        case 'ta':
          jsonString = _taStrings;
          break;
        case 'te':
          jsonString = _teStrings;
          break;
        default:
          jsonString = _enStrings;
      }
      _strings = Map<String, String>.from(jsonDecode(jsonString));
      _currentLocale = Locale(langCode);
      _changeNotifier.value = _currentLocale;
    } catch (e) {
      _strings = {};
    }
  }

  static Future<void> setLanguage(String langCode) async {
    await loadLanguage(langCode);
    await SecureStorage.saveData(_storageKey, langCode);
  }

  static String get(String key) {
    return _strings[key] ?? key;
  }

  static String get appName => _strings['appName'] ?? 'OceanSync';
  static String get dashboard => _strings['dashboard'] ?? 'Dashboard';
  static String get purchase => _strings['purchase'] ?? 'Purchase';
  static String get reGrading => _strings['reGrading'] ?? 'Re-grading';
  static String get sales => _strings['sales'] ?? 'Sales';
  static String get reports => _strings['reports'] ?? 'Reports';
  static String get settings => _strings['settings'] ?? 'Settings';
  static String get language => _strings['language'] ?? 'Language';
  static String get english => _strings['english'] ?? 'English';
  static String get tamil => _strings['tamil'] ?? 'Tamil';
  static String get telugu => _strings['telugu'] ?? 'Telugu';
  static String get login => _strings['login'] ?? 'Login';
  static String get logout => _strings['logout'] ?? 'Logout';
  static String get logoutMessage => _strings['logoutMessage'] ?? 'Logout?';
  static String get confirmLogout =>
      _strings['confirmLogout'] ?? 'Confirm Logout';
  static String get loading => _strings['loading'] ?? 'Loading...';
  static String get noData => _strings['noData'] ?? 'No data';
  static String get success => _strings['success'] ?? 'Success';
  static String get customers => _strings['customers'] ?? 'Customers';
  static String get vendors => _strings['vendors'] ?? 'Vendors';
  static String get stock => _strings['stock'] ?? 'Stock';
  static String get employee => _strings['employee'] ?? 'Employee';
  static String get totalSales => _strings['totalSales'] ?? 'Total Sales';
  static String get profit => _strings['profit'] ?? 'Profit';

  static const String _enStrings = '''
{
  "appName": "OceanSync",
  "dashboard": "Dashboard",
  "purchase": "Purchase",
  "reGrading": "Re-grading",
  "sales": "Sales",
  "reports": "Reports",
  "customers": "Customers",
  "vendors": "Vendors",
  "stock": "Stock",
  "employee": "Employee",
  "settings": "Settings",
  "language": "Language",
  "login": "Login",
  "logout": "Logout",
  "logoutMessage": "Are you sure you want to logout?",
  "confirmLogout": "Confirm Logout",
  "loading": "Loading...",
  "noData": "No data available",
  "success": "Success",
  "english": "English",
  "tamil": "Tamil",
  "telugu": "Telugu",
  "totalSales": "Total Sales",
  "profit": "Profit"
}
''';

  static const String _taStrings = '''
{
  "appName": "ஓஷன் சிங்க்",
  "dashboard": "டாஷ்போர்டு",
  "purchase": "கொள்முதல்",
  "reGrading": "ரீ-கிரேடிங்",
  "sales": "சேல்ஸ்",
  "reports": "ரிப்போர்ட்ஸ்",
  "customers": "வாடிக்கையாளர்கள்",
  "vendors": "சப்ளையர்கள்",
  "stock": "சரக்கு கையிருப்பு",
  "employee": "பணியாளர்",
  "settings": "அமைப்புகள்",
  "language": "மொழி",
  "login": "உள்நுழை",
  "logout": "வெளியேறு",
  "logoutMessage": "நீங்கள் வெளியேற விரும்புகிறீர்களா?",
  "confirmLogout": "வெளியேறுதலை உறுதிப்படுத்து",
  "loading": "ஏற்றப்படுகிறது...",
  "noData": "தரவு கிடைக்கவில்லை",
  "success": "வெற்றி",
  "english": "ஆங்கிலம்",
  "tamil": "தமிழ்",
  "telugu": "தெலுப்பு",
  "totalSales": "டோட்டல் சேல்ஸ்",
  "profit": "லாபம்"
}
''';

  static const String _teStrings = '''
{
  "appName": "ఓషన్‌సింక్",
  "dashboard": "డాష్‌బోర్డ్",
  "purchase": "కొనుగోలు",
  "reGrading": "రీ-ग्रेडिंग్",
  "sales": "Sales",
  "reports": "रिपोर्ट్స్",
  "customers": "कस्टमर्तlు",
  "vendors": "रैతు/सरफरादारులు",
  "stock": "सरुकు निल्ध",
  "employee": "उद्योgि",
  "settings": "सет्टिंग्स्",
  "language": "भाष",
  "login": "लॉगिन्",
  "logout": "लॉगॆट्",
  "logoutMessage": "Logout?",
  "confirmLogout": "Confirm",
  "loading": "लोड् अवुतोन्दि...",
  "noData": "डेटा अन्दर्बातलो लेदु",
  "success": "Success",
  "english": "English",
  "tamil": "Tamil",
  "telugu": "Telugu",
  "totalSales": "टोटल् सोल्स्",
  "profit": "लाभम"
}
''';
}
