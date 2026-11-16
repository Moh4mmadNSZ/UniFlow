// منوی اصلی برنامه و کار هر گزینه.

import 'app_exceptions.dart';
import 'console_input.dart';
import 'console_output.dart';
import 'faculties.dart';
import 'student.dart';
import 'student_manager.dart';
import 'utils.dart';
import 'validators.dart';

class StudentMenu {
  final StudentManager manager;

  StudentMenu(this.manager);

  /// منو را نشان می‌دهد و تا وقتی کاربر گزینه ۵ (Exit) را نزده، تکرار می‌کند.
  Future<void> run() async {
    while (true) {
      _printMenu();
      final choice = readLine('Choose an option (1-8): ');
      switch (choice) {
        case '1':
          await _addStudent();
        case '2':
          _showAll();
        case '3':
          _showInfoById();
        case '4':
          await _deleteStudent();
        case '5':
          printSuccess(
              'All data is saved in ${manager.storage.filePath}. Goodbye!');
          return;
        case '6':
          await _editStudent();
        case '7':
          _searchStudents();
        case '8':
          _showStatistics();
        default:
          printError('Please enter a number from 1 to 8.');
          continue;
      }
      waitForEnter();
    }
  }

  void _printMenu() {
    print('');
    print('==========================================');
    print('  UniFlow - Student Registration System');
    print('  Students saved: ${manager.count}');
    print('==========================================');
    print('  1) Add Student');
    print('  2) Show All');
    print('  3) Show Info by ID');
    print('  4) Delete Student');
    print('  5) Exit');
    print('------------------------------------------');
    print('  6) Edit Student');
    print('  7) Search Students');
    print('  8) Statistics');
    print('==========================================');
  }

  /// گزینه ۱: ثبت دانشجوی جدید.
  Future<void> _addStudent() async {
    printTitle('Add Student');

    // تکراری بودن شماره همین اول بررسی می‌شود تا کاربر بقیه فرم را بیهوده پر نکند.
    final studentId = askUntilValid('Student ID (4-10 digits): ', (value) {
      final error = validateStudentId(value);
      if (error != null) {
        return error;
      }
      if (manager.findById(value) != null) {
        return 'A student with ID $value already exists.';
      }
      return null;
    });
    final firstName = askUntilValid(
        'First name: ', (value) => validateName(value, 'First name'));
    final lastName = askUntilValid(
        'Last name: ', (value) => validateName(value, 'Last name'));
    final nationalId =
        askUntilValid('National ID (10 digits): ', validateNationalId);
    final dateOfBirth =
        askDate('Date of birth (YYYY-MM-DD): ', validateDateOfBirth);
    final email = askUntilValid('Email: ', validateEmail);
    final phone = askUntilValid('Phone (09xxxxxxxxx): ', validatePhone);
    final faculty = _askFaculty();
    final major = _askMajor(faculty);
    final semester =
        int.parse(askUntilValid('Semester (1-12): ', validateSemester));
    final enrollmentDate = askDate(
      'Enrollment date (YYYY-MM-DD, Enter = today): ',
      (date) => validateEnrollmentDate(date, dateOfBirth),
      defaultValue: _today(),
    );
    final status = _askStatus();
    final gpaText = askUntilValid('GPA (0-20, Enter to skip): ', validateGpa);
    final address = askUntilValid('Address (Enter to skip): ', validateAddress);

    final student = Student(
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      nationalId: nationalId,
      dateOfBirth: dateOfBirth,
      email: email,
      phone: phone,
      faculty: faculty,
      major: major,
      semester: semester,
      enrollmentDate: enrollmentDate,
      status: status,
      gpa: gpaText.isEmpty ? null : double.parse(gpaText),
      address: address.isEmpty ? null : address,
    );

    try {
      await manager.addStudent(student);
      printSuccess(
          'Student ${student.studentId} (${student.fullName}) was added and saved.');
    } on StudentException catch (e) {
      printError(e.message);
    } on StorageException catch (e) {
      printError(e.message);
    }
  }

  /// گزینه ۲: نمایش همه دانشجویان.
  void _showAll() {
    printTitle('All Students');
    final students = manager.getAll();
    if (students.isEmpty) {
      printInfo('No students registered yet. Use option 1 to add one.');
      return;
    }
    printStudentTable(students);
    printInfo('\nTotal: ${students.length} student(s)');
  }

  /// گزینه ۳: نمایش اطلاعات کامل یک دانشجو با شماره دانشجویی.
  void _showInfoById() {
    printTitle('Show Info by ID');
    final student = _askExistingStudent();
    if (student != null) {
      printStudentDetails(student);
    }
  }

  /// گزینه ۴: حذف دانشجو، بعد از گرفتن تأیید.
  Future<void> _deleteStudent() async {
    printTitle('Delete Student');
    final student = _askExistingStudent();
    if (student == null) {
      return;
    }
    printStudentDetails(student);
    final sure = askYesNo('\nDelete ${student.fullName} '
        '(${student.studentId})? This cannot be undone.');
    if (!sure) {
      printInfo('Delete cancelled. Nothing was changed.');
      return;
    }

    try {
      await manager.deleteStudent(student.studentId);
      printSuccess('Student ${student.studentId} was deleted.');
    } on StudentException catch (e) {
      printError(e.message);
    } on StorageException catch (e) {
      printError(e.message);
    }
  }

