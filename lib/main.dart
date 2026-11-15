import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'repositories/student_repository.dart';
import 'services/student_service.dart';
import 'storage/student_file_storage.dart';

/// نقطه شروع برنامه.
/// پوشه داده را پیدا می‌کند، لایه‌ها را می‌سازد و برنامه را اجرا می‌کند.
Future<void> main() async {
  // قبل از استفاده از پلاگین‌ها (مثل path_provider) باید این خط اجرا شود.
  WidgetsFlutterBinding.ensureInitialized();

  final dataDirectory = await findDataDirectory();

  // ساختن لایه‌ها به ترتیب: Storage ← Repository ← Service
  final storage = StudentFileStorage(dataDirectory);
  final repository = StudentRepository(storage);
  final service = StudentService(repository);

  runApp(UniFlowApp(service: service));
}

/// پوشه ذخیره فایل: پوشه UniFlow داخل پوشه Documents کاربر.
/// روی اوبونتو معمولاً ‎~/Documents/UniFlow است.
Future<Directory> findDataDirectory() async {
  Directory base;
  try {
    base = await getApplicationDocumentsDirectory();
  } catch (e) {
    // اگر پوشه Documents پیدا نشد، از پوشه مخصوص داده‌های برنامه استفاده می‌کنیم.
    base = await getApplicationSupportDirectory();
  }
  return Directory('${base.path}${Platform.pathSeparator}UniFlow');
}
