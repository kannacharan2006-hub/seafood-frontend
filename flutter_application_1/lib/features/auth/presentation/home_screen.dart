import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_1/services/secure_storage.dart';
import 'package:flutter_application_1/services/websocket_service.dart';

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

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("About", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ClipOval(
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("OceanSync", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text("Seafood Trading ERP", style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
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
            _buildCard("About App", [
              _buildInfoText("OceanSync is a comprehensive seafood trading management solution. Track purchases, sales, inventory, and finances with ease."),
            ]),
            const SizedBox(height: 16),
            _buildCard("Features", [
              _buildFeatureRow(Icons.shopping_cart, "Purchase", "Vendor management"),
              _buildFeatureRow(Icons.inventory_2, "Inventory", "Stock tracking"),
              _buildFeatureRow(Icons.trending_up, "Sales", "Export orders"),
              _buildFeatureRow(Icons.sync_alt, "Re-grading", "Stock conversion"),
              _buildFeatureRow(Icons.people, "Employees", "Team management"),
              _buildFeatureRow(Icons.bar_chart, "Reports", "Business analytics"),
            ]),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Developer", style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const Text("Charan Kumar Kanna", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: const Text("Full Stack Developer", style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildContactBtn(Icons.email, "Email", () => _launchUrl('mailto:kanna.charan2006@gmail.com'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildContactBtn(Icons.phone, "Call", () => _launchUrl('tel:+919391561154'))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildContactBtn(Icons.chat, "WhatsApp", () => _launchWhatsApp())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Follow on Social Media", style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialBtn(Icons.link, const Color(0xFF0A66C2), () => _launchUrl('https://linkedin.com/in/charankumar')),
                      _buildSocialBtn(Icons.camera_alt, const Color(0xFFE4405F), () => _launchUrl('https://www.instagram.com/charann.kumar__/')),
                      _buildSocialBtn(Icons.facebook, const Color(0xFF1877F2), () => _launchUrl('https://www.facebook.com/charan2006/')),
                      _buildSocialBtn(Icons.code, Colors.white, () => _launchUrl('https://github.com/charankumar')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(child: Text("© 2024 OceanSync | Made with ❤️ in India 🇮🇳", style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  static Widget _buildCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildInfoText(String text) {
    return Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5));
  }

  static Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF667EEA).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF667EEA)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildContactBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))],
          ),
        ),
      ),
    );
  }

  static Widget _buildSocialBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  static Future<void> _launchWhatsApp() async {
    final url = "https://wa.me/919391561154?text=${Uri.encodeComponent("Hi Charankumar!")}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final int? companyId;

  const HomeScreen({
    super.key,
    required this.userName,
    this.companyId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription<WebSocketMessage>? _wsSubscription;

  final List<String> _titles = [
    "Dashboard",
    "Purchase",
    "Re-grading",
    "Sales",
    "Reports",
  ];

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  void _initWebSocket() {
    if (widget.companyId != null) {
      _wsService.connectWithCompany(widget.companyId!);
      _wsSubscription = _wsService.messages?.listen(_handleWebSocketMessage);
    }
  }

  void _handleWebSocketMessage(WebSocketMessage message) {
    if (!mounted) return;

    final notificationTitle = switch (message.event) {
      WebSocketEvent.stockUpdate => 'Stock Updated',
      WebSocketEvent.purchaseCreated => 'New Purchase',
      WebSocketEvent.exportCreated => 'New Sale',
      WebSocketEvent.conversionCreated => 'Conversion Complete',
      WebSocketEvent.authSuccess => 'Connected',
      _ => null,
    };

    if (notificationTitle == null) return;

    final notificationBody = switch (message.event) {
      WebSocketEvent.stockUpdate => 'Inventory has been updated',
      WebSocketEvent.purchaseCreated => 'A new purchase has been recorded',
      WebSocketEvent.exportCreated => 'A new export has been recorded',
      WebSocketEvent.conversionCreated => 'Items have been converted',
      WebSocketEvent.authSuccess => 'Real-time updates enabled',
      _ => null,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificationTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (notificationBody != null)
              Text(
                notificationBody,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsService.disconnectAndClear();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
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
              const Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "You'll need to login again to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                navigator.pop(); // Close dialog

                // Show loading
                scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Logging out...")));

                // Your existing logout logic
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// DRAWER
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          backgroundColor: Colors.white,
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business_center, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    "OceanSync",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.userName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _drawerSection("Customers"),
                  _drawerItem(
                    Icons.account_balance_wallet,
                    "Customer Balance",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerBalanceScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(Icons.payments, "Customer Payment", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerPaymentScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _drawerSection("Vendors"),
                  _drawerItem(Icons.store, "Vendor Balance", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorBalanceScreen(),
                      ),
                    );
                  }),
                  _drawerItem(Icons.payment, "Vendor Payment", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorPaymentScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _drawerSection("Company"),
                  _drawerItem(Icons.people, "Manage Employees", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageEmployeesScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _drawerSection("Stock"),
                  _drawerItem(Icons.inventory_2, "Stock Overview", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StockScreen()),
                    );
                  }),
                  _drawerSection("About"),
                  _drawerItem(Icons.info_outline, "About App", _showAboutApp),
                ],
              ),
            ),

            /// LOGOUT
            /// LOGOUT - Updated
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog, // ← Changed from _logout
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[500],
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
          DashboardScreen(userName: widget.userName),
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
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
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

  /// DRAWER SECTION
  Widget _drawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// DRAWER ITEM
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, size: 22, color: const Color(0xFF3C3C43)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFC7C7CC)),
        onTap: onTap,
      ),
    );
  }
}
