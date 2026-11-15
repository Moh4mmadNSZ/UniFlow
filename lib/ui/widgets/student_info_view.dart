import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../utils/text_utils.dart';
import 'student_card.dart';

/// نمایش کامل اطلاعات یک دانشجو در چند بخش.
/// هم صفحه جزئیات و هم صفحه جست‌وجو با شماره دانشجویی از آن استفاده می‌کنند.
class StudentInfoView extends StatelessWidget {
  final Student student;

  const StudentInfoView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final gpa = student.gpa;
    final address = student.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(context, 'اطلاعات فردی', [
          _row(context, 'شماره دانشجویی', _text(student.studentId)),
          _row(context, 'نام', _text(student.firstName)),
          _row(context, 'نام خانوادگی', _text(student.lastName)),
          _row(context, 'کد ملی', _text(student.nationalId)),
          _row(context, 'تاریخ تولد', _text(formatDate(student.dateOfBirth))),
        ]),
        _section(context, 'اطلاعات تماس', [
          _row(context, 'ایمیل', _text(student.email)),
          _row(context, 'شماره موبایل', _text(student.phone)),
          _row(context, 'آدرس', _text(address ?? 'ثبت نشده')),
        ]),
        _section(context, 'اطلاعات تحصیلی', [
          _row(context, 'دانشکده', _text(student.faculty)),
          _row(context, 'رشته', _text(student.major)),
          _row(context, 'ترم', _text('${student.semester}')),
          _row(context, 'تاریخ ورود',
              _text(formatDate(student.enrollmentDate))),
          _row(
            context,
            'وضعیت',
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusChip(status: student.status),
            ),
          ),
          _row(
            context,
            'معدل',
            _text(gpa == null ? 'هنوز ثبت نشده' : gpa.toStringAsFixed(2)),
          ),
        ]),
        _section(context, 'سابقه', [
          _row(context, 'زمان ثبت', _text(formatDateTime(student.createdAt))),
          _row(context, 'آخرین ویرایش',
              _text(formatDateTime(student.updatedAt))),
        ]),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _text(String value) => SelectableText(value);
}
