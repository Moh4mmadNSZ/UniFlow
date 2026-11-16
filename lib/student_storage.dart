// خواندن و نوشتن فهرست دانشجویان در فایل JSON.
// این کلاس فقط با فایل کار می‌کند و قوانین برنامه (مثل یکتا بودن شماره) را نمی‌شناسد.

import 'dart:convert';
import 'dart:io';

import 'app_exceptions.dart';
import 'student.dart';

class StudentStorage {
  /// مسیر فایل داده، مثلاً data/students.json
  final String filePath;

  /// اگر هنگام خواندن فایل مشکلی پیش آمده باشد (مثلاً فایل خراب بوده)، پیامش این‌جاست.
  String? warning;

  StudentStorage(this.filePath);

  File get file => File(filePath);

  /// همه دانشجویان را از فایل می‌خواند.
  Future<List<Student>> load() async {
    // ۱. اجرای اول برنامه: فایل هنوز ساخته نشده است.
    if (!await file.exists()) {
      return [];
    }

    // ۲. خواندن متن فایل. خطا در این مرحله یعنی مشکل دسترسی یا دیسک.
    String text;
    try {
      text = await file.readAsString();
    } on FileSystemException catch (e) {
      throw StorageException('Could not read $filePath: ${e.message}');
    }

    // ۳. فایل خالی یعنی هنوز دانشجویی ثبت نشده است.
    if (text.trim().isEmpty) {
      return [];
    }

    // ۴. تبدیل متن JSON به فهرست دانشجویان. خطا در این مرحله یعنی فایل خراب است.
    try {
      final items = jsonDecode(text) as List<dynamic>;
      final students = <Student>[];
      for (final item in items) {
        students.add(Student.fromJson(item as Map<String, dynamic>));
      }
      return students;
    } catch (error) {
      // فایل خراب را پاک نمی‌کنیم؛ با نام دیگری کنار می‌گذاریم تا محتوایش از دست نرود.
      final backupPath =
          '$filePath.broken-${DateTime.now().millisecondsSinceEpoch}';
      try {
        await file.rename(backupPath);
      } on FileSystemException catch (e) {
        throw StorageException(
            '$filePath is damaged and could not be moved: ${e.message}');
      }
      warning = 'The data file was damaged. It was saved as $backupPath '
          'and the program started with an empty list.';
      return [];
    }
  }

  /// همه دانشجویان را در فایل می‌نویسد.
  /// اول در یک فایل موقت می‌نویسیم و بعد آن را جای فایل اصلی می‌گذاریم؛
  /// اگر برنامه وسط نوشتن بسته شود، فایل اصلی سالم می‌ماند.
  Future<void> save(List<Student> students) async {
    final items = <Map<String, dynamic>>[];
    for (final student in students) {
      items.add(student.toJson());
    }
    // withIndent فایل را مرتب و خوانا می‌نویسد.
    final text = const JsonEncoder.withIndent('  ').convert(items);

    try {
      await file.parent.create(recursive: true);
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(text, flush: true);
      await tempFile.rename(filePath);
    } on FileSystemException catch (e) {
      throw StorageException('Could not save $filePath: ${e.message}');
    }
  }
}
