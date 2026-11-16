// مدل دانشجو: اطلاعات یک دانشجو و تبدیل آن به JSON و برعکس.
// این فایل نمی‌داند اطلاعات کجا ذخیره می‌شود.

import 'utils.dart';

/// وضعیت تحصیلی دانشجو. فقط همین سه مقدار مجاز است.
enum StudentStatus { active, suspended, graduated }

/// متن قابل نمایش هر وضعیت.
String statusLabel(StudentStatus status) {
  switch (status) {
    case StudentStatus.active:
      return 'Active';
    case StudentStatus.suspended:
      return 'Suspended';
    case StudentStatus.graduated:
      return 'Graduated';
  }
}

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

  /// نام کامل، مثلاً «Sara Rezaei».
  String get fullName => '$firstName $lastName';

  /// تبدیل دانشجو به Map تا بتوان آن را در فایل JSON نوشت.
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

  /// ساختن دانشجو از Map‌ای که از فایل JSON خوانده شده است.
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
      // عدد 18 در JSON به شکل int خوانده می‌شود، پس آن را double می‌کنیم.
      gpa: (json['gpa'] as num?)?.toDouble(),
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
