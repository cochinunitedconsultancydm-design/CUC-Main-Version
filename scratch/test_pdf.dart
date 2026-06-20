import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  try {
    final dir = Directory(r'D:\Cochin United\Cochin United\CUC Main Version\new checklist');
    if (!await dir.exists()) {
      print('Directory not found');
      return;
    }

    final files = dir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.pdf')).toList();
    print('Found ${files.length} PDFs');
    
    if (files.isEmpty) return;

    var file = files.first;
    print('Parsing ${file.path}...');
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    
    print('Text length: ${text.length}');
    print('First 100 chars: ${text.substring(0, text.length > 100 ? 100 : text.length)}');

    String fileName = file.uri.pathSegments.last;
    String title = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'checklist', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'\(\d+\)'), '');
    title = title.replaceAll('-', ' ');
    title = title.replaceAll('_', ' ');
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    print('Cleaned title: $title');

  } catch (e, stack) {
    print('Error: $e\n$stack');
  }
}
