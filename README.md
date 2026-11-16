# UniFlow

<div dir="rtl">

**سامانه ثبت‌نام و مدیریت دانشجویان** — پروژه درس برنامه‌نویسی موبایل، نوشته‌شده فقط با زبان Dart

یک برنامه کنسولی (ترمینالی) با منوی عددی. اطلاعات دانشجویان در فایل `data/students.json` ذخیره می‌شود، پس با بستن برنامه از بین نمی‌رود و در اجرای بعدی دوباره خوانده می‌شود.

## امکانات

| گزینه منو | کار |
|---|---|
| 1) Add Student | ثبت دانشجوی جدید. هر ورودی بررسی می‌شود و شماره دانشجویی تکراری پذیرفته نمی‌شود. |
| 2) Show All | جدول همه دانشجویان به ترتیب شماره دانشجویی |
| 3) Show Info by ID | نمایش اطلاعات کامل یک دانشجو با شماره دانشجویی |
| 4) Delete Student | حذف دانشجو بعد از گرفتن تأیید (y/n) |
| 5) Exit | خروج از برنامه |
| 6) Edit Student | ویرایش اطلاعات؛ با زدن Enter مقدار فعلی حفظ می‌شود |
| 7) Search Students | جست‌وجو با نام، رشته یا شماره دانشجویی |
| 8) Statistics | تعداد کل، فعال، تعلیق و فارغ‌التحصیل، تعداد رشته‌ها و میانگین معدل |

- **Save in File:** بعد از هر ثبت، ویرایش یا حذف، فایل همان لحظه ذخیره می‌شود.
- **بررسی ورودی‌ها:** شماره دانشجویی، نام، کد ملی، تاریخ‌ها، ایمیل، موبایل، ترم و معدل. اگر ورودی نادرست باشد، پیام خطا نمایش داده می‌شود و همان سؤال دوباره پرسیده می‌شود. ارقام فارسی هم پذیرفته می‌شوند.
- **حفاظت از فایل:** اگر فایل وجود نداشته باشد، برنامه با فهرست خالی شروع می‌شود. اگر فایل خراب باشد، کنار گذاشته می‌شود و رونویسی نمی‌شود. اگر خواندن فایل ممکن نباشد، برنامه متوقف می‌شود تا فایل پاک نشود. نوشتن هم اول در یک فایل موقت انجام می‌شود.
- **۴۵ تست خودکار** برای مدل، بررسی ورودی‌ها، فایل و مدیریت دانشجویان.

## پیش‌نیاز

Dart نسخه 3.5 یا بالاتر. اگر Flutter نصب است، Dart هم همراه آن نصب شده است (Flutter 3.50 همراه با Dart 3.14).

## اجرا

</div>

```bash
git clone https://github.com/Moh4mmadNSZ/UniFlow.git
cd UniFlow
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
dart pub get
dart run
```

<div dir="rtl">

دو خط `export` برای وقتی است که pub.dev در دسترس نیست و پکیج‌ها از یک میرور دانلود می‌شوند. اگر pub.dev باز است، به آن‌ها نیازی نیست.

ساخت یک فایل اجرایی مستقل:

</div>

```bash
dart compile exe bin/uniflow.dart -o uniflow
./uniflow
```

<div dir="rtl">

اجرای تست‌ها و بررسی کد:

</div>

```bash
dart test
dart analyze
```

<div dir="rtl">

## نمونه اجرا

این خروجی از یک اجرای واقعی برنامه است. نام‌ها و شماره‌ها ساختگی‌اند.

</div>

```text
==========================================
  UniFlow - Student Registration System
  Students saved: 2
==========================================
  1) Add Student
  2) Show All
  3) Show Info by ID
  4) Delete Student
  5) Exit
------------------------------------------
  6) Edit Student
  7) Search Students
  8) Statistics
==========================================
Choose an option (1-8): 2

=== All Students ===
ID         Name                Major                 Sem Status     GPA
-----------------------------------------------------------------------
1001       Sara Rezaei         Computer Engineering  3   Active     17.25
1002       Ali Karimi          Physics               5   Suspended  15.50

Total: 2 student(s)
```

