import 'dart:io';

import 'package:test/test.dart';
import 'package:uniflow/app_exceptions.dart';
import 'package:uniflow/student.dart';
import 'package:uniflow/student_manager.dart';
import 'package:uniflow/student_storage.dart';

import 'test_data.dart';

void main() {
  late Directory tempDir;
  late StudentManager manager;

  /// یک StudentManager تازه روی همان فایل؛ مثل بستن و باز کردن دوباره برنامه.
  Future<StudentManager> openManager() async {
    final newManager =
        StudentManager(StudentStorage('${tempDir.path}/students.json'));
    await newManager.load();
    return newManager;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('uniflow_manager_test_');
    manager = await openManager();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// شماره دانشجویی‌های یک فهرست، برای مقایسه ساده در تست‌ها.
  List<String> ids(List<Student> students) {
    final result = <String>[];
    for (final student in students) {
      result.add(student.studentId);
    }
    return result;
  }

  group('add', () {
    test('the first student is added and saved in the file', () async {
      await manager.addStudent(makeStudent());

      expect(manager.count, 1);
      final reopened = await openManager();
      expect(reopened.findById('1001')?.fullName, 'Sara Rezaei');
    });

    test('several students can be added', () async {
      await manager.addStudent(makeStudent(studentId: '1001'));
      await manager.addStudent(makeStudent(studentId: '1002'));
      await manager.addStudent(makeStudent(studentId: '1003'));

      expect((await openManager()).count, 3);
    });

    test('a duplicate student ID is rejected', () async {
      await manager.addStudent(makeStudent(studentId: '1001'));

      await expectLater(
        manager.addStudent(
            makeStudent(studentId: '1001', nationalId: '9999999999')),
        throwsA(isA<StudentException>()),
      );
      expect(manager.count, 1);
    });

    test('a duplicate national ID is rejected', () async {
      await manager
          .addStudent(makeStudent(studentId: '1001', nationalId: '0123456789'));

      await expectLater(
        manager.addStudent(
            makeStudent(studentId: '1002', nationalId: '0123456789')),
        throwsA(isA<StudentException>()),
      );
    });

    test('wrong data is rejected and nothing is saved', () async {
      await expectLater(
        manager.addStudent(makeStudent(email: 'sara@')),
        throwsA(isA<StudentException>()),
      );
      expect(manager.count, 0);
      expect(await manager.storage.file.exists(), isFalse);
    });
  });

  group('find', () {
    test('finds an existing ID, also typed with Persian digits', () async {
      await manager.addStudent(makeStudent());
      expect(manager.findById('1001'), isNotNull);
      expect(manager.findById('۱۰۰۱'), isNotNull);
    });

    test('gives null for a missing ID', () {
      expect(manager.findById('9999'), isNull);
    });
  });

  group('update', () {
    test('saves the new data and keeps the creation time', () async {
      final original = makeStudent(createdAt: DateTime(2026, 1, 1));
      await manager.addStudent(original);

      await manager.updateStudent(
          makeStudent(firstName: 'Maryam', createdAt: original.createdAt));

      final saved = (await openManager()).findById('1001')!;
      expect(saved.firstName, 'Maryam');
      expect(saved.createdAt, DateTime(2026, 1, 1));
    });

    test('a missing student cannot be updated', () async {
      await expectLater(
        manager.updateStudent(makeStudent(studentId: '5555')),
        throwsA(isA<StudentException>()),
      );
    });
  });

  group('delete', () {
    test('removes the student from the file too', () async {
      await manager.addStudent(makeStudent(studentId: '1001'));
      await manager.addStudent(makeStudent(studentId: '1002'));

      final removed = await manager.deleteStudent('1001');

      expect(removed.studentId, '1001');
      final reopened = await openManager();
      expect(ids(reopened.getAll()), ['1002']);
    });

    test('a missing ID throws and changes nothing', () async {
      await manager.addStudent(makeStudent());

      await expectLater(
        manager.deleteStudent('9999'),
        throwsA(isA<StudentException>()),
      );
      expect(manager.count, 1);
    });
  });

  group('list, search and statistics', () {
    setUp(() async {
      await manager.addStudent(makeStudent(
          studentId: '10001',
          firstName: 'Maryam',
          lastName: 'Ahmadi',
          faculty: 'Basic Sciences',
          major: 'Physics',
          status: StudentStatus.graduated,
          gpa: null));
      await manager.addStudent(makeStudent(
          studentId: '9999',
          firstName: 'Ali',
          lastName: 'Karimi',
          major: 'Electrical Engineering',
          status: StudentStatus.suspended,
          gpa: 15));
      await manager.addStudent(makeStudent(studentId: '1001', gpa: 17.25));
    });

    test('getAll sorts student IDs as numbers, not as text', () {
      expect(ids(manager.getAll()), ['1001', '9999', '10001']);
    });

    test('search looks in name, major and student ID', () {
      expect(ids(manager.search('sara')), ['1001']);
      expect(ids(manager.search('PHYSICS')), ['10001']);
      expect(ids(manager.search('999')), ['9999']);
      expect(manager.search('nobody'), isEmpty);
    });

    test('statistics count statuses and majors and skip empty GPAs', () {
      expect(manager.countByStatus(StudentStatus.active), 1);
      expect(manager.countByStatus(StudentStatus.suspended), 1);
      expect(manager.countByStatus(StudentStatus.graduated), 1);
      expect(manager.countMajors(), 3);
      expect(manager.averageGpa(), closeTo(16.125, 0.0001));
    });
  });

  test('average GPA is null when nobody has a GPA', () {
    expect(manager.averageGpa(), isNull);
  });

  test('if saving fails, the list in memory does not change', () async {
    // پوشه‌ای هم‌نام فایل داده می‌سازیم تا نوشتن شکست بخورد.
    await Directory(manager.storage.filePath).create();

    await expectLater(
      manager.addStudent(makeStudent()),
      throwsA(isA<StorageException>()),
    );
    expect(manager.count, 0);
  });

  test('nothing is saved before the file has been read', () async {
    final notLoaded =
        StudentManager(StudentStorage('${tempDir.path}/students.json'));
    await expectLater(
      notLoaded.addStudent(makeStudent()),
      throwsA(isA<StorageException>()),
    );
  });
}
