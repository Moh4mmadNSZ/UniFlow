// داده‌های ساختگی که در چند فایل تست استفاده می‌شوند.
// همه نام‌ها، شماره‌ها و ایمیل‌ها ساختگی هستند.

import 'package:uniflow/models/student.dart';

/// یک دانشجوی درست با مقدارهای پیش‌فرض می‌سازد.
/// هر فیلدی را که تست لازم دارد می‌توان با پارامتر نام‌دار عوض کرد.
Student makeStudent({
  String studentId = '1001',
  String firstName = 'سارا',
  String lastName = 'رضایی',
  String? nationalId,
  String email = 'sara.rezaei@example.com',
  String phone = '09121234567',
  String faculty = 'فنی و مهندسی',
  String major = 'مهندسی کامپیوتر',
  int semester = 3,
  StudentStatus status = StudentStatus.active,
  double? gpa = 17.25,
  String? address,
  DateTime? createdAt,
}) {
  return Student(
    studentId: studentId,
    firstName: firstName,
    lastName: lastName,
    // کد ملی ساختگی و یکتا که از روی شماره دانشجویی ساخته می‌شود: 1001 ← 0000001001
    nationalId: nationalId ?? ('0000000000$studentId').substring(studentId.length),
    dateOfBirth: DateTime(2004, 3, 21),
    email: email,
    phone: phone,
    faculty: faculty,
    major: major,
    semester: semester,
    enrollmentDate: DateTime(2024, 9, 22),
    status: status,
    gpa: gpa,
    address: address,
    createdAt: createdAt,
  );
}
