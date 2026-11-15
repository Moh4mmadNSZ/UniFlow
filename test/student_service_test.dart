import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uniflow/models/student.dart';
import 'package:uniflow/repositories/student_repository.dart';
import 'package:uniflow/services/student_service.dart';
import 'package:uniflow/storage/student_file_storage.dart';
import 'package:uniflow/utils/app_exceptions.dart';

import 'test_helpers.dart';

void main() {
  late Directory tempDir;
  late StudentService service;

  /// یک سرویس تازه روی همان پوشه می‌سازد؛ مثل بستن و باز کردن دوباره برنامه.
  Future<StudentService> openService() async {
    final newService = StudentService(
      StudentRepository(StudentFileStorage(tempDir)),
    );
    await newService.init();
    return newService;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('uniflow_service_test_');
    service = await openService();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('add', () {
    test('the first student is added and saved to the file', () async {
      await service.addStudent(makeStudent());

      expect(service.allStudents.length, 1);
      final reopened = await openService();
      expect(reopened.findById('1001')?.fullName, 'سارا رضایی');
    });

    test('several students can be added', () async {
      await service.addStudent(makeStudent(studentId: '1001'));
      await service.addStudent(makeStudent(studentId: '1002'));
      await service.addStudent(makeStudent(studentId: '1003'));

      expect(service.allStudents.length, 3);
      expect((await openService()).allStudents.length, 3);
    });

    test('a duplicate student ID is rejected and nothing changes', () async {
      await service.addStudent(makeStudent(studentId: '1001'));

      await expectLater(
        service.addStudent(
          makeStudent(studentId: '1001', nationalId: '9999999999'),
        ),
        throwsA(isA<DuplicateStudentException>()),
      );
      expect(service.allStudents.length, 1);
    });

    test('a duplicate national ID is rejected', () async {
      await service.addStudent(
        makeStudent(studentId: '1001', nationalId: '0123456789'),
      );

      await expectLater(
        service.addStudent(
          makeStudent(studentId: '1002', nationalId: '0123456789'),
        ),
        throwsA(isA<DuplicateStudentException>()),
      );
    });

    test('an invalid email is rejected and nothing is saved', () async {
      await expectLater(
        service.addStudent(makeStudent(email: 'sara@')),
        throwsA(isA<ValidationException>()),
      );
      expect(service.allStudents, isEmpty);
      expect(await service.dataFileSize(), 0);
    });

    test('a GPA out of range is rejected', () async {
      await expectLater(
        service.addStudent(makeStudent(gpa: 20.5)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('lastOperation describes the last successful action', () async {
      expect(service.lastOperation, isNull);
      await service.addStudent(makeStudent());
      expect(service.lastOperation, contains('1001'));
    });
  });

  group('find', () {
    test('an existing ID is found, also with Persian digits', () async {
      await service.addStudent(makeStudent());
      expect(service.findById('1001'), isNotNull);
      expect(service.findById('۱۰۰۱'), isNotNull);
    });

    test('a missing ID gives null', () {
      expect(service.findById('9999'), isNull);
    });
  });

  group('update', () {
    test('changes are saved and the creation time is kept', () async {
      final original = makeStudent(createdAt: DateTime(2026, 1, 1));
      await service.addStudent(original);

      await service.updateStudent(
        makeStudent(firstName: 'مریم', createdAt: original.createdAt),
      );

      final saved = (await openService()).findById('1001')!;
      expect(saved.firstName, 'مریم');
      expect(saved.createdAt, DateTime(2026, 1, 1));
      expect(saved.updatedAt.isAfter(saved.createdAt), isTrue);
    });

    test('updating a missing student throws StudentNotFoundException',
        () async {
      await expectLater(
        service.updateStudent(makeStudent(studentId: '5555')),
        throwsA(isA<StudentNotFoundException>()),
      );
    });
  });

  group('delete', () {
    test('a deleted student is removed from the file too', () async {
      await service.addStudent(makeStudent(studentId: '1001'));
      await service.addStudent(makeStudent(studentId: '1002'));

      await service.deleteStudent('1001');

      expect(service.findById('1001'), isNull);
      final reopened = await openService();
      expect(reopened.allStudents.length, 1);
      expect(reopened.findById('1002'), isNotNull);
    });

    test('deleting a missing ID throws and changes nothing', () async {
      await service.addStudent(makeStudent());

      await expectLater(
        service.deleteStudent('9999'),
        throwsA(isA<StudentNotFoundException>()),
      );
      expect(service.allStudents.length, 1);
    });
  });

  group('search, filter, sort and stats', () {
    setUp(() async {
      await service.addStudent(makeStudent(
        studentId: '1001',
        firstName: 'سارا',
        lastName: 'گودرزی',
        gpa: 17.25,
        createdAt: DateTime(2026, 1, 1),
      ));
      await service.addStudent(makeStudent(
        studentId: '9999',
        firstName: 'علی',
        lastName: 'لطفی',
        major: 'مهندسی برق',
        status: StudentStatus.suspended,
        gpa: 15,
        createdAt: DateTime(2026, 2, 1),
      ));
      await service.addStudent(makeStudent(
        studentId: '10001',
        firstName: 'مریم',
        lastName: 'احمدی',
        faculty: 'علوم پایه',
        major: 'فیزیک',
        status: StudentStatus.graduated,
        gpa: null,
        createdAt: DateTime(2026, 3, 1),
      ));
    });

    List<String> ids(List<Student> students) {
      final result = <String>[];
      for (final student in students) {
        result.add(student.studentId);
      }
      return result;
    }

    test('search looks in name, major and student ID', () {
      expect(ids(service.search(query: 'سارا')), ['1001']);
      expect(ids(service.search(query: 'برق')), ['9999']);
      expect(ids(service.search(query: '999')), ['9999']);
      expect(service.search(query: 'ناموجود'), isEmpty);
    });

    test('filters by status and major', () {
      expect(ids(service.search(status: StudentStatus.suspended)), ['9999']);
      expect(ids(service.search(major: 'فیزیک')), ['10001']);
    });

    test('sorts student IDs as numbers, not as text', () {
      expect(ids(service.search(sortBy: SortOption.studentId)),
          ['1001', '9999', '10001']);
    });

    test('sorts last names in Persian alphabetical order', () {
      expect(ids(service.search(sortBy: SortOption.lastName)),
          ['10001', '1001', '9999']);
    });

    test('newest first puts the latest registration on top', () {
      expect(ids(service.search(sortBy: SortOption.newest)),
          ['10001', '9999', '1001']);
    });

    test('stats count statuses and majors and skip empty GPAs', () {
      final stats = service.getStats();
      expect(stats.total, 3);
      expect(stats.active, 1);
      expect(stats.suspended, 1);
      expect(stats.graduated, 1);
      expect(stats.majorCount, 3);
      expect(stats.averageGpa, closeTo(16.125, 0.0001));
    });

    test('majorsInUse lists each major once in alphabetical order', () {
      expect(service.majorsInUse(),
          ['فیزیک', 'مهندسی برق', 'مهندسی کامپیوتر']);
    });
  });

  test('stats of an empty list have no average GPA', () {
    final stats = service.getStats();
    expect(stats.total, 0);
    expect(stats.averageGpa, isNull);
  });

  test('nothing is written before the data file has been read', () async {
    final notLoaded = StudentService(
      StudentRepository(StudentFileStorage(tempDir)),
    );
    await expectLater(
      notLoaded.addStudent(makeStudent()),
      throwsA(isA<StorageException>()),
    );
  });

  test('if saving fails, the list in memory does not change', () async {
    // پوشه‌ای هم‌نام فایل داده می‌سازیم تا نوشتن شکست بخورد.
    await Directory(service.dataFilePath).create();

    await expectLater(
      service.addStudent(makeStudent()),
      throwsA(isA<StorageException>()),
    );
    expect(service.allStudents, isEmpty);
  });
}
