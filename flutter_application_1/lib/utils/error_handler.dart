import 'package:flutter/material.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../config/api.dart';
import '../services/sentry_service.dart';
import '../features/subscription/models/subscription_exception.dart';
import '../features/subscription/presentation/subscription_expired_overlay.dart';

class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final int? statusCode;

  const AppError({
    required this.message,
    this.details,
    required this.type,
    this.statusCode,
  });

  factory AppError.fromException(dynamic e) {
    String message = 'Something went wrong';
    String? details;
    ErrorType type = ErrorType.unknown;
    int? statusCode;

    final errorString = e.toString();

    if (e is SubscriptionExpiredException) {
      message = e.message;
      type = ErrorType.subscription;
      statusCode = 403;
    } else if (errorString.contains('Session expired') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('401')) {
      message = 'Your session has expired. Please login again.';
      type = ErrorType.auth;
      statusCode = 401;
    } else if (errorString.contains('Network') ||
        errorString.contains('SocketException') ||
        errorString.contains('Timeout')) {
      message = 'Please check your internet connection and try again.';
      type = ErrorType.network;
    } else if (errorString.contains('404') ||
        errorString.contains('Not found')) {
      message = 'The requested resource was not found.';
      type = ErrorType.notFound;
      statusCode = 404;
    } else if (errorString.contains('403') ||
        errorString.contains('Forbidden')) {
      message = 'You do not have permission to perform this action.';
      type = ErrorType.permission;
      statusCode = 403;
    } else if (errorString.contains('429') ||
        errorString.contains('Too many requests')) {
      message = 'Too many requests. Please wait a moment and try again.';
      type = ErrorType.rateLimit;
      statusCode = 429;
    } else if (errorString.contains('500') ||
        errorString.contains('Internal Server Error')) {
      message = 'Server error. Please try again later.';
      type = ErrorType.server;
      statusCode = 500;
    } else {
      message = errorString.replaceFirst('Exception: ', '');
      details = errorString;
    }

    return AppError(
      message: message,
      details: details,
      type: type,
      statusCode: statusCode,
    );
  }

  bool get isAuthError => type == ErrorType.auth;
  bool get isNetworkError => type == ErrorType.network;
  bool get isServerError => type == ErrorType.server;
}

enum ErrorType {
  network,
  auth,
  server,
  notFound,
  permission,
  subscription,
  rateLimit,
  validation,
  unknown,
}

class ErrorHandler {
  static void showError(BuildContext context, dynamic error,
      {VoidCallback? onRetry}) {
    final appError = error is AppError ? error : AppError.fromException(error);

    if (appError.type == ErrorType.subscription) {
      final exception = error is SubscriptionExpiredException
          ? error
          : SubscriptionExpiredException(
              message: appError.message,
              plans: [],
            );
      SubscriptionExpiredOverlay.show(context, error: exception);
      return;
    }

    // Report to Sentry (silently skipped if not configured)
    SentryService.captureException(error, extras: {
      'error_type': appError.type.name,
      'status_code': appError.statusCode,
      'message': appError.message,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIcon(appError.type), color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appError.message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: _getColor(appError.type),
        duration: const Duration(seconds: 4),
        action: appError.isAuthError
            ? SnackBarAction(
                label: 'LOGIN',
                textColor: Colors.white,
                onPressed: () {
                  Api.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                    (route) => false,
                  );
                },
              )
            : onRetry != null
                ? SnackBarAction(
                    label: 'RETRY',
                    textColor: Colors.white,
                    onPressed: onRetry,
                  )
                : null,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Color _getColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.auth:
        return Colors.red;
      case ErrorType.server:
        return Colors.red.shade800;
      case ErrorType.notFound:
        return Colors.grey.shade700;
      case ErrorType.permission:
        return Colors.purple;
      case ErrorType.subscription:
        return Colors.deepOrange;
      case ErrorType.rateLimit:
        return Colors.amber.shade800;
      case ErrorType.validation:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  static IconData _getIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_person;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.subscription:
        return Icons.subscriptions_rounded;
      case ErrorType.rateLimit:
        return Icons.speed;
      case ErrorType.validation:
        return Icons.warning;
      default:
        return Icons.error;
    }
  }
}
