import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utility class for WCAG color contrast calculations and verification.
///
/// Provides methods to:
/// - Calculate relative luminance per WCAG 2.1
/// - Compute contrast ratios between two colors
/// - Verify WCAG AA/AAA compliance
/// - Suggest adjusted colors for better contrast
class ColorContrast {
  /// Calculates the relative luminance of a color per WCAG 2.1 definition.
  ///
  /// Formula: L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  /// where R, G, B are sRGB values after linearization.
  ///
  /// Returns a value between 0 (black) and 1 (white).
  static double relativeLuminance(Color color) {
    double linearize(double channel) {
      final srgb = channel / 255.0;
      if (srgb <= 0.04045) {
        return srgb / 12.92;
      }
      return math.pow((srgb + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = linearize(color.r * 255);
    final g = linearize(color.g * 255);
    final b = linearize(color.b * 255);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates the contrast ratio between two colors per WCAG 2.1.
  ///
  /// Ratio = (L1 + 0.05) / (L2 + 0.05)
  /// where L1 is the lighter luminance and L2 is the darker luminance.
  ///
  /// Returns a value between 1:1 (identical) and 21:1 (black on white).
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if the contrast ratio meets WCAG AA for normal text (>= 4.5:1).
  static bool meetsAAForNormalText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Checks if the contrast ratio meets WCAG AA for large text (>= 3:1).
  /// Large text is defined as >= 18pt or >= 14pt bold.
  static bool meetsAAForLargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Checks if the contrast ratio meets WCAG AAA for normal text (>= 7:1).
  static bool meetsAAAForNormalText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Checks if the contrast ratio meets WCAG AAA for large text (>= 4.5:1).
  static bool meetsAAAForLargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Checks if the contrast ratio meets WCAG AA for UI components (>= 3:1).
  static bool meetsAAForUIComponents(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Returns a human-readable WCAG compliance level string.
  ///
  /// Possible values: "AAA", "AA", "AA (Large Text Only)", "FAIL"
  static String complianceLevel(Color foreground, Color background,
      {bool isLargeText = false, bool isUIComponent = false}) {
    final ratio = contrastRatio(foreground, background);

    if (isUIComponent) {
      if (ratio >= 3.0) return 'AA (UI)';
      return 'FAIL';
    }

    if (ratio >= 7.0) return 'AAA';
    if (ratio >= 4.5) return 'AA';
    if (isLargeText && ratio >= 3.0) return 'AA (Large Text)';
    return 'FAIL';
  }

  /// Suggests a darker foreground color to meet WCAG AA (4.5:1) on the given
  /// background. Returns the original color if it already passes.
  ///
  /// This is a heuristic that darkens the color step by step. For production
  /// use, consider more sophisticated color adjustment algorithms.
  static Color suggestForegroundForAA(
      Color foreground, Color background, {bool isLargeText = false}) {
    final target = isLargeText ? 3.0 : 4.5;
    if (contrastRatio(foreground, background) >= target) return foreground;

    // Darken the foreground color iteratively
    var adjusted = foreground;
    for (var i = 0; i < 20; i++) {
      final r = (adjusted.r * 255 - 12).clamp(0, 255);
      final g = (adjusted.g * 255 - 12).clamp(0, 255);
      final b = (adjusted.b * 255 - 12).clamp(0, 255);
      adjusted = Color.fromRGBO(r.round(), g.round(), b.round(), 1.0);
      if (contrastRatio(adjusted, background) >= target) break;
    }
    return adjusted;
  }

  /// Suggests a lighter foreground color to meet WCAG AA (4.5:1) on the given
  /// background. Useful when the foreground is too dark on a dark background.
  static Color suggestLighterForegroundForAA(
      Color foreground, Color background, {bool isLargeText = false}) {
    final target = isLargeText ? 3.0 : 4.5;
    if (contrastRatio(foreground, background) >= target) return foreground;

    // Lighten the foreground color iteratively
    var adjusted = foreground;
    for (var i = 0; i < 20; i++) {
      final r = (adjusted.r * 255 + 12).clamp(0, 255);
      final g = (adjusted.g * 255 + 12).clamp(0, 255);
      final b = (adjusted.b * 255 + 12).clamp(0, 255);
      adjusted = Color.fromRGBO(r.round(), g.round(), b.round(), 1.0);
      if (contrastRatio(adjusted, background) >= target) break;
    }
    return adjusted;
  }

  /// Returns the contrast ratio formatted as a string (e.g., "4.5:1").
  static String formatRatio(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);
    return '${ratio.toStringAsFixed(1)}:1';
  }
}