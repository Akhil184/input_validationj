import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// JSON configuration for date formats
const String jsonConfig = '''
[
  {
    "datetype": "dd-mm-yyyy",
    "enabled": true
  },
  {
    "datetype": "mm-dd-yyyy",
    "enabled": false
  },
  {
    "datetype": "yyyy-mm-dd",
    "enabled": false
  },
  {
    "datetype": "dd/mm/yyyy",
    "enabled": true
  },
  {
    "datetype": "mm/dd/yyyy",
    "enabled": false
  },
  {
    "datetype": "yyyy/mm/dd",
    "enabled": false
  }
]
''';

/// Parse the JSON configuration
List<Map<String, dynamic>> parseDateConfig() {
  return List<Map<String, dynamic>>.from(jsonDecode(jsonConfig));
}

List getEnabledDateFormats() {
  return parseDateConfig()
      .where((config) => config['enabled'] == true)
      .map((config) => config['datetype'])
      .toList();
}

String? _currentDateFormat = 'dd-mm-yyyy';

/// Formatter for the date input field that automatically inserts and removes separators
class TextInputValidation extends TextInputFormatter {
  final String dateFormat;

  TextInputValidation(this.dateFormat);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final separator = dateFormat.contains('/') ? '/' : '-';
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final oldText = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    StringBuffer buffer = StringBuffer();
    int cursorOffset = newValue.selection.baseOffset;

    // Build formatted text based on length
    if (newText.length > 2) {
      buffer.write(newText.substring(0, 2) + separator);
      if (newText.length > 4) {
        buffer.write(newText.substring(2, 4) + separator);
        if (newText.length > 6) {
          buffer.write(newText.substring(4, 8));
        } else {
          buffer.write(newText.substring(4));
        }
      } else {
        buffer.write(newText.substring(2));
      }
    } else {
      buffer.write(newText);
    }

    final formattedText = buffer.toString();

    // Adjust cursor position
    int newCursorOffset = _calculateCursorOffset(
      oldText,
      newText,
      cursorOffset,
      formattedText,
    );

    newCursorOffset = newCursorOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newCursorOffset,
      ),
    );
  }

  int _calculateCursorOffset(
    String oldText,
    String newText,
    int cursorOffset,
    String formattedText,
  ) {
    final oldTextLength = oldText.length;
    final formattedTextLength = formattedText.length;

    // If text is removed
    if (formattedTextLength < oldTextLength) {
      if (cursorOffset <= formattedTextLength) {
        // Cursor is within the new text length
        return cursorOffset;
      } else {
        // Cursor was beyond the removed section
        return formattedTextLength;
      }
    }

    // If text is added
    if (formattedTextLength > oldTextLength) {
      if (cursorOffset < oldTextLength) {
        // Cursor is before the added text
        return cursorOffset;
      } else {
        // Cursor was within or after the added section
        int adjustment = formattedTextLength - oldTextLength;
        return cursorOffset + adjustment;
      }
    }

    // If text length remains the same
    return cursorOffset;
  }
}

/// Validator function for date input with leap year and format validation
String? dateValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a date';
  }

  final dateFormatConfig = parseDateConfig().firstWhere(
    (config) => config['enabled'] == true,
    orElse: () => {'datetype': 'dd-mm-yyyy'},
  );

  final dateFormat = dateFormatConfig['datetype'];
  final separator = dateFormat.contains('/') ? '/' : '-';

  RegExp regex;
  switch (dateFormat) {
    case 'dd-mm-yyyy':
    case 'dd/mm/yyyy':
      regex = RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$'); // Dash or slash
      break;
    case 'mm-dd-yyyy':
    case 'mm/dd/yyyy':
      regex = RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$'); // Dash or slash
      break;
    case 'yyyy-mm-dd':
    case 'yyyy/mm/dd':
      regex = RegExp(r'^\d{4}[-/]\d{2}[-/]\d{2}$'); // Dash or slash
      break;
    default:
      return 'Invalid date format';
  }

  if (!regex.hasMatch(value)) {
    return 'Enter a valid date in $dateFormat format';
  }

  final parts = value.split(RegExp(r'[-/]'));
  if (parts.length != 3) {
    return 'Enter a valid date';
  }

  int day, month, year;
  try {
    day = int.parse(parts[0]);
    month = int.parse(parts[1]);
    year = int.parse(parts[2]);
  } catch (e) {
    return 'Enter a valid date';
  }

  if (year < 1996 || year > 2024) {
    return 'Year must be between 1996 and 2024';
  }

  if (month < 1 || month > 12) {
    return 'Enter a valid month (01-12)';
  }

  if (day < 1 || day > 31) {
    return 'Enter a valid day (01-31)';
  }

  if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
    return 'Enter a valid day for the month (01-30)';
  }

  if (month == 2) {
    if (isLeapYear(year)) {
      if (day > 29) {
        return 'Enter a valid day for February in a leap year (01-29)';
      }
    } else {
      if (day > 28) {
        return 'Enter a valid day for February (01-28)';
      }
    }
  }

  return null; // Date is valid
}

/// Helper function to check for leap years
bool isLeapYear(int year) {
  return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
}

void setCurrentDateFormat(String format) {
  _currentDateFormat = format;
}
