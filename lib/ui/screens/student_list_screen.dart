import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/student_card.dart';
import 'student_details_screen.dart';
import 'student_form_screen.dart';

/// فهرست همه دانشجویان، با جست‌وجو، فیلتر و مرتب‌سازی (گزینه ۲ منو).
class StudentListScreen extends StatefulWidget {
  final StudentService service;

  const StudentListScreen({super.key, required this.service});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  StudentStatus? _statusFilter; // null یعنی همه وضعیت‌ها
  String? _majorFilter; // null یعنی همه رشته‌ها
  SortOption _sortBy = SortOption.studentId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetails(Student student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentDetailsScreen(service: widget.service, student: student),
      ),
    );
    // شاید دانشجو ویرایش یا حذف شده باشد، پس فهرست دوباره ساخته می‌شود.
    if (mounted) setState(() {});
  }

  Future<void> _openAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(service: widget.service),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final majors = service.majorsInUse();
    // اگر رشته انتخاب‌شده دیگر دانشجویی نداشته باشد، فیلتر رشته نادیده گرفته می‌شود.
    final selectedMajor = majors.contains(_majorFilter) ? _majorFilter : null;
    final students = service.search(
      query: _query,
      status: _statusFilter,
      major: selectedMajor,
      sortBy: _sortBy,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('فهرست دانشجویان')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('ثبت دانشجو'),
      ),
      body: service.allStudents.isEmpty
          ? EmptyState(
              icon: Icons.school_outlined,
              message: 'هنوز دانشجویی ثبت نشده است',
              actionLabel: 'ثبت اولین دانشجو',
              onAction: _openAddForm,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _buildFilters(majors, selectedMajor),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('${students.length} دانشجو'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: students.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off,
                              message: 'دانشجویی با این مشخصات پیدا نشد',
                            )
                          // ListView.builder فقط ردیف‌هایی را می‌سازد که روی صفحه دیده می‌شوند.
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                return StudentCard(
                                  student: student,
                                  onTap: () => _openDetails(student),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilters(List<String> majors, String? selectedMajor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'جست‌وجو با نام، رشته یا شماره دانشجویی',
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'پاک کردن جست‌وجو',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('همه'),
                selected: _statusFilter == null,
                onSelected: (_) => setState(() => _statusFilter = null),
              ),
              for (final status in StudentStatus.values)
                ChoiceChip(
                  label: Text(statusLabel(status)),
                  selected: _statusFilter == status,
                  onSelected: (_) => setState(() => _statusFilter = status),
                ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedMajor,
                  isDense: true,
                  decoration: const InputDecoration(labelText: 'رشته'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('همه رشته‌ها'),
                    ),
                    for (final major in majors)
                      DropdownMenuItem<String?>(
                        value: major,
                        child: Text(major),
                      ),
                  ],
                  onChanged: (value) => setState(() => _majorFilter = value),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<SortOption>(
                  initialValue: _sortBy,
                  isDense: true,
                  decoration: const InputDecoration(labelText: 'مرتب‌سازی'),
                  items: [
                    for (final option in SortOption.values)
                      DropdownMenuItem(
                        value: option,
                        child: Text(sortLabel(option)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
