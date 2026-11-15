import 'package:material_ui/material_ui.dart';

import 'services/student_service.dart';
import 'ui/app_theme.dart';
import 'ui/screens/home_screen.dart';

/// ریشه برنامه: تم، زبان فارسی، راست‌چین بودن و صفحه اول.
class UniFlowApp extends StatelessWidget {
  final StudentService service;

  const UniFlowApp({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniFlow',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // با زبان فارسی، همه صفحه‌ها راست‌چین می‌شوند
      // و متن‌های آماده Material (مثل دکمه‌های تقویم) هم فارسی می‌شوند.
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomeScreen(service: service),
    );
  }
}
