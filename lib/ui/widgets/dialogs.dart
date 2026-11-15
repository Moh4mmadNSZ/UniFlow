import 'package:material_ui/material_ui.dart';

/// دیالوگ تأیید.
/// اگر کاربر دکمه تأیید را بزند true و در غیر این صورت false برمی‌گرداند.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: isDanger
                ? FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  // اگر کاربر بیرون از دیالوگ کلیک کند، result برابر null است.
  return result ?? false;
}

/// نمایش یک پیام کوتاه پایین صفحه. پیام خطا رنگ قرمز دارد.
void showMessage(BuildContext context, String text, {bool isError = false}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: isError ? colors.error : null,
    ),
  );
}