```text
=== Add Student ===
Student ID (4-10 digits): 1001
Error: A student with ID 1001 already exists.
Student ID (4-10 digits): 1002
First name: Ali
Last name: Karimi
National ID (10 digits): 0012345679
Date of birth (YYYY-MM-DD): 2003-01-10
Email: ali.karimi@example.com
Phone (09xxxxxxxxx): 09351234567
Faculty:
  1) Engineering
  2) Basic Sciences
  3) Humanities
  4) Management and Economics
  5) Art and Architecture
Choose 1-5: 2
Major:
  1) Applied Mathematics
  2) Physics
  3) Chemistry
  4) Statistics
Choose 1-4: 2
Semester (1-12): 5
Enrollment date (YYYY-MM-DD, Enter = today): 2022-09-23
Status:
  1) Active
  2) Suspended
  3) Graduated
Choose 1-3 [1]: 2
GPA (0-20, Enter to skip): 15.5
Address (Enter to skip): Tehran
OK: Student 1002 (Ali Karimi) was added and saved.
```

```text
=== Delete Student ===
Student ID: 1002
  ...
Delete Ali Karimi (1002)? This cannot be undone. (y/n): n
Delete cancelled. Nothing was changed.
```

<div dir="rtl">

## فایل داده

فایل در پوشه `data` و کنار پروژه ساخته می‌شود؛ یعنی نسبت به پوشه‌ای که برنامه را از آن اجرا می‌کنید. مسیر کامل آن هنگام شروع برنامه چاپ می‌شود. فایل یک فهرست JSON است:

</div>

```json
[
  {
    "studentId": "1001",
    "firstName": "Sara",
    "lastName": "Rezaei",
    "nationalId": "0012345678",
    "dateOfBirth": "2004-03-21",
    "email": "sara.rezaei@example.com",
    "phone": "09121234567",
    "faculty": "Engineering",
    "major": "Computer Engineering",
    "semester": 3,
    "enrollmentDate": "2024-09-22",
    "status": "active",
    "gpa": 17.25,
    "address": null,
    "createdAt": "2026-11-16T07:50:14.934212",
    "updatedAt": "2026-11-16T07:50:14.934212"
  }
]
```

<div dir="rtl">

## ساختار پروژه

</div>

```text
bin/
  uniflow.dart            start of the program: reads the file, runs the menu
lib/
  student.dart            Student class and StudentStatus enum, JSON conversion
  student_storage.dart    reads and writes data/students.json
  student_manager.dart    list of students: add, find, update, delete, search, stats
  student_menu.dart       the menu and what each option does
  console_input.dart      asks questions until the answer is valid
  console_output.dart     messages, the students table and the details view
  validators.dart         rules for every field
  faculties.dart          faculties and their majors
  app_exceptions.dart     StudentException and StorageException
  utils.dart              date helpers and Persian digit conversion
test/                     automated tests (dart test)
```

<div dir="rtl">

مسیر کار: `StudentMenu` ورودی را می‌گیرد ← `StudentManager` قوانین را بررسی می‌کند و فهرست را تغییر می‌دهد ← `StudentStorage` فهرست را در فایل JSON می‌نویسد.

## محدودیت‌ها

- برنامه یک‌کاربره است و رابط گرافیکی ندارد.
- با هر تغییر، کل فایل دوباره نوشته می‌شود. این روش برای چند هزار دانشجو مناسب است، ولی برای تعداد خیلی بیشتر بهتر است از پایگاه داده استفاده شود.
- تاریخ‌ها میلادی هستند.

## نسخه Flutter

نسخه قبلی این پروژه، که با Flutter و رابط گرافیکی ساخته شده بود، در تاریخچه گیت در کامیت `567aeb2` باقی مانده است.

</div>
