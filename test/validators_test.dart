import 'package:flutter_test/flutter_test.dart';
import 'package:uniflow/utils/text_utils.dart';
import 'package:uniflow/utils/validators.dart';

import 'test_helpers.dart';

void main() {
  group('normalizeDigits', () {
    test('converts Persian and Arabic digits to English digits', () {
      expect(normalizeDigits('۱۰۰۱'), '1001');
      expect(normalizeDigits('٠٩١٢'), '0912');
      expect(normalizeDigits('۱۷٫۲۵'), '17.25');
      expect(normalizeDigits('abc'), 'abc');
    });
  });

  group('comparePersian', () {
    test('sorts words in Persian alphabetical order', () {
      final names = ['لطفی', 'گودرزی', 'حسینی', 'چمنی', 'احمدی'];
      names.sort(comparePersian);
      expect(names, ['احمدی', 'چمنی', 'حسینی', 'گودرزی', 'لطفی']);
    });
  });

  group('Validators.studentId', () {
    test('rejects empty, letters, too short and too long values', () {
      expect(Validators.studentId(''), isNotNull);
      expect(Validators.studentId('10a1'), isNotNull);
      expect(Validators.studentId('123'), isNotNull);
      expect(Validators.studentId('12345678901'), isNotNull);
    });

    test('accepts a valid number, also with Persian digits', () {
      expect(Validators.studentId('1001'), isNull);
      expect(Validators.studentId('۱۰۰۱'), isNull);
    });
  });

  group('Validators.name', () {
    test('accepts Persian and English names, also with a half-space', () {
      expect(Validators.name('سارا', fieldName: 'نام'), isNull);
      expect(Validators.name('علی‌رضا', fieldName: 'نام'), isNull);
      expect(Validators.name('Sara', fieldName: 'نام'), isNull);
    });

    test('rejects empty names, digits and names that are too short', () {
      expect(Validators.name('', fieldName: 'نام'), isNotNull);
      expect(Validators.name('سارا2', fieldName: 'نام'), isNotNull);
      expect(Validators.name('سارا۲', fieldName: 'نام'), isNotNull);
      expect(Validators.name('س', fieldName: 'نام'), isNotNull);
    });
  });

  group('Validators.nationalId', () {
    test('needs exactly 10 digits', () {
      expect(Validators.nationalId('0123456789'), isNull);
      expect(Validators.nationalId('012345678'), isNotNull);
      expect(Validators.nationalId('01234567ab'), isNotNull);
    });
  });

  group('Validators.email', () {
    test('rejects invalid emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('sara'), isNotNull);
      expect(Validators.email('sara@'), isNotNull);
      expect(Validators.email('sara@example'), isNotNull);
      expect(Validators.email('@example.com'), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.email('sara.rezaei@example.com'), isNull);
    });
  });

  group('Validators.phone', () {
    test('needs 11 digits starting with 09', () {
      expect(Validators.phone('09121234567'), isNull);
      expect(Validators.phone('۰۹۱۲۱۲۳۴۵۶۷'), isNull);
      expect(Validators.phone('0912123456'), isNotNull);
      expect(Validators.phone('9121234567'), isNotNull);
      expect(Validators.phone('08121234567'), isNotNull);
    });
  });

  group('Validators.semester', () {
    test('must be a whole number from 1 to 12', () {
      expect(Validators.semester('3'), isNull);
      expect(Validators.semester('0'), isNotNull);
      expect(Validators.semester('13'), isNotNull);
      expect(Validators.semester('2.5'), isNotNull);
      expect(Validators.semester(''), isNotNull);
    });
  });

  group('Validators.gpa', () {
    test('is optional', () {
      expect(Validators.gpa(''), isNull);
      expect(Validators.gpa(null), isNull);
    });

    test('accepts values from 0 to 20 with up to two decimals', () {
      expect(Validators.gpa('0'), isNull);
      expect(Validators.gpa('17.25'), isNull);
      expect(Validators.gpa('20'), isNull);
      expect(Validators.gpa('۱۸٫۵'), isNull);
    });

    test('rejects values out of range, text and extra decimals', () {
      expect(Validators.gpa('21'), isNotNull);
      expect(Validators.gpa('-1'), isNotNull);
      expect(Validators.gpa('abc'), isNotNull);
      expect(Validators.gpa('17.255'), isNotNull);
    });
  });

  group('date validators', () {
    test('date of birth cannot be in the future or under 15 years ago', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 10));
      expect(Validators.dateOfBirth(null), isNotNull);
      expect(Validators.dateOfBirth(tomorrow), isNotNull);
      expect(Validators.dateOfBirth(tenYearsAgo), isNotNull);
      expect(Validators.dateOfBirth(DateTime(2004, 3, 21)), isNull);
    });

    test('enrollment date must be after birth and not in the future', () {
      final birth = DateTime(2004, 3, 21);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(Validators.enrollmentDate(DateTime(2024, 9, 22), birth), isNull);
      expect(Validators.enrollmentDate(DateTime(2003, 1, 1), birth), isNotNull);
      expect(Validators.enrollmentDate(tomorrow, birth), isNotNull);
      expect(Validators.enrollmentDate(null, birth), isNotNull);
    });

    test('ageOn counts full years only', () {
      final birth = DateTime(2004, 3, 21);
      expect(Validators.ageOn(birth, DateTime(2024, 3, 20)), 19);
      expect(Validators.ageOn(birth, DateTime(2024, 3, 21)), 20);
    });
  });

  group('faculty and major', () {
    test('the major must belong to the chosen faculty', () {
      expect(Validators.faculty('فنی و مهندسی'), isNull);
      expect(Validators.faculty('دانشکده ناموجود'), isNotNull);
      expect(Validators.major('مهندسی کامپیوتر', 'فنی و مهندسی'), isNull);
      expect(Validators.major('حقوق', 'فنی و مهندسی'), isNotNull);
    });
  });

  group('Validators.validateStudent', () {
    test('returns no errors for a valid student', () {
      expect(Validators.validateStudent(makeStudent()), isEmpty);
    });

    test('returns one error for each invalid field', () {
      final errors = Validators.validateStudent(
        makeStudent(email: 'bad-email', gpa: 25),
      );
      expect(errors.length, 2);
    });
  });
}
