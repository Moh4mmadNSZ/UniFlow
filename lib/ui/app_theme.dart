// رنگ‌ها و فونت برنامه، همه در یک جا.

import 'package:material_ui/material_ui.dart';

import '../models/student.dart';

/// رنگ اصلی برنامه (سبزآبی تیره).
const Color brandColor = Color(0xFF0D6A65);

/// تم برنامه: Material 3 با رنگ اصلی و فونت وزیرمتن.
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: brandColor),
    fontFamily: 'Vazirmatn',
    inputDecorationTheme: const InputDecorationThemeData(
      border: OutlineInputBorder(),
    ),
  );
}

/// رنگ هر وضعیت تحصیلی.
Color statusColor(StudentStatus status) {
  switch (status) {
    case StudentStatus.active:
      return const Color(0xFF2E7D4F); // سبز
    case StudentStatus.suspended:
      return const Color(0xFFB26A00); // کهربایی
    case StudentStatus.graduated:
      return const Color(0xFF2F5DA8); // آبی
  }
}
