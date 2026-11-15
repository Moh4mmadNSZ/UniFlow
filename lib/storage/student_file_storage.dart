// لایه ذخیره‌سازی: فقط با فایل کار می‌کند.
// این کلاس می‌داند فایل کجاست، چطور خوانده و نوشته می‌شود و اگر خراب بود چه کند.
// قوانین برنامه (مثل یکتا بودن شماره دانشجویی) را نمی‌شناسد.

import 'dart:convert';
import 'dart:io';

import '../models/student.dart';
import '../utils/app_exceptions.dart';

/// نتیجه خواندن فایل: فهرست دانشجویان و یک هشدار اختیاری برای کاربر.
class LoadResult {
  final List<Student> students;
  final String? warning;

  LoadResult(this.students, {this.warning});
}

class StudentFileStorage {
  /// نسخه ساختار فایل. اگر روزی ساختار فایل عوض شود، این عدد را بالا می‌بریم.
  static const int schemaVersion = 1;
  static const String fileName = 'students.json';

  /// پوشه‌ای که فایل داده داخل آن است.
  final Directory directory;

  StudentFileStorage(this.directory);

  /// فایل اصلی داده.
  File get file => File('${directory.path}${Platform.pathSeparator}$fileName');

  /// خواندن همه دانشجویان از فایل.
  Future<LoadResult> readStudents() async {
    // ۱. اجرای اول برنامه: فایل هنوز ساخته نشده است.
    if (!await file.exists()) {
      return LoadResult([]);
    }

    // ۲. خواندن بایت‌های فایل. خطا در این مرحله یعنی مشکل دسترسی یا دیسک.
    List<int> bytes;
    try {
      bytes = await file.readAsBytes();
    } on FileSystemException catch (e) {
      throw StorageException('خواندن فایل داده ممکن نشد: ${e.message}');
    }

    // ۳. تبدیل بایت‌ها به متن و متن به دانشجو.
    // خطا در این مرحله یعنی محتوای فایل خراب است.
    try {
      final text = utf8.decode(bytes);
      if (text.trim().isEmpty) {
        return LoadResult([]); // فایل خالی مثل فهرست خالی است
      }
      final data = jsonDecode(text) as Map<String, dynamic>;
      final items = data['students'] as List<dynamic>;
      final students = <Student>[];
      for (final item in items) {
        students.add(Student.fromJson(item as Map<String, dynamic>));
      }
      return LoadResult(students);
    } catch (e) {
      final backupName = await _backupCorruptedFile();
      return LoadResult(
        [],
        warning: 'فایل داده خراب بود. محتوای قبلی با نام «$backupName» '
            'کنار گذاشته شد و برنامه با فهرست خالی شروع شد.',
      );
    }
  }

  /// فایل خراب را با نام دیگری کنار می‌گذارد تا هیچ‌وقت رونویسی نشود.
  Future<String> _backupCorruptedFile() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final backupName = 'students.corrupted-$stamp.json';
    try {
      await file.rename('${directory.path}${Platform.pathSeparator}$backupName');
    } on FileSystemException catch (e) {
      throw StorageException(
        'فایل داده خراب است و کنار گذاشتن آن هم ممکن نشد: ${e.message}',
      );
    }
    return backupName;
  }

  /// نوشتن همه دانشجویان در فایل.
  /// اول در یک فایل موقت می‌نویسیم و بعد آن را جایگزین فایل اصلی می‌کنیم.
  /// به این ترتیب اگر برنامه وسط نوشتن بسته شود، فایل اصلی سالم می‌ماند.
  Future<void> writeStudents(List<Student> students) async {
    final items = <Map<String, dynamic>>[];
    for (final student in students) {
      items.add(student.toJson());
    }
    final data = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'students': items,
    };
    // withIndent فایل را مرتب و خوانا می‌نویسد.
    final text = const JsonEncoder.withIndent('  ').convert(data);

    try {
      await directory.create(recursive: true);
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(text, flush: true);
      await tempFile.rename(file.path);
    } on FileSystemException catch (e) {
      throw StorageException('ذخیره در فایل انجام نشد: ${e.message}');
    }
  }

  /// متن خام فایل، برای نمایش در صفحه «فایل داده».
  Future<String> readRawText() async {
    if (!await file.exists()) {
      return '';
    }
    try {
      return await file.readAsString();
    } on FileSystemException catch (e) {
      throw StorageException('خواندن فایل داده ممکن نشد: ${e.message}');
    }
  }

  /// اندازه فایل به بایت. اگر فایل وجود نداشته باشد صفر است.
  Future<int> fileSize() async {
    if (!await file.exists()) {
      return 0;
    }
    return file.length();
  }
}