  /// گزینه ۶: ویرایش اطلاعات دانشجو. با Enter مقدار فعلی حفظ می‌شود.
  Future<void> _editStudent() async {
    printTitle('Edit Student');
    final old = _askExistingStudent();
    if (old == null) {
      return;
    }
    printInfo('Press Enter to keep the current value.');

    final firstName = askOrKeep('First name', old.firstName,
        (value) => validateName(value, 'First name'));
    final lastName = askOrKeep(
        'Last name', old.lastName, (value) => validateName(value, 'Last name'));
    final nationalId =
        askOrKeep('National ID', old.nationalId, validateNationalId);
    final dateOfBirth = askDate(
      'Date of birth [${formatDate(old.dateOfBirth)}]: ',
      validateDateOfBirth,
      defaultValue: old.dateOfBirth,
    );
    final email = askOrKeep('Email', old.email, validateEmail);
    final phone = askOrKeep('Phone', old.phone, validatePhone);
    final faculty = _askFaculty(current: old.faculty);
    final major = _askMajor(faculty, current: old.major);
    final semester =
        int.parse(askOrKeep('Semester', '${old.semester}', validateSemester));
    final enrollmentDate = askDate(
      'Enrollment date [${formatDate(old.enrollmentDate)}]: ',
      (date) => validateEnrollmentDate(date, dateOfBirth),
      defaultValue: old.enrollmentDate,
    );
    final status = _askStatus(current: old.status);
    final gpaText = askOrKeep('GPA', old.gpa?.toString() ?? '', validateGpa);
    final address = askOrKeep('Address', old.address ?? '', validateAddress);

    // شماره دانشجویی و زمان ثبت عوض نمی‌شوند؛ زمان ویرایش خودکار «الان» می‌شود.
    final updated = Student(
      studentId: old.studentId,
      firstName: firstName,
      lastName: lastName,
      nationalId: nationalId,
      dateOfBirth: dateOfBirth,
      email: email,
      phone: phone,
      faculty: faculty,
      major: major,
      semester: semester,
      enrollmentDate: enrollmentDate,
      status: status,
      gpa: gpaText.isEmpty ? null : double.parse(gpaText),
      address: address.isEmpty ? null : address,
      createdAt: old.createdAt,
    );

    try {
      await manager.updateStudent(updated);
      printSuccess('Student ${old.studentId} was updated.');
    } on StudentException catch (e) {
      printError(e.message);
    } on StorageException catch (e) {
      printError(e.message);
    }
  }

  /// گزینه ۷: جست‌وجو با نام، رشته یا شماره دانشجویی.
  void _searchStudents() {
    printTitle('Search Students');
    final text = readLine('Name, major or student ID: ');
    if (text.isEmpty) {
      printError('Please type something to search for.');
      return;
    }
    final results = manager.search(text);
    if (results.isEmpty) {
      printInfo('No students match "$text".');
      return;
    }
    printStudentTable(results);
    printInfo('\n${results.length} student(s) found.');
  }

  /// گزینه ۸: آمار.
  void _showStatistics() {
    printTitle('Statistics');
    final average = manager.averageGpa();
    printInfo('  Total students : ${manager.count}');
    printInfo(
        '  Active         : ${manager.countByStatus(StudentStatus.active)}');
    printInfo(
        '  Suspended      : ${manager.countByStatus(StudentStatus.suspended)}');
    printInfo(
        '  Graduated      : ${manager.countByStatus(StudentStatus.graduated)}');
    printInfo('  Majors         : ${manager.countMajors()}');
    printInfo(
        '  Average GPA    : ${average == null ? '-' : average.toStringAsFixed(2)}');
  }

  /// شماره دانشجویی را می‌پرسد و دانشجو را برمی‌گرداند.
  /// اگر پیدا نشود، پیام می‌دهد و null برمی‌گرداند.
  Student? _askExistingStudent() {
    final id = readLine('Student ID: ');
    if (id.isEmpty) {
      printError('Student ID is required.');
      return null;
    }
    final student = manager.findById(id);
    if (student == null) {
      printError('No student with ID $id was found.');
    }
    return student;
  }

  String _askFaculty({String? current}) {
    final faculties = facultyMajors.keys.toList();
    final currentIndex = current == null ? -1 : faculties.indexOf(current);
    final index = askChoice('Faculty:', faculties,
        defaultIndex: currentIndex == -1 ? null : currentIndex);
    return faculties[index];
  }

  String _askMajor(String faculty, {String? current}) {
    final majors = facultyMajors[faculty]!;
    final currentIndex = current == null ? -1 : majors.indexOf(current);
    final index = askChoice('Major:', majors,
        defaultIndex: currentIndex == -1 ? null : currentIndex);
    return majors[index];
  }

  StudentStatus _askStatus({StudentStatus current = StudentStatus.active}) {
    final labels = <String>[];
    for (final status in StudentStatus.values) {
      labels.add(statusLabel(status));
    }
    final index = askChoice('Status:', labels, defaultIndex: current.index);
    return StudentStatus.values[index];
  }

  /// تاریخ امروز بدون ساعت.
  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
