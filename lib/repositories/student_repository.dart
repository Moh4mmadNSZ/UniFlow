// لایه Repository: فهرست دانشجویان را در حافظه نگه می‌دارد
// و بعد از هر تغییر، کل فهرست را به Storage می‌دهد تا در فایل ذخیره شود.

import '../models/student.dart';
import '../storage/student_file_storage.dart';
import '../utils/app_exceptions.dart';

class StudentRepository {
  final StudentFileStorage _storage;

  /// فهرست اصلی دانشجویان در حافظه.
  /// خصوصی (_) است تا فقط از داخل همین کلاس تغییر کند.
  List<Student> _students = [];

  /// آیا اطلاعات با موفقیت از فایل خوانده شده است؟
  bool _isLoaded = false;

  StudentRepository(this._storage);

  bool get isLoaded => _isLoaded;

  /// یک کپی فقط‌خواندنی از فهرست؛ بیرون از این کلاس نمی‌توان آن را تغییر داد.
  List<Student> get all => List.unmodifiable(_students);

  /// مسیر کامل فایل داده.
  String get filePath => _storage.file.path;

  /// خواندن اطلاعات از فایل در شروع برنامه. هشدار احتمالی را برمی‌گرداند.
  Future<String?> load() async {
    final result = await _storage.readStudents();
    _students = result.students;
    _isLoaded = true;
    return result.warning;
  }

  /// پیدا کردن دانشجو با شماره دانشجویی. اگر پیدا نشود null برمی‌گرداند.
  Student? findById(String studentId) {
    for (final student in _students) {
      if (student.studentId == studentId) {
        return student;
      }
    }
    return null;
  }

  Future<void> add(Student student) async {
    _checkLoaded();
    final newList = List<Student>.from(_students);
    newList.add(student);
    await _save(newList);
  }

  Future<void> update(Student student) async {
    _checkLoaded();
    final index = _indexOf(student.studentId);
    if (index == -1) {
      throw StudentNotFoundException(student.studentId);
    }
    final newList = List<Student>.from(_students);
    newList[index] = student;
    await _save(newList);
  }

  Future<void> delete(String studentId) async {
    _checkLoaded();
    final index = _indexOf(studentId);
    if (index == -1) {
      throw StudentNotFoundException(studentId);
    }
    final newList = List<Student>.from(_students);
    newList.removeAt(index);
    await _save(newList);
  }

  Future<String> readRawFile() => _storage.readRawText();

  Future<int> fileSize() => _storage.fileSize();

  /// اول فهرست جدید در فایل نوشته می‌شود و فقط اگر موفق بود، حافظه به‌روز می‌شود.
  /// اگر نوشتن خطا بدهد، خط دوم اجرا نمی‌شود و فهرست قبلی دست‌نخورده می‌ماند.
  Future<void> _save(List<Student> newList) async {
    await _storage.writeStudents(newList);
    _students = newList;
  }

  int _indexOf(String studentId) {
    for (var i = 0; i < _students.length; i++) {
      if (_students[i].studentId == studentId) {
        return i;
      }
    }
    return -1;
  }

  /// تا وقتی خواندن فایل موفق نشده، نوشتن ممنوع است؛
  /// وگرنه اولین ثبت، کل فایل قبلی را با یک فهرست تک‌نفره رونویسی می‌کرد.
  void _checkLoaded() {
    if (!_isLoaded) {
      throw StorageException(
        'اطلاعات هنوز از فایل خوانده نشده است؛ برای جلوگیری از پاک شدن داده‌ها، چیزی ذخیره نشد.',
      );
    }
  }
}
