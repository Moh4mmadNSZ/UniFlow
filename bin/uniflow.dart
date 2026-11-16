// نقطه شروع برنامه: فایل را می‌خواند و منو را اجرا می‌کند.

import 'dart:io';

import 'package:uniflow/app_exceptions.dart';
import 'package:uniflow/console_output.dart';
import 'package:uniflow/student_manager.dart';
import 'package:uniflow/student_menu.dart';
import 'package:uniflow/student_storage.dart';

/// مسیر فایل داده، نسبت به پوشه‌ای که برنامه از آن اجرا می‌شود.
const String dataFilePath = 'data/students.json';

Future<void> main() async {
  final storage = StudentStorage(dataFilePath);
  final manager = StudentManager(storage);

  // ۱. خواندن اطلاعات از فایل
  try {
    await manager.load();
  } on StorageException catch (e) {
    printError(e.message);
    printError(
        'The program stopped so that your data file is not overwritten.');
    exitCode = 1;
    return;
  }

  // ۲. اگر فایل خراب بوده، به کاربر خبر می‌دهیم
  final warning = storage.warning;
  if (warning != null) {
    printWarning(warning);
  }
  printInfo('Data file: ${storage.file.absolute.path} '
      '(${manager.count} student(s))');

  // ۳. نمایش منو تا وقتی کاربر Exit را بزند
  await StudentMenu(manager).run();
}
