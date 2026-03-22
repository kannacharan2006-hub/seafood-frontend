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

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
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

  // 🔥 PASTE THESE 2 FUNCTIONS

  void _showAboutApp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
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
                const SizedBox(height: 32),
                
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // App Name
                const Text(
                  "OceanSync",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Made in India Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "🇮🇳 Made in India",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF9500),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                const Divider(height: 1),
                
                // App Info Section
                _aboutSection("App Info", [
                  _aboutItem(Icons.info_outline, "Version", "1.0.0"),
                  _aboutItem(Icons.phone_android, "Platform", "Android"),
                  _aboutItem(Icons.cloud_outlined, "Backend", "Cloud API"),
                ]),
                
                const Divider(height: 1),
                
                // Features Section
                _aboutSection("Features", [
                  _aboutItem(Icons.shopping_cart_outlined, "Purchase", "Manage vendor purchases"),
                  _aboutItem(Icons.inventory_2_outlined, "Inventory", "Track stock levels"),
                  _aboutItem(Icons.trending_up, "Sales", "Handle export orders"),
                  _aboutItem(Icons.sync_alt, "Re-grading", "Stock conversion"),
                  _aboutItem(Icons.people_outline, "Employees", "Team management"),
                  _aboutItem(Icons.bar_chart_outlined, "Reports", "Business analytics"),
                ]),
                
                const Divider(height: 1),
                
                // Description
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "OceanSync is a comprehensive business management solution designed for seafood trading businesses. It helps you manage purchases, sales, inventory, and finances all in one place.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3C3C43),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Built with modern technology to provide fast, reliable, and secure experience for your business operations.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3C3C43),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Developer Section
                _aboutSection("Developer", [
                  _aboutItem(Icons.person_outline, "Name", "Charan Kumar Kanna"),
                  _aboutItem(Icons.location_on_outlined, "Location", "Repalle, Andhra Pradesh"),
                  _aboutItem(Icons.email_outlined, "Email", "kanna.charan2006@gmail.com"),
                ]),
                
                const SizedBox(height: 32),
                
                // Footer
                const Text(
                  "© 2024 Seafood ERP",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Made with ❤️ in India",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC7C7CC),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _aboutItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Developer", style: TextStyle(fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Profile Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                
                // Name
                const Text(
                  "Charan Kumar Kanna",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Full Stack Developer",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      "Repalle, Andhra Pradesh, India",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(height: 1),
                
                // About Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Passionate developer focused on building practical solutions for small businesses. Specializing in mobile app development with Flutter for Android platforms.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3C3C43),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Portfolio Stats
                _aboutSection("Portfolio", [
                  _aboutItem(Icons.apps_outlined, "Apps Built", "5+"),
                  _aboutItem(Icons.work_outline, "Experience", "3+ Years"),
                  _aboutItem(Icons.sentiment_satisfied_alt_outlined, "Happy Clients", "50+"),
                ]),
                
                const Divider(height: 1),
                
                // Skills Section
                _aboutSection("Skills", [
                  _aboutItem(Icons.code, "Framework", "Flutter / Dart"),
                  _aboutItem(Icons.phone_android, "Platform", "Android"),
                  _aboutItem(Icons.cloud_outlined, "Backend", "REST API"),
                ]),
                
                const Divider(height: 1),
                
                // Contact Section
                _aboutSection("Contact", [
                  _aboutItemTappable(Icons.message, "WhatsApp", "+91 93915 61154", 
                      () => _launchWhatsApp()),
                  _aboutItemTappable(Icons.phone, "Phone", "+91 93915 61154",
                      () => launchUrl(Uri.parse('tel:+919391561154'))),
                  _aboutItemTappable(Icons.email, "Email", "kanna.charan2006@gmail.com",
                      () => launchUrl(Uri.parse('mailto:kanna.charan2006@gmail.com'))),
                ]),
                
                const Divider(height: 1),
                
                // Social Section
                _aboutSection("Social Profiles", [
                  _aboutItemTappable(Icons.link, "LinkedIn", "linkedin.com/in/charankumar",
                      () => launchUrl(Uri.parse('https://linkedin.com/in/charankumar'))),
                  _aboutItemTappable(Icons.camera_alt, "Instagram", "@charann.kumar__",
                      () => launchUrl(Uri.parse('https://www.instagram.com/charann.kumar__/'))),
                  _aboutItemTappable(Icons.facebook, "Facebook", "Charan Kumar",
                      () => launchUrl(Uri.parse('https://www.facebook.com/charan2006/'))),
                ]),
                
                const SizedBox(height: 32),
                
                // Footer
                const Text(
                  "© 2024 Charan Kumar Kanna",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Made with ❤️ in India",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC7C7CC),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutItemTappable(IconData icon, String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    const message = "Hi Charankumar! I found your app. Can you help me?";
    final whatsappUrl = Uri.parse(
        "https://wa.me/919391561154?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
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
        color: Colors.grey.withOpacity(0.05),
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
