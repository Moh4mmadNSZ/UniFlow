import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/app_exceptions.dart';
import '../../utils/text_utils.dart';
import '../widgets/dialogs.dart';
import '../widgets/student_card.dart';
import '../widgets/student_info_view.dart';
import 'student_form_screen.dart';

/// این صفحه دو حالت دارد:
/// view: نمایش اطلاعات با شماره دانشجویی (گزینه ۳ منو)
/// delete: حذف دانشجو با شماره دانشجویی (گزینه ۴ منو)
enum LookupMode { view, delete }

class StudentLookupScreen extends StatefulWidget {
  final StudentService service;
  final LookupMode mode;

  const StudentLookupScreen({
    super.key,
    required this.service,
    required this.mode,
  });

  @override
  State<StudentLookupScreen> createState() => _StudentLookupScreenState();
}

class _StudentLookupScreenState extends State<StudentLookupScreen> {
  final _idController = TextEditingController();
  Student? _found; // دانشجوی پیدا شده
  String? _notFoundId; // شماره‌ای که جست‌وجو شد ولی پیدا نشد

  bool get _isDeleteMode => widget.mode == LookupMode.delete;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _search() {
    final id = normalizeDigits(_idController.text).trim();
    if (id.isEmpty) {
      showMessage(context, 'شماره دانشجویی را وارد کنید', isError: true);
      return;
    }
    final student = widget.service.findById(id);
    setState(() {
      _found = student;
      _notFoundId = student == null ? id : null;
    });
  }

  Future<void> _delete(Student student) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف دانشجو',
      message:
          'دانشجو «${student.fullName}» با شماره دانشجویی ${student.studentId} حذف شود؟ این کار قابل برگشت نیست.',
      confirmText: 'حذف',
      isDanger: true,
    );
    if (!mounted) return;
    if (!confirmed) {
      showMessage(context, 'حذف لغو شد');
      return;
    }

    try {
      await widget.service.deleteStudent(student.studentId);
      if (!mounted) return;
      showMessage(context, 'دانشجو ${student.studentId} حذف شد');
      setState(() {
        _found = null;
        _notFoundId = null;
        _idController.clear();
      });
    } on AppException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, isError: true);
    }
  }

  Future<void> _edit(Student student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentFormScreen(service: widget.service, student: student),
      ),
    );
    if (mounted) {
      setState(() => _found = widget.service.findById(student.studentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // متغیرهای محلی؛ تا Dart بتواند بعد از بررسی null، نوع آن‌ها را غیر null بداند.
    final found = _found;
    final notFoundId = _notFoundId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isDeleteMode ? 'حذف دانشجو' : 'نمایش اطلاعات با شماره دانشجویی',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isDeleteMode
                      ? 'شماره دانشجویی دانشجویی را که می‌خواهید حذف شود وارد کنید.'
                      : 'شماره دانشجویی را وارد کنید تا اطلاعات کامل او نمایش داده شود.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'شماره دانشجویی',
                          hintText: 'مثال: 1001',
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('جست‌وجو'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (notFoundId != null) _notFoundCard(notFoundId),
                if (found != null && !_isDeleteMode) ...[
                  StudentInfoView(student: found),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _edit(found),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('ویرایش اطلاعات'),
                  ),
                ],
                if (found != null && _isDeleteMode) _deletePreview(found),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notFoundCard(String id) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: colors.onErrorContainer),
        title: Text(
          'دانشجویی با شماره دانشجویی $id پیدا نشد',
          style: TextStyle(color: colors.onErrorContainer),
        ),
        subtitle: Text(
          'شماره را بررسی کنید یا از «نمایش همه دانشجویان» کمک بگیرید.',
          style: TextStyle(color: colors.onErrorContainer),
        ),
      ),
    );
  }

  Widget _deletePreview(Student student) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(student.firstName.substring(0, 1)),
              ),
              title: Text(student.fullName),
              subtitle: Text('${student.studentId} · ${student.major}'),
              trailing: StatusChip(status: student.status),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => _delete(student),
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف این دانشجو'),
            ),
          ],
        ),
      ),
    );
  }
}
