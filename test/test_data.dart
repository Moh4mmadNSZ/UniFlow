// داده ساختگی برای تست‌ها. همه نام‌ها، شماره‌ها و ایمیل‌ها ساختگی‌اند.

import 'package:uniflow/student.dart';

/// یک دانشجوی درست با مقدارهای پیش‌فرض می‌سازد.
/// هر فیلدی را که تست لازم دارد می‌توان با پارامتر نام‌دار عوض کرد.
Student makeStudent({
  String studentId = '1001',
  String firstName = 'Sara',
  String lastName = 'Rezaei',
  String? nationalId,
  String email = 'sara.rezaei@example.com',
  String faculty = 'Engineering',
  String major = 'Computer Engineering',
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
    nationalId: nationalId ?? studentId.padLeft(10, '0'),
    dateOfBirth: DateTime(2004, 3, 21),
    email: email,
    phone: '09121234567',
    faculty: faculty,
    major: major,
    semester: 3,
    enrollmentDate: DateTime(2024, 9, 22),
    status: status,
    gpa: gpa,
    address: address,
    createdAt: createdAt,
  );
}
