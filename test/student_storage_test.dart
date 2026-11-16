import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:uniflow/app_exceptions.dart';
import 'package:uniflow/student_storage.dart';

import 'test_data.dart';

void main() {
  late Directory tempDir;
  late StudentStorage storage;

  setUp(() async {
    // هر تست یک پوشه موقت و خالی دارد و روی یک فایل واقعی کار می‌کند.
    tempDir = await Directory.systemTemp.createTemp('uniflow_test_');
    storage = StudentStorage('${tempDir.path}/students.json');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('a missing file gives an empty list (first run)', () async {
    expect(await storage.load(), isEmpty);
    expect(storage.warning, isNull);
  });

  test('an empty file gives an empty list', () async {
    await storage.file.writeAsString('');
    expect(await storage.load(), isEmpty);
  });

  test('saved students are read back after a restart', () async {
    await storage.save([
      makeStudent(studentId: '1001'),
      makeStudent(studentId: '1002', firstName: 'Ali'),
    ]);

    // یک شیء جدید، مثل اجرای دوباره برنامه
    final afterRestart = StudentStorage(storage.filePath);
    final students = await afterRestart.load();

    expect(students.length, 2);
    expect(students[1].firstName, 'Ali');
  });

  test('the file is a readable JSON list', () async {
    await storage.save([makeStudent(firstName: 'سارا')]);
    final text = await storage.file.readAsString();

    expect(jsonDecode(text), isA<List<dynamic>>());
    expect(text, contains('سارا'));
    expect(await File('${storage.filePath}.tmp').exists(), isFalse);
  });

  test('save creates the data folder when it is missing', () async {
    final nested = StudentStorage('${tempDir.path}/data/students.json');
    await nested.save([makeStudent()]);
    expect(await nested.file.exists(), isTrue);
  });

  test('a damaged file is kept as a backup and the list starts empty',
      () async {
    await storage.file.writeAsString('[ { "studentId": ');

    final students = await storage.load();

    expect(students, isEmpty);
    expect(storage.warning, isNotNull);
    expect(await storage.file.exists(), isFalse);
    final backups = tempDir
        .listSync()
        .where((entity) => entity.path.contains('.broken-'))
        .toList();
    expect(backups.length, 1);
    expect(await File(backups.first.path).readAsString(), '[ { "studentId": ');
  });

  test('wrong data types are treated as a damaged file', () async {
    await storage.file.writeAsString('[{"studentId": 1001}]');
    expect(await storage.load(), isEmpty);
    expect(storage.warning, isNotNull);
  });

  test('a write error becomes a StorageException', () async {
    // پوشه‌ای با نام students.json می‌سازیم تا نوشتن فایل شکست بخورد.
    await Directory(storage.filePath).create();

    await expectLater(
      storage.save([makeStudent()]),
      throwsA(isA<StorageException>()),
    );
    expect(await Directory(storage.filePath).exists(), isTrue);
  });
}
