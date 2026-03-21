import 'package:flutter/material.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'services/secure_storage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    final token = await SecureStorage.getToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ERP SaaS",
      theme: ThemeData(primarySwatch: Colors.blue),

      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const HomeScreen(userName: "User");
          }

          return const SplashScreen();
        },
      ),
    );
  }
}
