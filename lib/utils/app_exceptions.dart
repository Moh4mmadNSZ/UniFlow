// خطاهای اختصاصی برنامه.
// هر خطا یک پیام فارسی دارد که مستقیم به کاربر نشان داده می‌شود.

/// کلاس پایه همه خطاهای برنامه.
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// ورودی نامعتبر است (مثلاً معدل بیشتر از ۲۰).
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// شماره دانشجویی یا کد ملی تکراری است.
class DuplicateStudentException extends AppException {
  DuplicateStudentException(super.message);
}

/// دانشجویی با این شماره وجود ندارد.
class StudentNotFoundException extends AppException {
  StudentNotFoundException(String studentId)
      : super('دانشجویی با شماره دانشجویی $studentId پیدا نشد');
}

/// خواندن یا نوشتن فایل داده با مشکل روبه‌رو شد.
class StorageException extends AppException {
  StorageException(super.message);
}
