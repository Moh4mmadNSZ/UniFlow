// خطاهای اختصاصی برنامه. هر خطا یک پیام دارد که به کاربر نشان داده می‌شود.

/// خطای قوانین برنامه، مثل شماره دانشجویی تکراری یا دانشجویی که پیدا نشد.
class StudentException implements Exception {
  final String message;

  StudentException(this.message);

  @override
  String toString() => message;
}

/// خطای خواندن یا نوشتن فایل داده.
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}
