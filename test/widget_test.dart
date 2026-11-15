import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uniflow/app.dart';
import 'package:uniflow/repositories/student_repository.dart';
import 'package:uniflow/services/student_service.dart';
import 'package:uniflow/storage/student_file_storage.dart';

import 'test_helpers.dart';

void main() {
  late Directory tempDir;
  late StudentService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('uniflow_widget_test_');
    service = StudentService(StudentRepository(StudentFileStorage(tempDir)));
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// برنامه را در یک پنجره 1280 در 900 اجرا می‌کند.
  /// کار با فایل داخل runAsync انجام می‌شود، چون تست‌های ویجت زمان ساختگی دارند.
  Future<void> startApp(WidgetTester tester, {bool withStudent = false}) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await service.init();
      if (withStudent) {
        await service.addStudent(makeStudent());
      }
    });
    await tester.pumpWidget(UniFlowApp(service: service));
    await tester.pumpAndSettle();
  }

  /// پیدا کردن SelectableText با یک متن مشخص.
  Finder selectableText(String text) {
    return find.byWidgetPredicate(
      (widget) => widget is SelectableText && widget.data == text,
    );
  }

  Future<void> searchById(WidgetTester tester, String id) async {
    await tester.enterText(find.byType(TextField), id);
    await tester.tap(find.text('جست‌وجو'));
    await tester.pumpAndSettle();
  }

  testWidgets('the home screen shows the five menu items', (tester) async {
    await startApp(tester);

    expect(find.text('ثبت دانشجو'), findsOneWidget);
    expect(find.text('نمایش همه دانشجویان'), findsOneWidget);
    expect(find.text('نمایش اطلاعات با شماره دانشجویی'), findsOneWidget);
    expect(find.text('حذف دانشجو'), findsOneWidget);
    expect(find.text('خروج'), findsOneWidget);
  });

  testWidgets('Show All with no students shows the empty message',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('نمایش همه دانشجویان'));
    await tester.pumpAndSettle();

    expect(find.text('هنوز دانشجویی ثبت نشده است'), findsOneWidget);
  });

  testWidgets('Show All lists a saved student', (tester) async {
    await startApp(tester, withStudent: true);

    await tester.tap(find.text('نمایش همه دانشجویان'));
    await tester.pumpAndSettle();

    expect(find.text('سارا رضایی'), findsOneWidget);
    expect(find.text('1 دانشجو'), findsOneWidget);
  });

  testWidgets('Show Info by ID shows a message for a missing ID',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('نمایش اطلاعات با شماره دانشجویی'));
    await tester.pumpAndSettle();
    await searchById(tester, '9999');

    expect(
      find.text('دانشجویی با شماره دانشجویی 9999 پیدا نشد'),
      findsOneWidget,
    );
  });

  testWidgets('Show Info by ID shows the details of a saved student',
      (tester) async {
    await startApp(tester, withStudent: true);

    await tester.tap(find.text('نمایش اطلاعات با شماره دانشجویی'));
    await tester.pumpAndSettle();
    await searchById(tester, '1001');

    expect(selectableText('سارا'), findsOneWidget);
    expect(selectableText('sara.rezaei@example.com'), findsOneWidget);
  });

  testWidgets('cancelling the delete dialog keeps the student',
      (tester) async {
    await startApp(tester, withStudent: true);

    await tester.tap(find.text('حذف دانشجو'));
    await tester.pumpAndSettle();
    await searchById(tester, '1001');
    await tester.tap(find.text('حذف این دانشجو'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('انصراف'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('حذف لغو شد'), findsOneWidget);
    expect(service.findById('1001'), isNotNull);
  });

  testWidgets('saving an empty form shows errors and saves nothing',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('ثبت دانشجو'));
    await tester.pumpAndSettle();
    final saveButton = find.text('ثبت دانشجو');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('شماره دانشجویی را وارد کنید'), findsOneWidget);
    expect(find.text('ایمیل را وارد کنید'), findsOneWidget);
    expect(service.allStudents, isEmpty);
  });

  testWidgets('Exit asks for confirmation before closing', (tester) async {
    await startApp(tester);

    await tester.tap(find.text('خروج'));
    await tester.pumpAndSettle();
    expect(find.text('خروج از برنامه'), findsOneWidget);

    await tester.tap(find.text('انصراف'));
    await tester.pumpAndSettle();
    expect(find.text('خروج از برنامه'), findsNothing);
  });
}
