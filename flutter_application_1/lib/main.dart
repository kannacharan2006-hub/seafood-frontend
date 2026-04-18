import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'services/secure_storage.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLocalizations.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    final token = await SecureStorage.getToken();
    return token != null;
  }

  Future<String> getUserRole() async {
    final role = await SecureStorage.getData("user_role");
    return role ?? "EMPLOYEE";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.appName,
      locale: AppLocalizations.currentLocale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return FutureBuilder<String>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                return HomeScreen(
                  userName: "User",
                  userRole: roleSnapshot.data ?? "EMPLOYEE",
                );
              },
            );
          }

          return const SplashScreen();
        },
      ),
    );
  }
}
