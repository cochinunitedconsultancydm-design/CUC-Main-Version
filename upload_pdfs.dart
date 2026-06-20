import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    await supabase.storage.createBucket('service_documents', const BucketOptions(public: true));
    print('Bucket created successfully');
  } catch (e) {
    print('Bucket might already exist or creation failed: $e');
  }

  final dir = Directory(r'D:\Cochin United\Cochin United\CUC Main Version\new checklist');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.pdf')).toList();
  print('Found ${files.length} PDFs');

  final existingServicesRaw = await supabase.from('service_content').select('id, title, details');
  final existingServices = List<Map<String, dynamic>>.from(existingServicesRaw);

  int missingCount = 0;
  int uploadCount = 0;

  for (var file in files) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final baseName = fileName.replaceAll('.pdf', '');

    // Attempt to upload
    final uploadPath = 'docs/$fileName';
    String? publicUrl;
    try {
      final bytes = await file.readAsBytes();
      await supabase.storage.from('service_documents').uploadBinary(uploadPath, bytes, fileOptions: const FileOptions(upsert: true));
      publicUrl = supabase.storage.from('service_documents').getPublicUrl(uploadPath);
      uploadCount++;
      print('Uploaded: $fileName');
    } catch (e) {
      print('Failed to upload $fileName: $e');
    }

    var match = existingServices.where((s) {
      final t = s['title'].toString().toLowerCase();
      final b = baseName.toLowerCase();
      final bClean = b.replaceAll(RegExp(r'\(\d+\)'), '').trim();
      return t == b || t == bClean || b.contains(t) || t.contains(bClean) || t.replaceAll(' ', '') == bClean.replaceAll(' ', '');
    }).firstOrNull;

    if (match != null) {
      if (publicUrl != null) {
        final details = Map<String, dynamic>.from(match['details'] ?? {});
        details['document_url'] = publicUrl;
        await supabase.from('service_content').update({'details': details}).eq('id', match['id']);
      }
    } else {
      print('No matching service found for $baseName, parsing PDF...');
      missingCount++;
      try {
        final bytes = await file.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(document);
        final text = extractor.extractText();
        document.dispose();
        
        final details = {
          'faqs': [],
          'notes': text,
        };
        if (publicUrl != null) {
          details['document_url'] = publicUrl;
        }

        await supabase.from('service_content').insert({
          'title': baseName,
          'description': 'Requirements and checklist for $baseName.',
          'service_id': 606,
          'details': details,
        });
        print('Inserted missing service: $baseName');
      } catch (e) {
        print('Failed to parse/insert $fileName: $e');
      }
    }
  }

  print('Upload complete. Uploaded: $uploadCount. Inserted Missing: $missingCount.');
}
