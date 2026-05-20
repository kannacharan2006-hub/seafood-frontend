import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supported deployment environments.
/// 
/// Usage:
///   flutter run --dart-define APP_ENV=dev
///   flutter run --dart-define APP_ENV=staging
///   flutter build apk --release --dart-define APP_ENV=prod
enum AppEnvironment {
  dev,
  staging,
  prod;

  String get label {
    switch (this) {
      case AppEnvironment.dev:
        return 'development';
      case AppEnvironment.staging:
        return 'staging';
      case AppEnvironment.prod:
        return 'production';
    }
  }

  bool get isDevelopment => this == AppEnvironment.dev;
  bool get isProduction => this == AppEnvironment.prod;
}

/// App configuration supporting multiple environments 
/// (dev/staging/prod) without bundling secrets in the APK.
///
/// ⚠️ SECURITY: The .env file is NOT bundled in release builds.
///    Use --dart-define to pass production values safely.
///
/// ## Quick Start
///
/// ```bash
/// # Development (uses .env file)
/// flutter run
///
/// # Production (secrets passed at compile time — safe)
/// flutter build apk --release \
///   --dart-define APP_ENV=prod \
///   --dart-define BASE_URL=https://api.yourdomain.com \
///   --dart-define SENTRY_DSN=https://key@oX.ingest.sentry.io/Y
/// ```
class AppConfig {
  // ---------------------------------------------------------------
  // 1. Environment detection
  // ---------------------------------------------------------------

  /// The current app environment. Defaults to [AppEnvironment.dev].
  /// 
  /// Set at build time: `--dart-define APP_ENV=prod`
  static AppEnvironment get environment {
    const envName = String.fromEnvironment('APP_ENV');
    switch (envName.toLowerCase()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      default:
        return AppEnvironment.dev;
    }
  }

  /// Shorthand check: is this a development build?
  static bool get isDevelopment => environment.isDevelopment;

  /// Shorthand check: is this a production build?
  static bool get isProduction => environment.isProduction;

  // ---------------------------------------------------------------
  // 2. Configuration values
  // ---------------------------------------------------------------

  /// Safely read a value from dotenv only if it has been initialized.
  static String? _env(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  /// The backend API base URL.
  ///
  /// Priority: --dart-define > .env > environment-specific fallback
  static String get baseUrl {
    const fromDartDefine = String.fromEnvironment('BASE_URL');
    if (fromDartDefine.isNotEmpty) return fromDartDefine;

    final fromEnv = _env('BASE_URL');
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    // Environment-specific defaults
    switch (environment) {
      case AppEnvironment.dev:
        return 'https://seafood-backend-3.onrender.com';
      case AppEnvironment.staging:
        return 'https://staging-api.yourdomain.com';
      case AppEnvironment.prod:
        // In production, --dart-define is required
        return 'https://seafood-backend-3.onrender.com';
    }
  }

  /// The Sentry DSN for crash reporting.
  ///
  /// Priority: --dart-define > .env > null (disabled)
  static String? get sentryDsn {
    const fromDartDefine = String.fromEnvironment('SENTRY_DSN');
    if (fromDartDefine.isNotEmpty) return fromDartDefine;

    final fromEnv = _env('SENTRY_DSN');
    if (fromEnv != null && fromEnv.isNotEmpty && fromEnv != 'YOUR_SENTRY_DSN_HERE') {
      return fromEnv;
    }

    return null;
  }

  /// Whether Sentry should be enabled in this environment.
  static bool get sentryEnabled {
    // Sentry is always enabled if a DSN is configured
    if (sentryDsn != null) return true;
    // Auto-enable in production as a safety net
    return isProduction;
  }

  /// Whether debug logging should be visible.
  static bool get enableDebugLogging => !isProduction;
}