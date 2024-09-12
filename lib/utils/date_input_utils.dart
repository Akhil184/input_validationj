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

/// Formatter for the date input field that automatically inserts and removes separators
class TextInputValidtion extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle deletion (backspace)
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    final dateFormatConfig = parseDateConfig().firstWhere(
            (config) => config['enabled'] == true,
        orElse: () => {'datetype': 'dd-mm-yyyy'}); // Default to dd-mm-yyyy

    final dateFormat = dateFormatConfig['datetype'];
    final separator = dateFormat.contains('/') ? '/' : '-';

    // Remove all non-numeric characters except for the separator
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final buffer = StringBuffer();

    // Insert separators based on the date format
    if (dateFormat == 'dd-mm-yyyy' || dateFormat == 'dd/mm/yyyy') {
      if (text.length > 2) {
        buffer.write(text.substring(0, 2) + separator);
        if (text.length > 4) {
          buffer.write(text.substring(2, 4) + separator);
          if (text.length > 6) {
            buffer.write(text.substring(4, 8));
          } else {
            buffer.write(text.substring(4));
          }
        } else {
          buffer.write(text.substring(2));
        }
      } else {
        buffer.write(text);
      }
    } else if (dateFormat == 'mm-dd-yyyy' || dateFormat == 'mm/dd/yyyy') {
      if (text.length > 2) {
        buffer.write(text.substring(0, 2) + separator);
        if (text.length > 4) {
          buffer.write(text.substring(2, 4) + separator);
          if (text.length > 6) {
            buffer.write(text.substring(4, 8));
          } else {
            buffer.write(text.substring(4));
          }
        } else {
          buffer.write(text.substring(2));
        }
      } else {
        buffer.write(text);
      }
    } else if (dateFormat == 'yyyy-mm-dd' || dateFormat == 'yyyy/mm/dd') {
      if (text.length > 4) {
        buffer.write(text.substring(0, 4) + separator);
        if (text.length > 6) {
          buffer.write(text.substring(4, 6) + separator);
          if (text.length > 8) {
            buffer.write(text.substring(6));
          } else {
            buffer.write(text.substring(6));
          }
        } else {
          buffer.write(text.substring(4));
        }
      } else {
        buffer.write(text);
      }
    }

    // Calculate the cursor position after formatting
    final cursorOffset = buffer.length;

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: cursorOffset, // Move cursor to the end
      ),
    );
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
    case 'mm-dd-yyyy':
      regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
      break;
    case 'yyyy-mm-dd':
      regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      break;
    case 'dd/mm/yyyy':
    case 'mm/dd/yyyy':
      regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
      break;
    case 'yyyy/mm/dd':
      regex = RegExp(r'^\d{4}/\d{2}/\d{2}$');
      break;
    default:
      return 'Invalid date format';
  }

  if (!regex.hasMatch(value)) {
    return 'Enter a valid date in $dateFormat format';
  }

  int day, month, year;
  final parts = value.split(separator);

  switch (dateFormat) {
    case 'dd-mm-yyyy':
      day = int.parse(parts[0]);
      month = int.parse(parts[1]);
      year = int.parse(parts[2]);
      break;
    case 'mm-dd-yyyy':
      month = int.parse(parts[0]);
      day = int.parse(parts[1]);
      year = int.parse(parts[2]);
      break;
    case 'yyyy-mm-dd':
      year = int.parse(parts[0]);
      month = int.parse(parts[1]);
      day = int.parse(parts[2]);
      break;
    case 'dd/mm/yyyy':
      day = int.parse(parts[0]);
      month = int.parse(parts[1]);
      year = int.parse(parts[2]);
      break;
    case 'mm/dd/yyyy':
      month = int.parse(parts[0]);
      day = int.parse(parts[1]);
      year = int.parse(parts[2]);
      break;
    case 'yyyy/mm/dd':
      year = int.parse(parts[0]);
      month = int.parse(parts[1]);
      day = int.parse(parts[2]);
      break;
    default:
      return 'Invalid date format';
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



