import 'package:material_ui/material_ui.dart';

import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../utils/app_exceptions.dart';
import '../../utils/faculties.dart';
import '../../utils/text_utils.dart';
import '../../utils/validators.dart';
import '../widgets/dialogs.dart';

/// فرم ثبت دانشجوی جدید و ویرایش دانشجوی موجود.
/// اگر student برابر null باشد فرم در حالت «ثبت» است، وگرنه در حالت «ویرایش».
class StudentFormScreen extends StatefulWidget {
  final StudentService service;
  final Student? student;

  const StudentFormScreen({super.key, required this.service, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // برای هر فیلد متنی یک کنترلر داریم تا متن آن را بخوانیم یا پر کنیم.
  final _studentIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _semesterController = TextEditingController();
  final _enrollmentDateController = TextEditingController();
  final _gpaController = TextEditingController();

  String? _faculty;
  String? _major;
  StudentStatus _status = StudentStatus.active;
  DateTime? _dateOfBirth;
  DateTime? _enrollmentDate;
  bool _isSaving = false;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    if (student != null) {
      // حالت ویرایش: فیلدها با اطلاعات فعلی دانشجو پر می‌شوند.
      _studentIdController.text = student.studentId;
      _firstNameController.text = student.firstName;
      _lastNameController.text = student.lastName;
      _nationalIdController.text = student.nationalId;
      _emailController.text = student.email;
      _phoneController.text = student.phone;
      _addressController.text = student.address ?? '';
      _semesterController.text = '${student.semester}';
      _gpaController.text = student.gpa?.toString() ?? '';
      _faculty = student.faculty;
      _major = student.major;
      _status = student.status;
      _dateOfBirth = student.dateOfBirth;
      _enrollmentDate = student.enrollmentDate;
      _dateOfBirthController.text = formatDate(student.dateOfBirth);
      _enrollmentDateController.text = formatDate(student.enrollmentDate);
    }
  }

  @override
  void dispose() {
    // کنترلرها حافظه می‌گیرند و وقتی صفحه بسته می‌شود باید آزاد شوند.
    final controllers = [
      _studentIdController,
      _firstNameController,
      _lastNameController,
      _nationalIdController,
      _dateOfBirthController,
      _emailController,
      _phoneController,
      _addressController,
      _semesterController,
      _enrollmentDateController,
      _gpaController,
    ];
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2004, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'تاریخ تولد را انتخاب کنید',
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickEnrollmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _enrollmentDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: 'تاریخ ورود را انتخاب کنید',
    );
    if (picked != null) {
      setState(() {
        _enrollmentDate = picked;
        _enrollmentDateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    // ۱. اجرای validator همه فیلدها. اگر یکی خطا داشته باشد، ذخیره انجام نمی‌شود.
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      showMessage(context, 'لطفاً خطاهای فرم را برطرف کنید', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    // ۲. ساختن شیء Student از ورودی‌ها. ارقام فارسی به انگلیسی تبدیل می‌شوند.
    final gpaText = normalizeDigits(_gpaController.text).trim();
    final addressText = _addressController.text.trim();
    final student = Student(
      studentId: normalizeDigits(_studentIdController.text).trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      nationalId: normalizeDigits(_nationalIdController.text).trim(),
      // علامت ! یعنی مطمئنیم مقدار null نیست، چون validator آن را بررسی کرده است.
      dateOfBirth: _dateOfBirth!,
      email: _emailController.text.trim(),
      phone: normalizeDigits(_phoneController.text).trim(),
      faculty: _faculty!,
      major: _major!,
      semester: int.parse(normalizeDigits(_semesterController.text).trim()),
      enrollmentDate: _enrollmentDate!,
      status: _status,
      gpa: gpaText.isEmpty ? null : double.parse(gpaText),
      address: addressText.isEmpty ? null : addressText,
      // در حالت ویرایش، زمان ثبت قبلی حفظ می‌شود.
      createdAt: widget.student?.createdAt,
    );

    // ۳. فرستادن به Service. اگر قانونی رعایت نشده باشد، Exception می‌گیریم.
    try {
      if (_isEditing) {
        await widget.service.updateStudent(student);
      } else {
        await widget.service.addStudent(student);
      }
      if (!mounted) return;
      showMessage(
        context,
        _isEditing
            ? 'تغییرات دانشجو ${student.studentId} ذخیره شد'
            : 'دانشجو ${student.studentId} با موفقیت ثبت شد',
      );
      Navigator.pop(context, true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showMessage(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش دانشجو' : 'ثبت دانشجوی جدید'),
      ),
      // SingleChildScrollView همه فیلدها را می‌سازد؛ پس validate همه آن‌ها را بررسی می‌کند.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('اطلاعات فردی'),
                  _textField(
                    controller: _studentIdController,
                    label: 'شماره دانشجویی',
                    hint: 'مثال: 1001',
                    validator: Validators.studentId,
                    leftToRight: true,
                    enabled: !_isEditing, // شماره دانشجویی در ویرایش قفل است
                  ),
                  _textField(
                    controller: _firstNameController,
                    label: 'نام',
                    validator: (value) =>
                        Validators.name(value, fieldName: 'نام'),
                  ),
                  _textField(
                    controller: _lastNameController,
                    label: 'نام خانوادگی',
                    validator: (value) => Validators.name(value,
                        fieldName: 'نام خانوادگی', max: 40),
                  ),
                  _textField(
                    controller: _nationalIdController,
                    label: 'کد ملی',
                    hint: '۱۰ رقم',
                    validator: Validators.nationalId,
                    leftToRight: true,
                  ),
                  _dateField(
                    controller: _dateOfBirthController,
                    label: 'تاریخ تولد',
                    onTap: _pickDateOfBirth,
                    validator: (_) => Validators.dateOfBirth(_dateOfBirth),
                  ),
                  _sectionTitle('اطلاعات تماس'),
                  _textField(
                    controller: _emailController,
                    label: 'ایمیل',
                    hint: 'name@example.com',
                    validator: Validators.email,
                    leftToRight: true,
                  ),
                  _textField(
                    controller: _phoneController,
                    label: 'شماره موبایل',
                    hint: '09121234567',
                    validator: Validators.phone,
                    leftToRight: true,
                  ),
                  _textField(
                    controller: _addressController,
                    label: 'آدرس (اختیاری)',
                    validator: Validators.address,
                    maxLines: 2,
                  ),
                  _sectionTitle('اطلاعات تحصیلی'),
                  _facultyField(),
                  _majorField(),
                  _textField(
                    controller: _semesterController,
                    label: 'ترم',
                    hint: '۱ تا ۱۲',
                    validator: Validators.semester,
                    leftToRight: true,
                  ),
                  _dateField(
                    controller: _enrollmentDateController,
                    label: 'تاریخ ورود',
                    onTap: _pickEnrollmentDate,
                    validator: (_) => Validators.enrollmentDate(
                        _enrollmentDate, _dateOfBirth),
                  ),
                  _statusField(),
                  _textField(
                    controller: _gpaController,
                    label: 'معدل (اختیاری)',
                    hint: 'مثال: 17.25',
                    validator: Validators.gpa,
                    leftToRight: true,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    // تا وقتی ذخیره تمام نشده، دکمه غیرفعال است تا دو بار ثبت نشود.
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isEditing ? 'ذخیره تغییرات' : 'ثبت دانشجو'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    FormFieldValidator<String>? validator,
    bool leftToRight = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        // شماره، ایمیل و تلفن چپ‌چین نوشته می‌شوند.
        textDirection: leftToRight ? TextDirection.ltr : null,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  /// فیلد تاریخ: فقط‌خواندنی است و با کلیک، تقویم باز می‌شود.
  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        validator: validator,
      ),
    );
  }

  Widget _facultyField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _faculty,
        decoration: const InputDecoration(labelText: 'دانشکده'),
        items: [
          for (final faculty in facultyMajors.keys)
            DropdownMenuItem(value: faculty, child: Text(faculty)),
        ],
        onChanged: (value) {
          setState(() {
            _faculty = value;
            _major = null; // با عوض شدن دانشکده، رشته باید دوباره انتخاب شود
          });
        },
        validator: Validators.faculty,
      ),
    );
  }

  Widget _majorField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _major,
        decoration: const InputDecoration(labelText: 'رشته'),
        // فقط رشته‌های دانشکده انتخاب‌شده نمایش داده می‌شوند.
        items: [
          for (final major in majorsOf(_faculty))
            DropdownMenuItem(value: major, child: Text(major)),
        ],
        onChanged: (value) => setState(() => _major = value),
        validator: (value) => Validators.major(value, _faculty),
      ),
    );
  }

  Widget _statusField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<StudentStatus>(
        initialValue: _status,
        decoration: const InputDecoration(labelText: 'وضعیت تحصیلی'),
        items: [
          for (final status in StudentStatus.values)
            DropdownMenuItem(value: status, child: Text(statusLabel(status))),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _status = value);
          }
        },
      ),
    );
  }
}
