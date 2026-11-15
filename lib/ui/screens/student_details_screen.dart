import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/app_exceptions.dart';
import '../widgets/dialogs.dart';
import '../widgets/student_info_view.dart';
import 'student_form_screen.dart';

/// صفحه جزئیات یک دانشجو، با دکمه‌های ویرایش و حذف.
class StudentDetailsScreen extends StatefulWidget {
  final StudentService service;
  final Student student;

  const StudentDetailsScreen({
    super.key,
    required this.service,
    required this.student,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  // late یعنی مقدار این متغیر بعداً (در initState) داده می‌شود.
  late Student _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  Future<void> _edit() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentFormScreen(service: widget.service, student: _student),
      ),
    );
    // اگر تغییرات ذخیره شده باشد، اطلاعات تازه را از Service می‌گیریم.
    if (saved == true) {
      final updated = widget.service.findById(_student.studentId);
      if (updated != null && mounted) {
        setState(() => _student = updated);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف دانشجو',
      message:
          'دانشجو «${_student.fullName}» با شماره دانشجویی ${_student.studentId} حذف شود؟ این کار قابل برگشت نیست.',
      confirmText: 'حذف',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await widget.service.deleteStudent(_student.studentId);
      if (!mounted) return;
      showMessage(context, 'دانشجو ${_student.studentId} حذف شد');
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      showMessage(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'ویرایش',
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'حذف',
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: StudentInfoView(student: _student),
          ),
        ),
      ),
    );
  }
}
