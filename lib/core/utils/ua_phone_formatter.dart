import 'package:flutter/services.dart';

/// Ukrainian phone helpers. The `+380` prefix is shown separately (as a fixed
/// field prefix); the user only types the 9 national digits, formatted as
/// `XX XXX XX XX`.
class UaPhone {
  UaPhone._();

  static const String prefix = '+380';
  static const int digitsLength = 9;

  /// Extracts the bare digits (max 9 or 11 for US test number) from a formatted/raw string.
  static String digitsOf(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('1')) {
      return digits.length > 11 ? digits.substring(0, 11) : digits;
    }
    return digits.length > digitsLength
        ? digits.substring(0, digitsLength)
        : digits;
  }

  static bool isComplete(String text) {
    final digits = digitsOf(text);
    if (digits.startsWith('1')) {
      return digits.length == 11;
    }
    return digits.length == digitsLength;
  }

  /// Full E.164 number, e.g. `+380671234567` or `+18005550123`.
  static String toE164(String text) {
    final digits = digitsOf(text);
    if (digits.startsWith('1')) {
      return '+$digits';
    }
    return '$prefix$digits';
  }

  /// Formats a stored phone (digits, with or without country code) for display,
  /// e.g. `380671234567` -> `+380 67 123 45 67`.
  static String displayE164(String? raw) {
    if (raw == null) return '';
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return '';
    if (d.startsWith('380') && d.length == 12) {
      final n = d.substring(3);
      return '+380 ${n.substring(0, 2)} ${n.substring(2, 5)} '
          '${n.substring(5, 7)} ${n.substring(7, 9)}';
    }
    return '+$d';
  }
}

/// Restricts input to digits and formats them dynamically.
class UaPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = UaPhone.digitsOf(newValue.text);
    final buffer = StringBuffer();
    if (digits.startsWith('1')) {
      for (var i = 0; i < digits.length; i++) {
        if (i == 1 || i == 4 || i == 7) buffer.write(' ');
        buffer.write(digits[i]);
      }
    } else {
      for (var i = 0; i < digits.length; i++) {
        if (i == 2 || i == 5 || i == 7) buffer.write(' ');
        buffer.write(digits[i]);
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
