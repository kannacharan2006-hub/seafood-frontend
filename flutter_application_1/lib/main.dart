import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'services/secure_storage.dart';
import 'services/localization_service.dart';
import 'services/connectivity_service.dart';
import 'core/widgets/error_boundary.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = _DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  AppErrorHandler.setup();

  await dotenv.load(fileName: ".env");
  await AppLocalizations.init();
  await ConnectivityService().initialize();

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

  runApp(
    ErrorBoundary(
      onError: (error, stackTrace) {
        debugPrint('App Error: $error');
        debugPrint('Stack trace: $stackTrace');
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppLocalizations.changeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    AppLocalizations.changeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

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
    final isTelugu = AppLocalizations.currentLocale.languageCode == 'te';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.appName,
      locale: AppLocalizations.currentLocale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: isTelugu ? 'TeluguFont' : 'Roboto',
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
                  userName:
                      "", // Will be fetched from secure storage in HomeScreen.initState
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
