// نمایش اطلاعات در ترمینال: پیام‌ها، جدول دانشجویان و جزئیات یک دانشجو.

import 'dart:io';

import 'student.dart';
import 'utils.dart';

/// رنگ‌ها فقط وقتی استفاده می‌شوند که خروجی واقعاً یک ترمینال باشد.
final bool _useColors = stdout.hasTerminal && stdout.supportsAnsiEscapes;

/// متن را با کد رنگ ANSI رنگی می‌کند.
String _color(String text, String code) {
  if (!_useColors) {
    return text;
  }
  return '\x1B[${code}m$text\x1B[0m';
}

void printTitle(String text) {
  print('');
  print(_color('=== $text ===', '1;36')); // فیروزه‌ای پررنگ
}

void printSuccess(String text) => print(_color('OK: $text', '32')); // سبز

void printError(String text) => print(_color('Error: $text', '31')); // قرمز

void printWarning(String text) => print(_color('Warning: $text', '33')); // زرد

void printInfo(String text) => print(text);

/// پهنای ستون‌های جدول: شماره، نام، رشته، ترم، وضعیت، معدل.
const List<int> _columnWidths = [11, 20, 22, 4, 11, 6];

/// جدول دانشجویان با ستون‌های شماره، نام، رشته، ترم، وضعیت و معدل.
void printStudentTable(List<Student> students) {
  final header = _tableRow(['ID', 'Name', 'Major', 'Sem', 'Status', 'GPA']);
  print(header);
  print('-' * header.length);
  for (final student in students) {
    final gpa = student.gpa;
    print(_tableRow([
      student.studentId,
      _fit(student.fullName, 19),
      _fit(student.major, 21),
      '${student.semester}',
      statusLabel(student.status),
      gpa == null ? '-' : gpa.toStringAsFixed(2),
    ]));
  }
}

/// یک ردیف جدول: هر خانه با فاصله تا پهنای ستون خودش پر می‌شود.
String _tableRow(List<String> cells) {
  final buffer = StringBuffer();
  for (var i = 0; i < cells.length; i++) {
    buffer.write(cells[i].padRight(_columnWidths[i]));
  }
  return buffer.toString().trimRight();
}

/// همه اطلاعات یک دانشجو، هر کدام در یک خط.
void printStudentDetails(Student student) {
  final gpa = student.gpa;
  _printRow('Student ID', student.studentId);
  _printRow('Name', student.fullName);
  _printRow('National ID', student.nationalId);
  _printRow('Date of birth', formatDate(student.dateOfBirth));
  _printRow('Email', student.email);
  _printRow('Phone', student.phone);
  _printRow('Address', student.address ?? '-');
  _printRow('Faculty', student.faculty);
  _printRow('Major', student.major);
  _printRow('Semester', '${student.semester}');
  _printRow('Enrollment date', formatDate(student.enrollmentDate));
  _printRow('Status', statusLabel(student.status));
  _printRow('GPA', gpa == null ? 'not set yet' : gpa.toStringAsFixed(2));
  _printRow('Registered at', formatDateTime(student.createdAt));
  _printRow('Last updated', formatDateTime(student.updatedAt));
}

void _printRow(String label, String value) {
  print('  ${label.padRight(16)}: $value');
}

/// اگر متن بلندتر از max باشد کوتاهش می‌کند تا ستون‌های جدول به هم نریزند.
String _fit(String text, int max) {
  if (text.length <= max) {
    return text;
  }
  return '${text.substring(0, max - 3)}...';
}
