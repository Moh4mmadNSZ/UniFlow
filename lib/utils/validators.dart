// قوانین بررسی درستی ورودی‌ها.
// هر تابع اگر ورودی درست باشد null برمی‌گرداند و اگر نادرست باشد، متن خطا را.
// TextFormField در Flutter هم دقیقاً همین شکل را برای validator می‌خواهد.

import '../models/student.dart';
import 'faculties.dart';
import 'text_utils.dart';

class Validators {
  static final RegExp _onlyDigits = RegExp(r'^[0-9]+$');
  static final RegExp _nationalId = RegExp(r'^[0-9]{10}$');
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phone = RegExp(r'^09[0-9]{9}$');
  static final RegExp _twoDecimals = RegExp(r'^[0-9]{1,2}(\.[0-9]{1,2})?$');
  // حروف فارسی (محدوده یونیکد 0600 تا 06FF)، حروف انگلیسی، فاصله و نیم‌فاصله
  static final RegExp _letters = RegExp(r'^[؀-ۿa-zA-Z ‌]+$');
  static final RegExp _anyDigit = RegExp(r'[0-9]');

  /// شماره دانشجویی: فقط رقم، بین ۴ تا ۱۰ رقم.
  static String? studentId(String? value) {
    final text = normalizeDigits(value ?? '').trim();
    if (text.isEmpty) {
      return 'شماره دانشجویی را وارد کنید';
    }
    if (!_onlyDigits.hasMatch(text)) {
      return 'شماره دانشجویی فقط باید رقم باشد';
    }
    if (text.length < 4 || text.length > 10) {
      return 'شماره دانشجویی باید بین ۴ تا ۱۰ رقم باشد';
    }
    return null;
  }

  /// نام یا نام خانوادگی: فقط حروف، با طولی بین min و max.
  static String? name(
    String? value, {
    required String fieldName,
    int min = 2,
    int max = 30,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '$fieldName را وارد کنید';
    }
    if (!_letters.hasMatch(text) || _anyDigit.hasMatch(normalizeDigits(text))) {
      return '$fieldName فقط باید شامل حروف باشد';
    }
    if (text.length < min || text.length > max) {
      return '$fieldName باید بین $min تا $max حرف باشد';
    }
    return null;
  }

  /// کد ملی: دقیقاً ۱۰ رقم.
  static String? nationalId(String? value) {
    final text = normalizeDigits(value ?? '').trim();
    if (text.isEmpty) {
      return 'کد ملی را وارد کنید';
    }
    if (!_nationalId.hasMatch(text)) {
      return 'کد ملی باید دقیقاً ۱۰ رقم باشد';
    }
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'ایمیل را وارد کنید';
    }
    if (!_email.hasMatch(text)) {
      return 'ایمیل معتبر نیست (نمونه درست: name@example.com)';
    }
    return null;
  }

  /// شماره موبایل ایران: ۱۱ رقم که با 09 شروع می‌شود.
  static String? phone(String? value) {
    final text = normalizeDigits(value ?? '').trim();
    if (text.isEmpty) {
      return 'شماره موبایل را وارد کنید';
    }
    if (!_phone.hasMatch(text)) {
      return 'شماره موبایل باید ۱۱ رقم باشد و با 09 شروع شود';
    }
    return null;
  }

  /// ترم: عدد صحیح بین ۱ تا ۱۲.
  static String? semester(String? value) {
    final text = normalizeDigits(value ?? '').trim();
    if (text.isEmpty) {
      return 'ترم را وارد کنید';
    }
    final number = int.tryParse(text);
    if (number == null) {
      return 'ترم باید یک عدد صحیح باشد';
    }
    if (number < 1 || number > 12) {
      return 'ترم باید بین ۱ تا ۱۲ باشد';
    }
    return null;
  }

  /// معدل اختیاری است: خالی بودنش خطا نیست.
  /// اگر وارد شود باید بین ۰ تا ۲۰ باشد و حداکثر دو رقم اعشار داشته باشد.
  static String? gpa(String? value) {
    final text = normalizeDigits(value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final number = double.tryParse(text);
    if (number == null) {
      return 'معدل باید عدد باشد (مثال: 17.25)';
    }
    if (number < 0 || number > 20) {
      return 'معدل باید بین ۰ تا ۲۰ باشد';
    }
    if (!_twoDecimals.hasMatch(text)) {
      return 'معدل حداکثر دو رقم اعشار دارد';
    }
    return null;
  }

  /// آدرس اختیاری است و حداکثر ۲۰۰ حرف دارد.
  static String? address(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'آدرس حداکثر ۲۰۰ حرف است';
    }
    return null;
  }

  /// تاریخ تولد: در گذشته، با حداقل سن ۱۵ سال.
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'تاریخ تولد را انتخاب کنید';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'تاریخ تولد نمی‌تواند در آینده باشد';
    }
    if (ageOn(value, now) < 15) {
      return 'سن دانشجو باید حداقل ۱۵ سال باشد';
    }
    return null;
  }

  /// تاریخ ورود: در آینده نباشد و بعد از تاریخ تولد باشد.
  static String? enrollmentDate(DateTime? value, DateTime? dateOfBirth) {
    if (value == null) {
      return 'تاریخ ورود را انتخاب کنید';
    }
    if (value.isAfter(DateTime.now())) {
      return 'تاریخ ورود نمی‌تواند در آینده باشد';
    }
    if (dateOfBirth != null && !value.isAfter(dateOfBirth)) {
      return 'تاریخ ورود باید بعد از تاریخ تولد باشد';
    }
    return null;
  }

  /// سن کامل (به سال) در یک تاریخ مشخص.
  static int ageOn(DateTime birthDate, DateTime date) {
    var age = date.year - birthDate.year;
    final hadBirthday = date.month > birthDate.month ||
        (date.month == birthDate.month && date.day >= birthDate.day);
    if (!hadBirthday) {
      age--;
    }
    return age;
  }

  static String? faculty(String? value) {
    if (value == null || !facultyMajors.containsKey(value)) {
      return 'دانشکده را انتخاب کنید';
    }
    return null;
  }

  /// رشته باید یکی از رشته‌های همان دانشکده باشد.
  static String? major(String? value, String? faculty) {
    if (value == null || !majorsOf(faculty).contains(value)) {
      return 'رشته را از فهرست انتخاب کنید';
    }
    return null;
  }

  /// همه قوانین را روی یک دانشجوی کامل اجرا می‌کند و فهرست خطاها را برمی‌گرداند.
  /// فهرست خالی یعنی همه اطلاعات درست است.
  static List<String> validateStudent(Student student) {
    final results = <String?>[
      studentId(student.studentId),
      name(student.firstName, fieldName: 'نام'),
      name(student.lastName, fieldName: 'نام خانوادگی', max: 40),
      nationalId(student.nationalId),
      dateOfBirth(student.dateOfBirth),
      email(student.email),
      phone(student.phone),
      faculty(student.faculty),
      major(student.major, student.faculty),
      semester(student.semester.toString()),
      enrollmentDate(student.enrollmentDate, student.dateOfBirth),
      gpa(student.gpa?.toString()),
      address(student.address),
    ];
    final errors = <String>[];
    for (final result in results) {
      if (result != null) {
        errors.add(result);
      }
    }
    return errors;
  }
}
