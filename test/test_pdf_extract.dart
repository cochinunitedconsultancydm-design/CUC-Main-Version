// ignore_for_file: avoid_print
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final file = File(r'D:\Cochin United\Cochin United\CUC Main Version\new checklist\certificate-list-for-aadhaar-update (1).pdf');
  if (!await file.exists()) {
    print('File not found');
    return;
  }
  final bytes = await file.readAsBytes();
  final document = PdfDocument(inputBytes: bytes);
  final text = PdfTextExtractor(document).extractText();
  document.dispose();
  
  print('--- EXTRACTED TEXT ---');
  print(text);
  print('----------------------');
  print('Text length: ${text.length}');
}
