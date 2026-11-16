// خواندن ورودی از کاربر در ترمینال.

import 'dart:convert';
import 'dart:io';

import 'console_output.dart';
import 'utils.dart';

/// یک خط از کاربر می‌خواند. فاصله‌های اول و آخر حذف و ارقام فارسی انگلیسی می‌شوند.
/// اگر ورودی تمام شود (مثلاً با Ctrl+D)، برنامه بسته می‌شود؛
/// اطلاعات قبلاً بعد از هر تغییر ذخیره شده‌اند.
String readLine(String prompt) {
  stdout.write(prompt);
  final line = stdin.readLineSync(encoding: utf8);
  if (line == null) {
    print('');
    printInfo('Input ended. Goodbye!');
    exit(0);
  }
  return normalizeDigits(line.trim());
}

/// سؤال را تا وقتی جواب درست داده نشده تکرار می‌کند.
/// validator برای جواب درست null و برای جواب نادرست متن خطا برمی‌گرداند.
String askUntilValid(String prompt, String? Function(String value) validator) {
  while (true) {
    final value = readLine(prompt);
    final error = validator(value);
    if (error == null) {
      return value;
    }
    printError(error);
  }
}

/// برای ویرایش: مقدار فعلی را نشان می‌دهد و اگر کاربر فقط Enter بزند، همان را نگه می‌دارد.
String askOrKeep(
    String label, String current, String? Function(String value) validator) {
  final shown = current.isEmpty ? 'none' : current;
  while (true) {
    final value = readLine('$label [$shown]: ');
    if (value.isEmpty) {
      return current;
    }
    final error = validator(value);
    if (error == null) {
      return value;
    }
    printError(error);
  }
}

/// یک تاریخ به شکل YYYY-MM-DD می‌پرسد.
/// اگر defaultValue داده شده باشد و کاربر فقط Enter بزند، همان برگردانده می‌شود.
DateTime askDate(String prompt, String? Function(DateTime? date) validator,
    {DateTime? defaultValue}) {
  while (true) {
    final text = readLine(prompt);
    DateTime? date;
    if (text.isEmpty && defaultValue != null) {
      date = defaultValue;
    } else {
      date = parseDate(text);
    }
    final error = validator(date);
    if (error == null && date != null) {
      return date;
    }
    printError(error ?? 'Enter a valid date like 2004-03-21.');
  }
}

/// فهرست گزینه‌ها را شماره‌دار نشان می‌دهد و شماره گزینه انتخاب‌شده (از صفر) را برمی‌گرداند.
/// اگر defaultIndex داده شده باشد، Enter یعنی همان گزینه.
int askChoice(String title, List<String> options, {int? defaultIndex}) {
  print(title);
  for (var i = 0; i < options.length; i++) {
    print('  ${i + 1}) ${options[i]}');
  }
  final hint = defaultIndex == null ? '' : ' [${defaultIndex + 1}]';
  while (true) {
    final text = readLine('Choose 1-${options.length}$hint: ');
    if (text.isEmpty && defaultIndex != null) {
      return defaultIndex;
    }
    final number = int.tryParse(text);
    if (number != null && number >= 1 && number <= options.length) {
      return number - 1;
    }
    printError('Please enter a number from 1 to ${options.length}.');
  }
}

/// سؤال بله یا خیر. فقط y یا n پذیرفته می‌شود.
bool askYesNo(String question) {
  while (true) {
    final answer = readLine('$question (y/n): ').toLowerCase();
    if (answer == 'y' || answer == 'yes') {
      return true;
    }
    if (answer == 'n' || answer == 'no') {
      return false;
    }
    printError('Please answer y or n.');
  }
}

/// تا کاربر Enter نزده صبر می‌کند تا نتیجه را بخواند.
void waitForEnter() {
  readLine('\nPress Enter to return to the menu...');
}
