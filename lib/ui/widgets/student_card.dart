import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../app_theme.dart';

/// برچسب رنگی وضعیت تحصیلی، مثل «فعال».
class StatusChip extends StatelessWidget {
  final StudentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// یک ردیف در فهرست دانشجویان.
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(student.firstName.substring(0, 1))),
        title: Text(student.fullName),
        subtitle: Text('${student.studentId} · ${student.major}'),
        trailing: StatusChip(status: student.status),
      ),
    );
  }
}
