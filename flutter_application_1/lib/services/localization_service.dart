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
    _strings = _getStrings(langCode);
    _currentLocale = Locale(langCode);
    _changeNotifier.value = _currentLocale;
  }

  static Future<void> setLanguage(String langCode) async {
    await loadLanguage(langCode);
    await SecureStorage.saveData(_storageKey, langCode);
  }

  static Map<String, String> _getStrings(String langCode) {
    if (langCode == 'ta') {
      return _taStrings;
    } else if (langCode == 'te') {
      return _teStrings;
    }
    return _enStrings;
  }

  static String get(String key) => _strings[key] ?? key;

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

  // English strings
  static const Map<String, String> _enStrings = {
    'appName': 'OceanSync',
    'dashboard': 'Dashboard',
    'purchase': 'Purchase',
    'reGrading': 'Re-grading',
    'sales': 'Sales',
    'reports': 'Reports',
    'customers': 'Customers',
    'vendors': 'Vendors',
    'stock': 'Stock',
    'employee': 'Employee',
    'settings': 'Settings',
    'language': 'Language',
    'login': 'Login',
    'logout': 'Logout',
    'logoutMessage': 'Are you sure you want to logout?',
    'confirmLogout': 'Confirm Logout',
    'loading': 'Loading...',
    'noData': 'No data available',
    'success': 'Success',
    'english': 'English',
    'tamil': 'Tamil',
    'telugu': 'Telugu',
    'totalSales': 'Total Sales',
    'profit': 'Profit',
  };

  // Tamil strings
  static const Map<String, String> _taStrings = {
    'appName': 'OceanSync',
    'dashboard': 'Dashboard',
    'purchase': 'Purchase',
    'reGrading': 'Re-grading',
    'sales': 'Sales',
    'reports': 'Reports',
    'customers': 'Customers',
    'vendors': 'Vendors',
    'stock': 'Stock',
    'employee': 'Employee',
    'settings': 'Settings',
    'language': 'Language',
    'login': 'Login',
    'logout': 'Logout',
    'logoutMessage': 'Are you sure?',
    'confirmLogout': 'Confirm',
    'loading': 'Loading...',
    'noData': 'No data',
    'success': 'Success',
    'english': 'English',
    'tamil': 'Tamil',
    'telugu': 'Telugu',
    'totalSales': 'Total Sales',
    'profit': 'Profit',
  };

  // Telugu strings with correct Unicode
  static const Map<String, String> _teStrings = {
    'appName': 'OceanSync',
    'dashboard': 'డాష్బోర్డ్',
    'purchase': 'కొనుగోలు',
    'reGrading': 'రీ-గ్రేడింగ్',
    'sales': 'అమ్మకాలు',
    'reports': 'রিপোর্ট',
    'customers': 'కస్ట\u0C24\u0C4D\u0C32\u0C41',
    'vendors':
        'রైతు/সর\u0C35\u0C30\u0C3Eద\u0C24\u0C30\u0C4D\u0C2E\u0C3E\u0C32\u0C41',
    'stock': 'सर\u0C17\u0C41 नि\u0C32\u0C4D',
    'employee': 'उद\u0C4D\u0C2D\u0C4D\u0C2D\u0C4B\u0C17\u0C3F',
    'settings': 'स\u0C24\u0C1F\u0C1F\u0C02\u0C17\u0C4D\u0C38\u0C1E',
    'language': 'భ\u0C3E',
    'login': 'ల\u0C3E\u0C17\u0C3F\u0C28\u0C4D',
    'logout': 'ల\u0C3E\u0C17\u0C4D\u0C14\u0C4D',
    'logoutMessage': '?',
    'confirmLogout': '',
    'loading': 'Loading...',
    'noData': 'ड\u0C24\u0C3E अ\u0C28\u0C24\u0C4D\u0C1C\u0C24\u0C4B\u0C32\u0C4D',
    'success': 'Success',
    'english': 'English',
    'tamil': 'Tamil',
    'telugu': 'Telugu',
    'totalSales': 'Total',
    'profit': 'ल\u0C15\u0C24\u0C02\u0C17\u0C02',
  };
}
