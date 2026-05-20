import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/app_config.dart';

/// Safe wrapper around Sentry crash reporting.
///
/// Safely handles missing DSN (Dev/Staging) and only initializes
/// when a valid DSN is configured (via .env or --dart-define).
class SentryService {
  static bool _initialized = false;

  /// The Sentry DSN from config (--dart-define or .env).
  static String? get _dsn => AppConfig.sentryDsn;

  /// Whether Sentry has been successfully initialized.
  static bool get isInitialized => _initialized;

  /// Initialize Sentry with the configured DSN.
  ///
  /// This is safe to call even if no DSN is configured — it will silently
  /// skip initialization in dev environments. Sentry will automatically
  /// capture Flutter errors, platform crashes, and unhandled exceptions.
  ///
  /// Call this once from main() before runApp().
  static Future<void> init() async {
    final dsn = _dsn;
    if (dsn == null) {
      debugPrint('[Sentry] No DSN configured. Skipping initialization.');
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate = 0.2; // 20% performance tracing
          options.environment = AppConfig.environment.label;
          options.reportPackages = false;
          // Breadcrumbs are enabled by default in sentry_flutter
          options.attachScreenshot = false; // Privacy: don't send screenshots
        },
        appRunner: () {
          // runApp is called from main.dart, not here
        },
      );
      _initialized = true;
      debugPrint('[Sentry] Initialized successfully.');
    } catch (e) {
      debugPrint('[Sentry] Failed to initialize: $e');
      // Never crash the app due to Sentry failure
    }
  }

  /// Capture an exception and send it to Sentry.
  ///
  /// Safe to call anywhere — will do nothing if Sentry wasn't initialized.
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) return;

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace is StackTrace ? stackTrace : null,
        hint: hint != null ? Hint.withMap({'hint': hint}) : null,
      );
    } catch (_) {
      // Silently fail — Sentry should never crash the app
    }
  }

  /// Capture a message/event to Sentry.
  ///
  /// Safe to call anywhere — will do nothing if Sentry wasn't initialized.
  static Future<void> captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) return;

    try {
      SentryLevel sentryLevel;
      switch (level) {
        case 'warning':
          sentryLevel = SentryLevel.warning;
          break;
        case 'error':
          sentryLevel = SentryLevel.error;
          break;
        case 'fatal':
          sentryLevel = SentryLevel.fatal;
          break;
        default:
          sentryLevel = SentryLevel.info;
      }

      await Sentry.captureMessage(
        message,
        level: sentryLevel,
      );
    } catch (_) {
      // Silently fail
    }
  }

  /// Set the user identifier for Sentry events.
  ///
  /// Call this after login to associate errors with a specific user.
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
  }) async {
    if (!_initialized) return;

    try {
      Sentry.configureScope(
        (scope) {
          scope.setUser(SentryUser(
            id: id,
            email: email,
            username: username,
          ));
        },
      );
    } catch (_) {
      // Silently fail
    }
  }

  /// Remove user context (call on logout).
  static Future<void> clearUser() async {
    if (!_initialized) return;

    try {
      Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    } catch (_) {
      // Silently fail
    }
  }
}