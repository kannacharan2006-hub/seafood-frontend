import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_1/services/secure_storage.dart';

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

import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Dashboard",
    "Purchase",
    "Re-grading",
    "Sales",
    "Reports",
  ];

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
                Navigator.of(context).pop(); // Close dialog

                // Show loading
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Logging out...")));

                // Your existing logout logic
                await SecureStorage.deleteToken();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
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

  // 🔥 PASTE THESE 2 FUNCTIONS

  void _showAboutApp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            title: const Text("About OceanSync",
                style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Main Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(Icons.business_center,
                      color: Colors.white, size: 60),
                ),
                const SizedBox(height: 24),

                // App Title
                Text(
                  "OceanSync",
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "v1.0.0 | Made in India 🇮🇳",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Welcome Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 48, color: Color(0xFFF59E0B)),
                      const SizedBox(height: 16),
                      Text(
                        "Why OceanSync?",
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Save time, reduce mistakes, grow your business.\nSimple app for seafood shops like yours.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Features List
                Text(
                  "What you get:",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),

                // Feature Cards
                _featureItem(Icons.shopping_cart, "Easy Purchase",
                    "Track what you buy from vendors"),
                _featureItem(Icons.inventory_2, "Stock Control",
                    "Never run out of stock"),
                _featureItem(Icons.account_balance_wallet, "Customer Money",
                    "Know who owes you"),
                _featureItem(
                    Icons.payment, "Vendor Money", "Pay vendors on time"),
                _featureItem(Icons.people, "Employees", "Manage your team"),
                _featureItem(Icons.bar_chart, "Reports", "See your profits"),

                const SizedBox(height: 32),

                // CTA Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Start Using Now!",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Everything works offline too!",
                        style: TextStyle(
                            fontSize: 16, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Made by Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2563EB),
                        child: Icon(Icons.favorite, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Made by Charan kumar Kanna",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold)),
                            Text("Repalle, Andhra Pradesh",
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Simple feature item widget
  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloper() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            title: const Text("Charan kumar Kanna",
                style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 90),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.verified, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name & Title
                Text(
                  "Charan kumar Kanna",
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Flutter Full Stack Developer",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "kothapalem, Andhra Pradesh",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // About Me
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 48, color: Color(0xFFF59E0B)),
                      const SizedBox(height: 20),
                      Text(
                        "Hi! 👋",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "I create simple apps for small businesses.\n"
                        "Seafood ERP helps you track purchases, stock, "
                        "customers and vendors easily.\n\n"
                        "Made with ❤️ in India for Indian shops.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCard("5+", "Apps", Icons.apps),
                    _statCard("3+", "Years", Icons.calendar_today),
                    _statCard("50+", "Happy Shops", Icons.store),
                  ],
                ),
                const SizedBox(height: 32),

                // Contact Buttons
                Column(
                  children: [
                    // WhatsApp ⭐ NEW
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(),
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text("WhatsApp Chat",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            launchUrl(Uri.parse('tel:+919391561154')),
                        icon: const Icon(Icons.phone, color: Colors.green),
                        label: const Text("Call +91 93915 61154",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.green, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => launchUrl(
                            Uri.parse('mailto:kanna.charan2006@gmail.com')),
                        icon: const Icon(Icons.email, color: Colors.red),
                        label: const Text("Email",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                // Add this AFTER Email button, before SizedBox(height: 32)
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Instagram
                    IconButton(
                      onPressed: () => launchUrl(
                          Uri.parse('https://instagram.com/yourusername')),
                      icon: const Icon(Icons.ondemand_video,
                          color: Color(0xFFE4405F), size: 32),
                      tooltip: "Instagram",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                        elevation: 2,
                      ),
                    ),
                    // Facebook
                    IconButton(
                      onPressed: () => launchUrl(
                          Uri.parse('https://facebook.com/yourusername')),
                      icon: const Icon(Icons.facebook,
                          color: Color(0xFF1877F2), size: 32),
                      tooltip: "Facebook",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                        elevation: 2,
                      ),
                    ),
                    // LinkedIn (bonus)
                    IconButton(
                      onPressed: () => launchUrl(
                          Uri.parse('https://linkedin.com/in/charankumar')),
                      icon: const Icon(Icons.business_center,
                          color: Color(0xFF0077B5), size: 32),
                      tooltip: "LinkedIn",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 🔥 WHATSAPP FUNCTION ⭐
  void _launchWhatsApp() async {
    const message =
        "Hi Charankumar! I found your OceanSync app. Can you help me?";
    final whatsappUrl = Uri.parse(
        "https://wa.me/919391561154?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

// Keep your existing _statCard and _contactButton functions

  Widget _statCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
      ],
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
      drawer: Drawer(
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
                  _drawerItem(
                      Icons.developer_mode, "Developer", _showDeveloper),
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

      /// BODY
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// DRAWER ITEM
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
