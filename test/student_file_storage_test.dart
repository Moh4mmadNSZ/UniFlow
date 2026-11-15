import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uniflow/storage/student_file_storage.dart';
import 'package:uniflow/utils/app_exceptions.dart';

import 'test_helpers.dart';

void main() {
  late Directory tempDir;
  late StudentFileStorage storage;

  setUp(() async {
    // هر تست یک پوشه موقت و خالی دارد و فایل واقعی می‌نویسد.
    tempDir = await Directory.systemTemp.createTemp('uniflow_test_');
    storage = StudentFileStorage(tempDir);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// فایل‌های پشتیبانی که از فایل خراب ساخته شده‌اند.
  List<File> backupFiles() {
    final backups = <File>[];
    for (final entity in tempDir.listSync()) {
      if (entity is File && entity.path.contains('students.corrupted-')) {
        backups.add(entity);
      }
    }
    return backups;
  }

  test('a missing file gives an empty list (first run)', () async {
    final result = await storage.readStudents();
    expect(result.students, isEmpty);
    expect(result.warning, isNull);
  });

  test('an empty file gives an empty list', () async {
    await storage.file.writeAsString('');
    final result = await storage.readStudents();
    expect(result.students, isEmpty);
    expect(result.warning, isNull);
  });

  test('saved students are read back by a new storage object (app restart)',
      () async {
    await storage.writeStudents([
      makeStudent(studentId: '1001'),
      makeStudent(studentId: '1002', firstName: 'علی'),
    ]);

    final afterRestart = StudentFileStorage(tempDir);
    final result = await afterRestart.readStudents();

    expect(result.students.length, 2);
    expect(result.students[0].studentId, '1001');
    expect(result.students[1].firstName, 'علی');
  });

  test('the file is readable JSON with a schema version', () async {
    await storage.writeStudents([makeStudent()]);
    final text = await storage.file.readAsString();
    final data = jsonDecode(text) as Map<String, dynamic>;

    expect(data['schemaVersion'], 1);
    expect((data['students'] as List).length, 1);
    expect(text, contains('سارا')); // فارسی به شکل متن خوانا ذخیره می‌شود
  });

  test('no temporary file is left after a successful write', () async {
    await storage.writeStudents([makeStudent()]);
    expect(await File('${storage.file.path}.tmp').exists(), isFalse);
  });

  test('a corrupted file is kept as a backup and the app starts empty',
      () async {
    await storage.file.writeAsString('{ this is not json');

    final result = await storage.readStudents();

    expect(result.students, isEmpty);
    expect(result.warning, isNotNull);
    expect(await storage.file.exists(), isFalse);
    final backups = backupFiles();
    expect(backups.length, 1);
    expect(await backups.first.readAsString(), '{ this is not json');
  });

  test('a file with wrong data types is treated as corrupted', () async {
    await storage.file.writeAsString(
      '{"schemaVersion": 1, "students": [{"studentId": 1001}]}',
    );
    final result = await storage.readStudents();
    expect(result.students, isEmpty);
    expect(result.warning, isNotNull);
    expect(backupFiles().length, 1);
  });

  test('bytes that are not valid UTF-8 are treated as corrupted', () async {
    await storage.file.writeAsBytes([0xFF, 0xFE, 0xFD]);
    final result = await storage.readStudents();
    expect(result.warning, isNotNull);
    expect(backupFiles().length, 1);
  });

  test('a write error becomes a StorageException and nothing is destroyed',
      () async {
    // پوشه‌ای با نام students.json می‌سازیم تا نوشتن فایل شکست بخورد.
    await Directory(storage.file.path).create();

    await expectLater(
      storage.writeStudents([makeStudent()]),
      throwsA(isA<StorageException>()),
    );
    expect(await Directory(storage.file.path).exists(), isTrue);
  });

  test('readRawText and fileSize describe the saved file', () async {
    expect(await storage.readRawText(), '');
    expect(await storage.fileSize(), 0);

    await storage.writeStudents([makeStudent()]);

    expect(await storage.readRawText(), contains('"studentId": "1001"'));
    expect(await storage.fileSize(), greaterThan(0));
  });
}
