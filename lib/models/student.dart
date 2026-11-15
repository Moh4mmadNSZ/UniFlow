// مدل داده دانشجو.
// این فایل فقط «شکل» اطلاعات یک دانشجو را تعریف می‌کند
// و نمی‌داند اطلاعات کجا و چطور ذخیره می‌شود.

import '../utils/text_utils.dart';

/// وضعیت تحصیلی دانشجو. فقط همین سه مقدار مجاز است.
enum StudentStatus { active, suspended, graduated }

/// متن فارسی هر وضعیت، برای نمایش در رابط کاربری.
String statusLabel(StudentStatus status) {
  switch (status) {
    case StudentStatus.active:
      return 'فعال';
    case StudentStatus.suspended:
      return 'تعلیق';
    case StudentStatus.graduated:
      return 'فارغ‌التحصیل';
  }
}

/// اطلاعات یک دانشجو.
///
/// همه فیلدها final هستند؛ یعنی بعد از ساخته شدن شیء تغییر نمی‌کنند.
/// برای ویرایش، یک شیء جدید با اطلاعات تازه می‌سازیم.
class Student {
  final String studentId; // شماره دانشجویی (یکتا)
  final String firstName;
  final String lastName;
  final String nationalId; // کد ملی ۱۰ رقمی
  final DateTime dateOfBirth;
  final String email;
  final String phone;
  final String faculty; // دانشکده
  final String major; // رشته
  final int semester; // ترم
  final DateTime enrollmentDate; // تاریخ ورود
  final StudentStatus status;
  final double? gpa; // اختیاری: دانشجوی ترم اول هنوز معدل ندارد
  final String? address; // اختیاری
  final DateTime createdAt; // زمان ثبت
  final DateTime updatedAt; // زمان آخرین ویرایش

  Student({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.faculty,
    required this.major,
    required this.semester,
    required this.enrollmentDate,
    this.status = StudentStatus.active,
    this.gpa,
    this.address,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// نام کامل، مثلاً «سارا رضایی».
  String get fullName => '$firstName $lastName';

  /// تبدیل شیء به Map تا بتوان آن را به JSON تبدیل کرد.
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'dateOfBirth': formatDate(dateOfBirth),
      'email': email,
      'phone': phone,
      'faculty': faculty,
      'major': major,
      'semester': semester,
      'enrollmentDate': formatDate(enrollmentDate),
      'status': status.name,
      'gpa': gpa,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// ساختن شیء Student از Map‌ای که از فایل JSON خوانده شده است.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      nationalId: json['nationalId'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String,
      phone: json['phone'] as String,
      faculty: json['faculty'] as String,
      major: json['major'] as String,
      semester: json['semester'] as int,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      status: StudentStatus.values.byName(json['status'] as String),
      // در JSON عدد 17 به شکل int خوانده می‌شود، پس آن را به double تبدیل می‌کنیم.
      gpa: (json['gpa'] as num?)?.toDouble(),
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() => 'Student($studentId, $fullName)';
}
