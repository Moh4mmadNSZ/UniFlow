import 'package:flutter_test/flutter_test.dart';
import 'package:uniflow/models/student.dart';

import 'test_helpers.dart';

void main() {
  group('Student', () {
    test('fullName joins first and last name', () {
      expect(makeStudent().fullName, 'سارا رضایی');
    });

    test('status is active by default', () {
      expect(makeStudent().status, StudentStatus.active);
    });

    test('toJson and then fromJson keep every field', () {
      final original = makeStudent(
        status: StudentStatus.suspended,
        address: 'تهران، خیابان آزادی',
        createdAt: DateTime(2026, 11, 15, 10, 30),
      );
      final copy = Student.fromJson(original.toJson());

      expect(copy.studentId, original.studentId);
      expect(copy.firstName, original.firstName);
      expect(copy.lastName, original.lastName);
      expect(copy.nationalId, original.nationalId);
      expect(copy.dateOfBirth, original.dateOfBirth);
      expect(copy.email, original.email);
      expect(copy.phone, original.phone);
      expect(copy.faculty, original.faculty);
      expect(copy.major, original.major);
      expect(copy.semester, original.semester);
      expect(copy.enrollmentDate, original.enrollmentDate);
      expect(copy.status, StudentStatus.suspended);
      expect(copy.gpa, 17.25);
      expect(copy.address, 'تهران، خیابان آزادی');
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
    });

    test('dates and status are written in a simple text form', () {
      final json = makeStudent().toJson();
      expect(json['dateOfBirth'], '2004-03-21');
      expect(json['enrollmentDate'], '2024-09-22');
      expect(json['status'], 'active');
    });

    test('an empty GPA and address stay null after a round trip', () {
      final copy = Student.fromJson(makeStudent(gpa: null).toJson());
      expect(copy.gpa, isNull);
      expect(copy.address, isNull);
    });

    test('a whole-number GPA read from JSON becomes a double', () {
      final json = makeStudent().toJson();
      json['gpa'] = 18;
      expect(Student.fromJson(json).gpa, 18.0);
    });

    test('createdAt and updatedAt are filled automatically', () {
      final before = DateTime.now();
      final student = makeStudent();
      expect(student.createdAt.isBefore(before), isFalse);
      expect(student.updatedAt.isBefore(before), isFalse);
    });

    test('statusLabel returns Persian text', () {
      expect(statusLabel(StudentStatus.active), 'فعال');
      expect(statusLabel(StudentStatus.suspended), 'تعلیق');
      expect(statusLabel(StudentStatus.graduated), 'فارغ‌التحصیل');
    });
  });
}
