import 'package:intl/intl.dart';

/// Utility class for consistent date formatting across the application
class DateFormatUtil {
  /// Format date as: Mar 06, 2024
  static String formatDateMMMddyyyy(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date and time as: Mar 06, 2024 10:30
  static String formatDateTimeMMMddyyyyHHmm(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date as: dd MMM yyyy (used in some screens)
  static String formatDateDdMMMyyyy(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date as: dd MMM yyyy, hh:mm a
  static String formatDateDdMMMyyyyhhhmma(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}
