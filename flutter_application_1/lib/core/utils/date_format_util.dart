import 'package:intl/intl.dart';

/// Utility class for consistent date formatting across the application
class DateFormatUtil {
  static DateTime _toIST(DateTime dt) {
    if (dt.isUtc) return dt.add(const Duration(hours: 5, minutes: 30));
    return dt;
  }

  /// Format date as: Mar 06, 2024
  static String formatDateMMMddyyyy(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      return DateFormat('MMM dd, yyyy').format(_toIST(DateTime.parse(dateStr)));
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date and time as: Mar 06, 2024 10:30
  static String formatDateTimeMMMddyyyyHHmm(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      return DateFormat('MMM dd, yyyy HH:mm')
          .format(_toIST(DateTime.parse(dateStr)));
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date as: dd MMM yyyy (used in some screens)
  static String formatDateDdMMMyyyy(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(_toIST(DateTime.parse(dateStr)));
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date as: dd MMM yyyy, hh:mm a
  static String formatDateDdMMMyyyyhhhmma(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(_toIST(DateTime.parse(dateStr)));
    } catch (e) {
      return dateStr;
    }
  }
}
