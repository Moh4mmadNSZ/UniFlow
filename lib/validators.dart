// قوانین بررسی درستی ورودی‌ها.
// هر تابع اگر ورودی درست باشد null برمی‌گرداند و اگر نادرست باشد، متن خطا را.

import 'faculties.dart';
import 'student.dart';

/// شماره دانشجویی: فقط رقم، از ۴ تا ۱۰ رقم.
String? validateStudentId(String value) {
  if (value.isEmpty) {
    return 'Student ID is required.';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Student ID must contain only digits.';
  }
  if (value.length < 4 || value.length > 10) {
    return 'Student ID must be 4 to 10 digits long.';
  }
  return null;
}

/// نام یا نام خانوادگی: فقط حروف فارسی یا انگلیسی، از ۲ تا ۳۰ حرف.
String? validateName(String value, String fieldName) {
  if (value.isEmpty) {
    return '$fieldName is required.';
  }
  // حروف انگلیسی، حروف فارسی (محدوده یونیکد 0600 تا 06FF)، فاصله و نیم‌فاصله
  final onlyLetters = RegExp(r'^[a-zA-Z؀-ۿ ‌]+$');
  final hasDigit = RegExp(r'[0-9۰-۹]');
  if (!onlyLetters.hasMatch(value) || hasDigit.hasMatch(value)) {
    return '$fieldName can only contain letters.';
  }
  if (value.length < 2 || value.length > 30) {
    return '$fieldName must be 2 to 30 letters long.';
  }
  return null;
}

/// کد ملی: دقیقاً ۱۰ رقم.
String? validateNationalId(String value) {
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
    return 'National ID must be exactly 10 digits.';
  }
  return null;
}

String? validateEmail(String value) {
  if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
    return 'Email is not valid. Example: name@example.com';
  }
  return null;
}

/// شماره موبایل ایران: ۱۱ رقم که با 09 شروع می‌شود.
String? validatePhone(String value) {
  if (!RegExp(r'^09[0-9]{9}$').hasMatch(value)) {
    return 'Phone must be 11 digits and start with 09.';
  }
  return null;
}

/// ترم: عدد صحیح از ۱ تا ۱۲.
String? validateSemester(String value) {
  final number = int.tryParse(value);
  if (number == null) {
    return 'Semester must be a whole number.';
  }
  if (number < 1 || number > 12) {
    return 'Semester must be between 1 and 12.';
  }
  return null;
}

/// معدل اختیاری است: خالی بودنش خطا نیست.
/// اگر وارد شود باید بین ۰ تا ۲۰ باشد و حداکثر دو رقم اعشار داشته باشد.
String? validateGpa(String value) {
  if (value.isEmpty) {
    return null;
  }
  final number = double.tryParse(value);
  if (number == null) {
    return 'GPA must be a number, like 17.25';
  }
  if (number < 0 || number > 20) {
    return 'GPA must be between 0 and 20.';
  }
  if (!RegExp(r'^[0-9]{1,2}(\.[0-9]{1,2})?$').hasMatch(value)) {
    return 'GPA can have at most two decimal places.';
  }
  return null;
}

/// آدرس اختیاری است و حداکثر ۲۰۰ حرف دارد.
String? validateAddress(String value) {
  if (value.length > 200) {
    return 'Address can be at most 200 characters.';
  }
  return null;
}

/// تاریخ تولد: نباید در آینده باشد و سن باید حداقل ۱۵ سال باشد.
/// اگر date برابر null باشد یعنی متن واردشده تاریخ درستی نبوده است.
String? validateDateOfBirth(DateTime? date) {
  if (date == null) {
    return 'Enter a valid date like 2004-03-21.';
  }
  final today = DateTime.now();
  if (date.isAfter(today)) {
    return 'Date of birth cannot be in the future.';
  }
  if (ageOn(date, today) < 15) {
    return 'The student must be at least 15 years old.';
  }
  return null;
}

/// تاریخ ورود: نباید در آینده باشد و باید بعد از تاریخ تولد باشد.
String? validateEnrollmentDate(DateTime? date, DateTime dateOfBirth) {
  if (date == null) {
    return 'Enter a valid date like 2024-09-22.';
  }
  if (date.isAfter(DateTime.now())) {
    return 'Enrollment date cannot be in the future.';
  }
  if (!date.isAfter(dateOfBirth)) {
    return 'Enrollment date must be after the date of birth.';
  }
  return null;
}

/// دانشکده باید در فهرست باشد و رشته باید متعلق به همان دانشکده باشد.
String? validateFacultyAndMajor(String faculty, String major) {
  final majors = facultyMajors[faculty];
  if (majors == null) {
    return 'Unknown faculty: $faculty';
  }
  if (!majors.contains(major)) {
    return '$major is not a major of $faculty.';
  }
  return null;
}

/// سن کامل (به سال) در یک تاریخ مشخص.
int ageOn(DateTime birthDate, DateTime date) {
  var age = date.year - birthDate.year;
  final hadBirthday = date.month > birthDate.month ||
      (date.month == birthDate.month && date.day >= birthDate.day);
  if (!hadBirthday) {
    age--;
  }
  return age;
}

/// همه قوانین بالا را روی یک دانشجوی کامل اجرا می‌کند.
/// فهرست خطاها را برمی‌گرداند؛ فهرست خالی یعنی همه چیز درست است.
List<String> validateStudent(Student student) {
  final results = <String?>[
    validateStudentId(student.studentId),
    validateName(student.firstName, 'First name'),
    validateName(student.lastName, 'Last name'),
    validateNationalId(student.nationalId),
    validateDateOfBirth(student.dateOfBirth),
    validateEmail(student.email),
    validatePhone(student.phone),
    validateFacultyAndMajor(student.faculty, student.major),
    validateSemester(student.semester.toString()),
    validateEnrollmentDate(student.enrollmentDate, student.dateOfBirth),
    validateGpa(student.gpa?.toString() ?? ''),
    validateAddress(student.address ?? ''),
  ];
  final errors = <String>[];
  for (final result in results) {
    if (result != null) {
      errors.add(result);
    }
  }
  return errors;
}
