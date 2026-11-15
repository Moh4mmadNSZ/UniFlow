// توابع کمکی برای کار با متن:
// تبدیل ارقام فارسی، مرتب‌سازی بر اساس الفبای فارسی و نمایش تاریخ.

/// ارقام فارسی (۰-۹) و عربی (٠-٩) را به ارقام انگلیسی تبدیل می‌کند.
/// علامت اعشار فارسی «٫» هم به نقطه تبدیل می‌شود.
/// مثال: '۱۰۰۱' ← '1001'
String normalizeDigits(String input) {
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  var result = input;
  for (var i = 0; i < 10; i++) {
    result = result.replaceAll(persianDigits[i], '$i');
    result = result.replaceAll(arabicDigits[i], '$i');
  }
  return result.replaceAll('٫', '.');
}

/// ترتیب حروف الفبای فارسی.
const String _persianAlphabet = 'آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی';

/// جایگاه یک حرف در الفبای فارسی.
/// حرفی که در الفبای فارسی نیست، بعد از همه حروف فارسی قرار می‌گیرد.
int _letterRank(String letter) {
  final index = _persianAlphabet.indexOf(letter);
  if (index != -1) {
    return index;
  }
  return 1000 + letter.codeUnitAt(0);
}

/// مقایسه دو متن بر اساس الفبای فارسی، برای مرتب‌سازی.
/// خروجی منفی یعنی a قبل از b می‌آید و خروجی مثبت یعنی بعد از آن.
int comparePersian(String a, String b) {
  final length = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < length; i++) {
    final difference = _letterRank(a[i]) - _letterRank(b[i]);
    if (difference != 0) {
      return difference;
    }
  }
  return a.length - b.length;
}

/// عدد را دو رقمی می‌کند. مثال: 3 ← 03
String twoDigits(int number) => number.toString().padLeft(2, '0');

/// تاریخ به شکل 2004-03-21
String formatDate(DateTime date) {
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

/// تاریخ و ساعت به شکل 2026-11-15 10:32
String formatDateTime(DateTime date) {
  return '${formatDate(date)} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}

/// اندازه فایل به شکل خوانا. مثال: «950 بایت» یا «2.4 کیلوبایت»
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes بایت';
  }
  return '${(bytes / 1024).toStringAsFixed(1)} کیلوبایت';
}
