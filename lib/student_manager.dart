// مدیریت دانشجویان: فهرست دانشجویان در حافظه، ثبت، جست‌وجو، ویرایش، حذف و آمار.
// بعد از هر تغییر، کل فهرست با StudentStorage در فایل ذخیره می‌شود.

import 'app_exceptions.dart';
import 'student.dart';
import 'student_storage.dart';
import 'utils.dart';
import 'validators.dart';

class StudentManager {
  final StudentStorage storage;

  /// فهرست دانشجویان در حافظه.
  /// خصوصی (_) است تا فقط از داخل همین کلاس تغییر کند.
  List<Student> _students = [];

  /// آیا فایل داده با موفقیت خوانده شده است؟
  bool _isLoaded = false;

  StudentManager(this.storage);

  /// تعداد دانشجویان.
  int get count => _students.length;

  /// خواندن دانشجویان از فایل. یک بار در شروع برنامه صدا زده می‌شود.
  Future<void> load() async {
    _students = await storage.load();
    _isLoaded = true;
  }

  /// همه دانشجویان، مرتب‌شده بر اساس شماره دانشجویی.
  List<Student> getAll() {
    final list = List<Student>.from(_students);
    _sortById(list);
    return list;
  }

  /// پیدا کردن دانشجو با شماره دانشجویی. اگر پیدا نشود null برمی‌گرداند.
  Student? findById(String studentId) {
    final id = normalizeDigits(studentId.trim());
    for (final student in _students) {
      if (student.studentId == id) {
        return student;
      }
    }
    return null;
  }

  /// ثبت دانشجوی جدید.
  Future<void> addStudent(Student student) async {
    _checkIsValid(student);
    if (findById(student.studentId) != null) {
      throw StudentException(
          'A student with ID ${student.studentId} already exists.');
    }
    _checkNationalIdIsFree(student);

    final newList = List<Student>.from(_students);
    newList.add(student);
    await _save(newList);
  }

  /// ذخیره اطلاعات تازه یک دانشجو. شماره دانشجویی عوض نمی‌شود.
  Future<void> updateStudent(Student student) async {
    _checkIsValid(student);
    final index = _indexOf(student.studentId);
    if (index == -1) {
      throw StudentException(
          'No student with ID ${student.studentId} was found.');
    }
    _checkNationalIdIsFree(student);

    final newList = List<Student>.from(_students);
    newList[index] = student;
    await _save(newList);
  }

  /// حذف دانشجو. دانشجوی حذف‌شده را برمی‌گرداند.
  Future<Student> deleteStudent(String studentId) async {
    final id = normalizeDigits(studentId.trim());
    final index = _indexOf(id);
    if (index == -1) {
      throw StudentException('No student with ID $id was found.');
    }

    final newList = List<Student>.from(_students);
    final removed = newList.removeAt(index);
    await _save(newList);
    return removed;
  }

  /// جست‌وجو در نام، رشته و شماره دانشجویی.
  /// حروف بزرگ و کوچک فرقی نمی‌کنند.
  List<Student> search(String text) {
    final query = normalizeDigits(text.trim()).toLowerCase();
    final result = <Student>[];
    for (final student in _students) {
      final matches = student.fullName.toLowerCase().contains(query) ||
          student.major.toLowerCase().contains(query) ||
          student.studentId.contains(query);
      if (matches) {
        result.add(student);
      }
    }
    _sortById(result);
    return result;
  }

  /// تعداد دانشجویان یک وضعیت، مثلاً تعداد دانشجویان فعال.
  int countByStatus(StudentStatus status) {
    var count = 0;
    for (final student in _students) {
      if (student.status == status) {
        count++;
      }
    }
    return count;
  }

  /// تعداد رشته‌های مختلف. Set هر رشته را فقط یک بار نگه می‌دارد.
  int countMajors() {
    final majors = <String>{};
    for (final student in _students) {
      majors.add(student.major);
    }
    return majors.length;
  }

  /// میانگین معدل دانشجویانی که معدل دارند.
  /// اگر هیچ دانشجویی معدل نداشته باشد، null برمی‌گرداند.
  double? averageGpa() {
    var sum = 0.0;
    var count = 0;
    for (final student in _students) {
      final gpa = student.gpa;
      if (gpa != null) {
        sum += gpa;
        count++;
      }
    }
    if (count == 0) {
      return null;
    }
    return sum / count;
  }

  /// اول فایل نوشته می‌شود و فقط اگر موفق بود، فهرست حافظه عوض می‌شود.
  /// اگر نوشتن خطا بدهد، خط آخر اجرا نمی‌شود و فهرست قبلی دست‌نخورده می‌ماند.
  Future<void> _save(List<Student> newList) async {
    // تا فایل خوانده نشده، چیزی نمی‌نویسیم؛ وگرنه اطلاعات قبلی فایل پاک می‌شد.
    if (!_isLoaded) {
      throw StorageException(
          'The data file has not been read yet, so nothing was saved.');
    }
    await storage.save(newList);
    _students = newList;
  }

  /// اگر اطلاعات دانشجو نادرست باشد، اولین خطا را پرتاب می‌کند.
  void _checkIsValid(Student student) {
    final errors = validateStudent(student);
    if (errors.isNotEmpty) {
      throw StudentException(errors.first);
    }
  }

  /// هر کد ملی فقط برای یک دانشجو مجاز است.
  void _checkNationalIdIsFree(Student student) {
    for (final other in _students) {
      if (other.nationalId == student.nationalId &&
          other.studentId != student.studentId) {
        throw StudentException('National ID ${student.nationalId} '
            'already belongs to student ${other.studentId}.');
      }
    }
  }

  /// جایگاه دانشجو در فهرست، یا -1 اگر پیدا نشود.
  int _indexOf(String studentId) {
    for (var i = 0; i < _students.length; i++) {
      if (_students[i].studentId == studentId) {
        return i;
      }
    }
    return -1;
  }

  /// شماره‌ها را به شکل عدد مقایسه می‌کنیم؛
  /// در مقایسه متنی «10001» قبل از «9999» قرار می‌گرفت.
  void _sortById(List<Student> list) {
    list.sort((a, b) {
      final first = int.tryParse(a.studentId) ?? 0;
      final second = int.tryParse(b.studentId) ?? 0;
      return first.compareTo(second);
    });
  }
}
