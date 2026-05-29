import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_1/services/secure_storage.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/services/websocket_provider.dart';
import 'package:flutter_application_1/main.dart' show themeController;

import 'package:flutter_application_1/features/auth/presentation/login_screen.dart';
import 'package:flutter_application_1/features/auth/presentation/dashboard_screen.dart';

import 'package:flutter_application_1/features/auth/presentation/reports_screen.dart';

import 'package:flutter_application_1/features/purchase/presentation/purchase_screen.dart';
import 'package:flutter_application_1/features/export/presentation/export_screen.dart';
import 'package:flutter_application_1/features/conversion/presentation/conversion_screen.dart';

import 'package:flutter_application_1/features/finance/presentation/customer_payment_screen.dart';
import 'package:flutter_application_1/features/finance/presentation/customer_balance_screen.dart';
import 'package:flutter_application_1/features/finance/presentation/vendor_balance_screen.dart';
import 'package:flutter_application_1/features/finance/presentation/vendor_payment_screen.dart';

import 'package:flutter_application_1/features/stock/presentation/stock_screen.dart';
import 'package:flutter_application_1/features/company/presentation/manage_employees_screen.dart';
import 'package:flutter_application_1/features/settings/presentation/manage_data_screen.dart';
import 'package:flutter_application_1/features/settings/presentation/language_settings_screen.dart';
import 'package:flutter_application_1/services/localization_service.dart';
import 'package:flutter_application_1/features/subscription/presentation/subscription_status_screen.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF2C3E6B), Color(0xFF4A2C5E)]
        : const [Color(0xFF667EEA), Color(0xFF764BA2)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("About", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).round()),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ClipOval(
                        child: Image.asset('assets/images/logo.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("OceanSync",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text("Seafood Trading ERP",
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Colors.white.withAlpha((0.9 * 255).round()))),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge("v1.0.0"),
                        const SizedBox(width: 8),
                        _buildBadge("🇮🇳 India"),
                        const SizedBox(width: 8),
                        _buildBadge("Flutter"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(isDark, "About App", [
              _buildInfoText(
                isDark,
                "OceanSync is a comprehensive seafood trading management solution. Track purchases, sales, inventory, and finances with ease.",
              ),
            ]),
            const SizedBox(height: 16),
            _buildCard(isDark, "Features", [
              _buildFeatureRow(
                  isDark, Icons.shopping_cart, "Purchase", "Vendor management"),
              _buildFeatureRow(
                  isDark, Icons.inventory_2, "Inventory", "Stock tracking"),
              _buildFeatureRow(
                  isDark, Icons.trending_up, "Sales", "Export orders"),
              _buildFeatureRow(
                  isDark, Icons.sync_alt, "Re-grading", "Stock conversion"),
              _buildFeatureRow(
                  isDark, Icons.people, "Employees", "Team management"),
              _buildFeatureRow(
                  isDark, Icons.bar_chart, "Reports", "Business analytics"),
            ]),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Developer",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                          const Text("Charan Kumar Kanna",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color:
                                    Colors.white.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Text("Full Stack Developer",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildContactBtn(
                              Icons.email,
                              "Email",
                              () => _launchUrl(
                                  'mailto:kanna.charan2006@gmail.com'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildContactBtn(Icons.phone, "Call",
                              () => _launchUrl('tel:+919391561154'))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildContactBtn(
                              Icons.chat, "WhatsApp", () => _launchWhatsApp())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Follow on Social Media",
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialBtn(
                          Icons.link,
                          const Color(0xFF0A66C2),
                          () => _launchUrl(
                              'https://linkedin.com/in/charankumar')),
                      _buildSocialBtn(
                          Icons.camera_alt,
                          const Color(0xFFE4405F),
                          () => _launchUrl(
                              'https://www.instagram.com/charann.kumar__/')),
                      _buildSocialBtn(
                          Icons.facebook,
                          const Color(0xFF1877F2),
                          () => _launchUrl(
                              'https://www.facebook.com/charan2006/')),
                      _buildSocialBtn(Icons.code, Colors.white,
                          () => _launchUrl('https://github.com/charankumar')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
                child: Text("© 2026 OceanSync | Made with ❤️ in India 🇮🇳",
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.tertiaryTextDark
                            : Colors.grey[500]))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.2 * 255).round()),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  static Widget _buildCard(bool isDark, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.primaryTextDark
                      : const Color(0xFF1A1A1A))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildInfoText(bool isDark, String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.secondaryTextDark : Colors.grey[600],
            height: 1.5));
  }

  static Widget _buildFeatureRow(
      bool isDark, IconData icon, String title, String subtitle) {
    final accentColor = isDark ? AppColors.accentDark : const Color(0xFF667EEA);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: accentColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryTextDark : null)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.tertiaryTextDark
                          : Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildContactBtn(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600))
          ],
        ),
      ),
    );
  }

  static Widget _buildSocialBtn(
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _launchWhatsApp() async {
    final url =
        "https://wa.me/919391561154?text=${Uri.encodeComponent("Hi Charankumar!")}";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class HomeScreen extends StatefulWidget {
  final String? userName;
  final int? companyId;
  final String? userRole;

  const HomeScreen({
    super.key,
    required this.userRole,
    this.userName,
    this.companyId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  String _userName = "";
  late WebSocketProvider _wsProvider;

  List<String> get _titles => [
        AppLocalizations.dashboard,
        AppLocalizations.purchase,
        AppLocalizations.reGrading,
        AppLocalizations.sales,
        AppLocalizations.reports,
      ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initWebSocket();
    _showDailyNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _wsProvider.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserName();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _loadUserName() async {
    final storedUserName = await SecureStorage.getData("user_name");
    if (mounted && storedUserName != null) {
      setState(() {
        _userName = storedUserName;
      });
    }
  }

  void _showDailyNotifications() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        NotificationService.showDailyNotification(context);
      }
    });
  }

  void _initWebSocket() {
    _wsProvider = WebSocketProvider();
    if (widget.companyId != null) {
      _wsProvider.connect(widget.companyId!);
    }
  }

  Future<void> _showLogoutDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red[400], size: 28),
              const SizedBox(width: 12),
              Text(
                "Confirm Logout",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.primaryTextDark : null),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[400],
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? AppColors.primaryTextDark : null),
              ),
              const SizedBox(height: 8),
              Text(
                "You'll need to login again to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.secondaryTextDark
                        : Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[500])),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop(); // Close dialog

                scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Logging out...")));

                await SecureStorage.deleteToken();

                if (!mounted) return;

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentMode = themeController.themeMode;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "Choose Theme",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeRadioTile(
                    context: context,
                    value: ThemeMode.system,
                    groupValue: currentMode,
                    icon: Icons.settings_brightness,
                    label: "System",
                    subtitle: "Follow device settings",
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        themeController.setThemeMode(mode);
                        setDialogState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildThemeRadioTile(
                    context: context,
                    value: ThemeMode.light,
                    groupValue: currentMode,
                    icon: Icons.light_mode,
                    label: "Light",
                    subtitle: "Always light mode",
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        themeController.setThemeMode(mode);
                        setDialogState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildThemeRadioTile(
                    context: context,
                    value: ThemeMode.dark,
                    groupValue: currentMode,
                    icon: Icons.dark_mode,
                    label: "Dark",
                    subtitle: "Always dark mode",
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        themeController.setThemeMode(mode);
                        setDialogState(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Done",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeRadioTile({
    required BuildContext context,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
    required String label,
    required String subtitle,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutApp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutAppScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      /// DRAWER
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        child: Drawer(
          backgroundColor: colorScheme.surface,
          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A2A4A), const Color(0xFF2C1A3E)]
                        : const [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.business_center,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "OceanSync",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_userName.isNotEmpty)
                          Text(
                            _userName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  children: [
                    if (widget.userRole == 'OWNER') ...[
                      _drawerSection(isDark),
                      _drawerItem(
                          Icons.account_balance_wallet,
                          "Customer Balance",
                          _navTo(const CustomerBalanceScreen()),
                          isDark),
                      _drawerItem(Icons.payments, "Customer Payment",
                          _navTo(const CustomerPaymentScreen()), isDark),
                      const SizedBox(height: 8),
                      _drawerSection(isDark, title: "Vendors"),
                      _drawerItem(Icons.store, "Vendor Balance",
                          _navTo(const VendorBalanceScreen()), isDark),
                      _drawerItem(Icons.payment, "Vendor Payment",
                          _navTo(const VendorPaymentScreen()), isDark),
                      const SizedBox(height: 8),
                      _drawerSection(isDark, title: "Company"),
                      _drawerItem(Icons.people, "Manage Employees",
                          _navTo(const ManageEmployeesScreen()), isDark),
                      _drawerItem(Icons.storage, "Manage Data",
                          _navTo(const ManageDataScreen()), isDark),
                      _drawerItem(Icons.subscriptions, "Subscription",
                          _navTo(const SubscriptionStatusScreen()), isDark),
                    ],
                    const SizedBox(height: 8),
                    _drawerSection(isDark, title: "Stock"),
                    _drawerItem(Icons.inventory_2, "Stock Overview",
                        _navTo(const StockScreen()), isDark),
                    const SizedBox(height: 8),
                    _drawerSection(isDark, title: "Appearance"),
                    _drawerItem(Icons.palette_outlined, "Theme",
                        _showThemeDialog, isDark),
                    _drawerItem(Icons.settings, "Language",
                        _navTo(const LanguageSettingsScreen()), isDark),
                    _drawerItem(
                        Icons.info_outline, "About App", _showAboutApp, isDark),
                  ],
                ),
              ),

              /// LOGOUT
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon:
                        const Icon(Icons.logout, size: 18, color: Colors.white),
                    label: const Text("Logout",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(userName: _userName),
          const PurchaseScreen(),
          const ConversionScreen(),
          const ExportScreen(),
          const ReportsDashboard(),
        ],
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          HapticFeedback.mediumImpact();
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isDark ? AppColors.accentDark : Colors.blue,
        unselectedItemColor:
            isDark ? AppColors.secondaryTextDark : Colors.grey[600],
        backgroundColor: colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Purchase",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory),
            label: "Re-grading",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: "Sales",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
        ],
      ),
    );
  }

  VoidCallback _navTo(Widget screen) {
    return () =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// DRAWER SECTION
  Widget _drawerSection(bool isDark, {String title = "Customers"}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? AppColors.secondaryTextDark : const Color(0xFF8E8E93),
        ),
      ),
    );
  }

  /// DRAWER ITEM
  Widget _drawerItem(
      IconData icon, String title, VoidCallback onTap, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1.5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha((0.8 * 255).round())
            : Colors.grey.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        minLeadingWidth: 28,
        leading: Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.secondaryTextDark : const Color(0xFF3C3C43),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.primaryTextDark : const Color(0xFF1A1A1A),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDark ? AppColors.tertiaryTextDark : const Color(0xFFC7C7CC),
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
