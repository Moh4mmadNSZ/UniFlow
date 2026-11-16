import 'package:test/test.dart';
import 'package:uniflow/utils.dart';
import 'package:uniflow/validators.dart';

import 'test_data.dart';

void main() {
  test('normalizeDigits converts Persian and Arabic digits', () {
    expect(normalizeDigits('۱۰۰۱'), '1001');
    expect(normalizeDigits('٠٩١٢'), '0912');
    expect(normalizeDigits('۱۷٫۵'), '17.5');
  });

  test('parseDate accepts real dates only', () {
    expect(parseDate('2004-03-21'), DateTime(2004, 3, 21));
    expect(parseDate('2004-02-30'), isNull);
    expect(parseDate('21-03-2004'), isNull);
    expect(parseDate('hello'), isNull);
  });

  test('student ID: only digits, 4 to 10 of them', () {
    expect(validateStudentId('1001'), isNull);
    expect(validateStudentId(''), isNotNull);
    expect(validateStudentId('10a1'), isNotNull);
    expect(validateStudentId('123'), isNotNull);
    expect(validateStudentId('12345678901'), isNotNull);
  });

  test('names: Persian or English letters only', () {
    expect(validateName('Sara', 'First name'), isNull);
    expect(validateName('سارا', 'First name'), isNull);
    expect(validateName('علی‌رضا', 'First name'), isNull);
    expect(validateName('Sara2', 'First name'), isNotNull);
    expect(validateName('S', 'First name'), isNotNull);
    expect(validateName('', 'First name'), isNotNull);
  });

  test('national ID: exactly 10 digits', () {
    expect(validateNationalId('0123456789'), isNull);
    expect(validateNationalId('012345678'), isNotNull);
  });

  test('email must look like name@example.com', () {
    expect(validateEmail('sara.rezaei@example.com'), isNull);
    expect(validateEmail('sara'), isNotNull);
    expect(validateEmail('sara@'), isNotNull);
    expect(validateEmail('sara@example'), isNotNull);
  });

  test('phone: 11 digits starting with 09', () {
    expect(validatePhone('09121234567'), isNull);
    expect(validatePhone('0912123456'), isNotNull);
    expect(validatePhone('08121234567'), isNotNull);
  });

  test('semester: a whole number from 1 to 12', () {
    expect(validateSemester('3'), isNull);
    expect(validateSemester('0'), isNotNull);
    expect(validateSemester('13'), isNotNull);
    expect(validateSemester('two'), isNotNull);
  });

  test('GPA: optional, from 0 to 20, at most two decimals', () {
    expect(validateGpa(''), isNull);
    expect(validateGpa('17.25'), isNull);
    expect(validateGpa('20'), isNull);
    expect(validateGpa('21'), isNotNull);
    expect(validateGpa('-1'), isNotNull);
    expect(validateGpa('17.255'), isNotNull);
    expect(validateGpa('abc'), isNotNull);
  });

  test('date of birth: not in the future and at least 15 years ago', () {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tenYearsAgo = DateTime.now().subtract(const Duration(days: 3650));
    expect(validateDateOfBirth(DateTime(2004, 3, 21)), isNull);
    expect(validateDateOfBirth(null), isNotNull);
    expect(validateDateOfBirth(tomorrow), isNotNull);
    expect(validateDateOfBirth(tenYearsAgo), isNotNull);
  });

  test('enrollment date: after birth and not in the future', () {
    final birth = DateTime(2004, 3, 21);
    expect(validateEnrollmentDate(DateTime(2024, 9, 22), birth), isNull);
    expect(validateEnrollmentDate(DateTime(2003, 1, 1), birth), isNotNull);
    expect(validateEnrollmentDate(null, birth), isNotNull);
  });

  test('the major must belong to the faculty', () {
    expect(validateFacultyAndMajor('Engineering', 'Physics'), isNotNull);
    expect(validateFacultyAndMajor('Engineering', 'Computer Engineering'),
        isNull);
  });

  test('validateStudent finds every wrong field', () {
    expect(validateStudent(makeStudent()), isEmpty);
    expect(validateStudent(makeStudent(email: 'bad', gpa: 25)).length, 2);
  });
}
