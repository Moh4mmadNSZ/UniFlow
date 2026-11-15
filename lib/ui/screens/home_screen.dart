import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/app_exceptions.dart';
import '../app_theme.dart';
import '../widgets/dialogs.dart';
import '../widgets/stat_card.dart';
import 'data_file_screen.dart';
import 'student_form_screen.dart';
import 'student_list_screen.dart';
import 'student_lookup_screen.dart';

/// صفحه اصلی: آمار دانشجویان و منوی پنج‌گزینه‌ای.
class HomeScreen extends StatefulWidget {
  final StudentService service;

  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// خواندن فایل داده در شروع برنامه.
  Future<void> _loadData() async {
    String? error;
    try {
      await widget.service.init();
    } on AppException catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadError = error;
    });

    // اگر فایل خراب بوده، به کاربر خبر می‌دهیم.
    final warning = widget.service.loadWarning;
    if (error == null && warning != null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('هشدار فایل داده'),
          content: Text(warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('متوجه شدم'),
            ),
          ],
        ),
      );
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    _loadData();
  }

  /// یک صفحه را باز می‌کند و بعد از برگشتن، آمار را دوباره می‌سازد.
  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) setState(() {});
  }

  /// گزینه ۵ منو: خروج از برنامه.
  Future<void> _exitApp() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'خروج از برنامه',
      message:
          'همه اطلاعات قبلاً در فایل ذخیره شده است. از برنامه خارج می‌شوید؟',
      confirmText: 'خروج',
    );
    if (confirmed) {
      // exit از کتابخانه dart:io برنامه را می‌بندد. کد 0 یعنی خروج بدون خطا.
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final error = _loadError;
    if (error != null) {
      return Scaffold(body: _buildLoadError(error));
    }

    final service = widget.service;
    final stats = service.getStats();
    final averageGpa = stats.averageGpa;
    final lastOperation = service.lastOperation;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniFlow'),
        actions: [
          TextButton.icon(
            onPressed: () => _open(DataFileScreen(service: service)),
            icon: const Icon(Icons.description_outlined),
            label: const Text('فایل داده'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'سامانه ثبت‌نام و مدیریت دانشجویان',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatCard(
                      label: 'کل دانشجویان',
                      value: '${stats.total}',
                      icon: Icons.groups_outlined,
                      color: brandColor,
                    ),
                    StatCard(
                      label: 'فعال',
                      value: '${stats.active}',
                      icon: Icons.check_circle_outline,
                      color: statusColor(StudentStatus.active),
                    ),
                    StatCard(
                      label: 'تعلیق',
                      value: '${stats.suspended}',
                      icon: Icons.pause_circle_outline,
                      color: statusColor(StudentStatus.suspended),
                    ),
                    StatCard(
                      label: 'فارغ‌التحصیل',
                      value: '${stats.graduated}',
                      icon: Icons.school_outlined,
                      color: statusColor(StudentStatus.graduated),
                    ),
                    StatCard(
                      label: 'تعداد رشته‌ها',
                      value: '${stats.majorCount}',
                      icon: Icons.menu_book_outlined,
                      color: theme.colorScheme.tertiary,
                    ),
                    StatCard(
                      label: 'میانگین معدل',
                      value: averageGpa == null
                          ? '—'
                          : averageGpa.toStringAsFixed(2),
                      icon: Icons.grade_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'منوی اصلی',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _MenuTile(
                  number: '1',
                  title: 'ثبت دانشجو',
                  subtitle: 'Add Student',
                  icon: Icons.person_add_alt_1,
                  onTap: () => _open(StudentFormScreen(service: service)),
                ),
                _MenuTile(
                  number: '2',
                  title: 'نمایش همه دانشجویان',
                  subtitle: 'Show All',
                  icon: Icons.list_alt,
                  onTap: () => _open(StudentListScreen(service: service)),
                ),
                _MenuTile(
                  number: '3',
                  title: 'نمایش اطلاعات با شماره دانشجویی',
                  subtitle: 'Show Info by ID',
                  icon: Icons.badge_outlined,
                  onTap: () => _open(
                    StudentLookupScreen(
                        service: service, mode: LookupMode.view),
                  ),
                ),
                _MenuTile(
                  number: '4',
                  title: 'حذف دانشجو',
                  subtitle: 'Delete Student',
                  icon: Icons.person_remove_outlined,
                  onTap: () => _open(
                    StudentLookupScreen(
                        service: service, mode: LookupMode.delete),
                  ),
                ),
                _MenuTile(
                  number: '5',
                  title: 'خروج',
                  subtitle: 'Exit',
                  icon: Icons.logout,
                  onTap: _exitApp,
                  isExit: true,
                ),
                if (lastOperation != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('آخرین عملیات'),
                      subtitle: Text(lastOperation),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// وقتی خواندن فایل ممکن نیست: پیام خطا و دکمه تلاش دوباره.
  Widget _buildLoadError(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('خواندن اطلاعات ممکن نشد', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش دوباره'),
            ),
          ],
        ),
      ),
    );
  }
}

/// یکی از گزینه‌های منوی اصلی.
class _MenuTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isExit;

  const _MenuTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isExit = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isExit ? colors.error : colors.primary;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: isExit ? colors.onError : colors.onPrimary,
          child: Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(icon, color: color),
      ),
    );
  }
}
