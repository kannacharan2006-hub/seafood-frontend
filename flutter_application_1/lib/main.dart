import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'services/secure_storage.dart';
import 'services/localization_service.dart';
import 'services/connectivity_service.dart';
import 'services/sentry_service.dart';
import 'core/widgets/error_boundary.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// HTTP overrides that bypass SSL certificate validation.
/// 
/// ⚠️ SAFETY: Only applied in debug/profile mode.
/// In release builds (Play Store), real SSL validation is enforced.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => 
              kReleaseMode ? false : true;
  }
}

/// Global theme controller instance for app-wide theme mode management.
final ThemeController themeController = ThemeController();

/// Safely load .env file if it exists (development only).
/// In release builds, .env is NOT bundled in the APK, so this silently skips.
Future<void> _loadEnvIfAvailable() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // .env not found — this is normal in release builds
  }
}

void main() async {
  // Only apply dev HTTP overrides in non-release builds
  if (!kReleaseMode) {
    HttpOverrides.global = _DevHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();

  AppErrorHandler.setup();

  // Load .env if it exists (for local development only — not bundled in release builds)
  await _loadEnvIfAvailable();
  await SentryService.init(); // Safe: silently skips if no DSN configured
  await AppLocalizations.init();
  await ConnectivityService().initialize();
  await themeController.loadThemeMode();

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
        // Also send to Sentry (silently skipped if not configured)
        SentryService.captureException(error, stackTrace: stackTrace);
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

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // Apply the Telugu font on top of the base AppTheme
        final lightTheme = AppTheme.lightTheme.copyWith(
          textTheme: AppTheme.lightTheme.textTheme.apply(
            fontFamily: isTelugu ? 'TeluguFont' : null,
          ),
        );
        final darkTheme = AppTheme.darkTheme.copyWith(
          textTheme: AppTheme.darkTheme.textTheme.apply(
            fontFamily: isTelugu ? 'TeluguFont' : null,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppLocalizations.appName,
          locale: AppLocalizations.currentLocale,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
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
      },
    );
  }
}