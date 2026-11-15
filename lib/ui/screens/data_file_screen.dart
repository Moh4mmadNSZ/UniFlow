import 'package:material_ui/material_ui.dart';

import '../../services/student_service.dart';
import '../../utils/app_exceptions.dart';
import '../../utils/text_utils.dart';

/// مسیر، حجم و محتوای خام فایل داده را نشان می‌دهد؛
/// با این صفحه می‌توان ثابت کرد اطلاعات واقعاً در فایل ذخیره شده است.
class DataFileScreen extends StatefulWidget {
  final StudentService service;

  const DataFileScreen({super.key, required this.service});

  @override
  State<DataFileScreen> createState() => _DataFileScreenState();
}

class _DataFileScreenState extends State<DataFileScreen> {
  bool _isLoading = true;
  String _content = '';
  int _size = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  Future<void> _readFile() async {
    var content = '';
    var size = 0;
    String? error;
    try {
      content = await widget.service.readDataFileText();
      size = await widget.service.dataFileSize();
    } on AppException catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _content = content;
      _size = size;
      _error = error;
    });
  }

  void _reload() {
    setState(() => _isLoading = true);
    _readFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فایل داده'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'خواندن دوباره فایل',
            onPressed: _reload,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _buildContent(),
                ),
              ),
            ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final service = widget.service;
    final error = _error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اطلاعات دانشجویان در این فایل ذخیره می‌شود. '
                  'بعد از هر ثبت، ویرایش یا حذف، فایل دوباره نوشته می‌شود.',
                ),
                const SizedBox(height: 12),
                _infoRow(
                  'مسیر فایل',
                  SelectableText(
                    service.dataFilePath,
                    textDirection: TextDirection.ltr,
                  ),
                ),
                _infoRow('حجم فایل', Text(formatFileSize(_size))),
                _infoRow(
                  'تعداد دانشجویان',
                  Text('${service.allStudents.length}'),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                error,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'محتوای خام فایل (JSON)',
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _content.isEmpty
              ? const Text(
                  'فایل هنوز ساخته نشده است؛ با ثبت اولین دانشجو ساخته می‌شود.',
                )
              : SelectableText(
                  _content,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontFamilyFallback: ['Vazirmatn'],
                    fontSize: 13,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, Widget value) {
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
}
