// لایه Service: قوانین برنامه اینجاست.
// اعتبارسنجی، جلوگیری از اطلاعات تکراری، جست‌وجو، فیلتر، مرتب‌سازی و آمار.
// این کلاس نمی‌داند اطلاعات در فایل ذخیره می‌شود یا جای دیگر؛
// فقط با Repository کار می‌کند.

import '../models/student.dart';
import '../repositories/student_repository.dart';
import '../utils/app_exceptions.dart';
import '../utils/text_utils.dart';
import '../utils/validators.dart';

/// گزینه‌های مرتب‌سازی فهرست دانشجویان.
enum SortOption { studentId, lastName, newest }

/// متن فارسی هر گزینه مرتب‌سازی.
String sortLabel(SortOption option) {
  switch (option) {
    case SortOption.studentId:
      return 'شماره دانشجویی';
    case SortOption.lastName:
      return 'نام خانوادگی';
    case SortOption.newest:
      return 'جدیدترین ثبت';
  }
}

/// آمار صفحه اصلی.
class DashboardStats {
  final int total;
  final int active;
  final int suspended;
  final int graduated;
  final int majorCount;
  final double? averageGpa; // اگر هیچ دانشجویی معدل نداشته باشد null است

  DashboardStats({
    required this.total,
    required this.active,
    required this.suspended,
    required this.graduated,
    required this.majorCount,
    required this.averageGpa,
  });
}

class StudentService {
  final StudentRepository _repository;

  /// متن آخرین عملیات موفق، برای نمایش در صفحه اصلی.
  String? _lastOperation;

  /// هشداری که هنگام خواندن فایل پیش آمده است (مثلاً فایل خراب).
  String? _loadWarning;

  StudentService(this._repository);

  String? get lastOperation => _lastOperation;

  String? get loadWarning => _loadWarning;

  String get dataFilePath => _repository.filePath;

  /// همه دانشجویان.
  List<Student> get allStudents => _repository.all;

  /// خواندن اطلاعات از فایل. اگر قبلاً خوانده شده باشد، دوباره نمی‌خواند.
  Future<void> init() async {
    if (_repository.isLoaded) {
      return;
    }
    _loadWarning = await _repository.load();
  }

  /// پیدا کردن دانشجو با شماره دانشجویی (ارقام فارسی هم پذیرفته می‌شود).
  Student? findById(String studentId) {
    return _repository.findById(normalizeDigits(studentId).trim());
  }

  /// ثبت دانشجوی جدید.
  Future<void> addStudent(Student student) async {
    _validate(student);
    if (_repository.findById(student.studentId) != null) {
      throw DuplicateStudentException(
        'دانشجویی با شماره دانشجویی ${student.studentId} قبلاً ثبت شده است',
      );
    }
    _checkNationalIdIsFree(student);
    await _repository.add(student);
    _lastOperation = 'ثبت دانشجو ${student.studentId} (${student.fullName})';
  }

  /// ذخیره تغییرات یک دانشجو.
  Future<void> updateStudent(Student student) async {
    _validate(student);
    _checkNationalIdIsFree(student);
    await _repository.update(student);
    _lastOperation = 'ویرایش دانشجو ${student.studentId} (${student.fullName})';
  }

  /// حذف دانشجو.
  Future<void> deleteStudent(String studentId) async {
    final id = normalizeDigits(studentId).trim();
    final student = _repository.findById(id);
    if (student == null) {
      throw StudentNotFoundException(id);
    }
    await _repository.delete(id);
    _lastOperation = 'حذف دانشجو $id (${student.fullName})';
  }

  /// جست‌وجو، فیلتر و مرتب‌سازی.
  /// متن جست‌وجو در نام، نام خانوادگی، رشته و شماره دانشجویی گشته می‌شود.
  List<Student> search({
    String query = '',
    StudentStatus? status,
    String? major,
    SortOption sortBy = SortOption.studentId,
  }) {
    final text = normalizeDigits(query).trim().toLowerCase();
    final result = <Student>[];
    for (final student in _repository.all) {
      if (status != null && student.status != status) {
        continue;
      }
      if (major != null && student.major != major) {
        continue;
      }
      if (text.isNotEmpty && !_matches(student, text)) {
        continue;
      }
      result.add(student);
    }
    _sort(result, sortBy);
    return result;
  }

  /// آمار صفحه اصلی.
  DashboardStats getStats() {
    final students = _repository.all;
    var active = 0;
    var suspended = 0;
    var graduated = 0;
    var gpaSum = 0.0;
    var gpaCount = 0;
    final majors = <String>{}; // Set: هر رشته فقط یک بار شمرده می‌شود

    for (final student in students) {
      switch (student.status) {
        case StudentStatus.active:
          active++;
        case StudentStatus.suspended:
          suspended++;
        case StudentStatus.graduated:
          graduated++;
      }
      majors.add(student.major);
      final gpa = student.gpa;
      if (gpa != null) {
        gpaSum += gpa;
        gpaCount++;
      }
    }

    return DashboardStats(
      total: students.length,
      active: active,
      suspended: suspended,
      graduated: graduated,
      majorCount: majors.length,
      averageGpa: gpaCount == 0 ? null : gpaSum / gpaCount,
    );
  }

  /// رشته‌هایی که دست‌کم یک دانشجو دارند، به ترتیب الفبا (برای فیلتر فهرست).
  List<String> majorsInUse() {
    final majors = <String>{};
    for (final student in _repository.all) {
      majors.add(student.major);
    }
    final list = majors.toList();
    list.sort(comparePersian);
    return list;
  }

  Future<String> readDataFileText() => _repository.readRawFile();

  Future<int> dataFileSize() => _repository.fileSize();

  /// اگر اطلاعات نادرست باشد، اولین خطا را به شکل ValidationException پرتاب می‌کند.
  void _validate(Student student) {
    final errors = Validators.validateStudent(student);
    if (errors.isNotEmpty) {
      throw ValidationException(errors.first);
    }
  }

  /// هر کد ملی فقط برای یک دانشجو مجاز است.
  void _checkNationalIdIsFree(Student student) {
    for (final other in _repository.all) {
      if (other.nationalId == student.nationalId &&
          other.studentId != student.studentId) {
        throw DuplicateStudentException(
          'کد ملی ${student.nationalId} قبلاً برای دانشجوی ${other.studentId} ثبت شده است',
        );
      }
    }
  }

  bool _matches(Student student, String text) {
    return student.fullName.toLowerCase().contains(text) ||
        student.major.contains(text) ||
        student.studentId.contains(text);
  }

  void _sort(List<Student> list, SortOption sortBy) {
    switch (sortBy) {
      case SortOption.studentId:
        // شماره‌ها را به شکل عدد مقایسه می‌کنیم؛
        // در مقایسه متنی «10001» قبل از «9999» قرار می‌گرفت.
        list.sort((a, b) {
          final first = int.tryParse(a.studentId) ?? 0;
          final second = int.tryParse(b.studentId) ?? 0;
          return first.compareTo(second);
        });
      case SortOption.lastName:
        list.sort((a, b) {
          final byLastName = comparePersian(a.lastName, b.lastName);
          if (byLastName != 0) {
            return byLastName;
          }
          return comparePersian(a.firstName, b.firstName);
        });
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }
}
