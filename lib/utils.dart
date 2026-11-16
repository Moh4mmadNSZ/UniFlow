// توابع کمکی کوچک که در چند جای برنامه استفاده می‌شوند.

/// ارقام فارسی و عربی را به ارقام انگلیسی تبدیل می‌کند.
/// مثال: '۱۰۰۱' ← '1001' و '۱۷٫۵' ← '17.5'
String normalizeDigits(String text) {
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  var result = text;
  for (var i = 0; i < 10; i++) {
    result = result.replaceAll(persianDigits[i], '$i');
    result = result.replaceAll(arabicDigits[i], '$i');
  }
  return result.replaceAll('٫', '.');
}

/// عدد را دو رقمی می‌کند. مثال: 3 ← '03'
String twoDigits(int number) => number.toString().padLeft(2, '0');

/// تاریخ را به شکل 2004-03-21 برمی‌گرداند.
String formatDate(DateTime date) {
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

/// تاریخ و ساعت را به شکل 2026-11-16 10:30 برمی‌گرداند.
String formatDateTime(DateTime date) {
  return '${formatDate(date)} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}

/// متنی مثل '2004-03-21' را به تاریخ تبدیل می‌کند.
/// اگر متن تاریخ درستی نباشد، null برمی‌گرداند.
DateTime? parseDate(String text) {
  final parts = text.trim().split('-');
  if (parts.length != 3 || parts[0].length != 4) {
    return null;
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }
  final date = DateTime(year, month, day);
  // DateTime تاریخ نادرستی مثل 2004-02-30 را به ماه بعد می‌برد،
  // پس بررسی می‌کنیم ماه و روز عوض نشده باشند.
  if (date.month != month || date.day != day) {
    return null;
  }
  return date;
}
