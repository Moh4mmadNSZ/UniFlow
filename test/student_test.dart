import 'package:test/test.dart';
import 'package:uniflow/student.dart';

import 'test_data.dart';

void main() {
  test('fullName joins first and last name', () {
    expect(makeStudent().fullName, 'Sara Rezaei');
  });

  test('status is active by default', () {
    expect(makeStudent().status, StudentStatus.active);
  });

  test('toJson and then fromJson keep every field', () {
    final original = makeStudent(
      status: StudentStatus.graduated,
      address: 'Tehran, Azadi St.',
      createdAt: DateTime(2026, 11, 16, 10, 30),
    );
    final copy = Student.fromJson(original.toJson());

    expect(copy.studentId, original.studentId);
    expect(copy.fullName, original.fullName);
    expect(copy.nationalId, original.nationalId);
    expect(copy.dateOfBirth, original.dateOfBirth);
    expect(copy.email, original.email);
    expect(copy.phone, original.phone);
    expect(copy.faculty, original.faculty);
    expect(copy.major, original.major);
    expect(copy.semester, original.semester);
    expect(copy.enrollmentDate, original.enrollmentDate);
    expect(copy.status, StudentStatus.graduated);
    expect(copy.gpa, 17.25);
    expect(copy.address, 'Tehran, Azadi St.');
    expect(copy.createdAt, original.createdAt);
  });

  test('dates and status are saved as simple text', () {
    final json = makeStudent().toJson();
    expect(json['dateOfBirth'], '2004-03-21');
    expect(json['status'], 'active');
  });

  test('an empty GPA and address stay null', () {
    final copy = Student.fromJson(makeStudent(gpa: null).toJson());
    expect(copy.gpa, isNull);
    expect(copy.address, isNull);
  });

  test('a whole-number GPA from the file becomes a double', () {
    final json = makeStudent().toJson();
    json['gpa'] = 18;
    expect(Student.fromJson(json).gpa, 18.0);
  });

  test('statusLabel gives readable text', () {
    expect(statusLabel(StudentStatus.suspended), 'Suspended');
  });
}
