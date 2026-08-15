import 'dart:io';

void main() {
  final filesToPatch = [
    'lib/widgets/add_license_dialog.dart',
    'lib/services/office_location_service.dart',
    'lib/screens/staff_management_screen.dart',
    'lib/screens/sop_screen.dart',
    'lib/screens/property_management_screen.dart',
    'lib/screens/hr_performance_screen.dart',
    'lib/screens/client_files_dialog.dart',
    'lib/screens/client_portal/client_deals_view.dart',
    'lib/screens/client_portal/client_documents_view.dart'
  ];

  for (final filePath in filesToPatch) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('File not found: $filePath');
      continue;
    }

    var content = file.readAsStringSync();

    // Check if already patched
    if (content.contains('backupFileInBackground')) {
      print('Already patched: $filePath');
      continue;
    }

    // Add imports if missing
    if (!content.contains('supabase_backup_service.dart')) {
      // Find the right import path
      final depth = filePath.split('/').length - 2;
      final prefix = depth > 0 ? '../' * depth : './';
      content = "import '${prefix}services/supabase_backup_service.dart';\n" + content;
    }
    if (!content.contains('dart:io')) {
      content = "import 'dart:io';\n" + content;
    }

    // Identify what variable has the path.
    // This regex looks for `AWSFile.fromPath(VAR)` or `localFile: AWSFile.fromPath(VAR)` or `AWSFile.fromData`
    // Actually, since they differ, let's just do a basic string replacement tailored for each file type, or a smart regex.
    
    // We can replace `.result;` with `.result;` followed by the backup code.
    // We need to extract the path variable from `AWSFile.fromPath(VAR)`
    
    final RegExp uploadRegex = RegExp(r'await\s+Amplify\.Storage\.uploadFile\([\s\S]*?AWSFile\.fromPath\(([^)]+)\)[\s\S]*?path:\s*StoragePath\.fromString\(([^)]+)\)[\s\S]*?}\)\.result;');
    
    // Some use `localFile: localFile` (office_location_service, property_management, client_deals_view)
    
    content = content.replaceAllMapped(RegExp(r'(await\s+Amplify\.Storage\.uploadFile\([\s\S]*?\)\.result;)'), (match) {
      final text = match.group(1)!;
      // Extract S3 key
      final keyMatch = RegExp(r'StoragePath\.fromString\(([^)]+)\)').firstMatch(text);
      if (keyMatch == null) return text;
      final keyVar = keyMatch.group(1)!;
      
      // Extract local path or use a fallback
      final pathMatch = RegExp(r'AWSFile\.fromPath\(([^)]+)\)').firstMatch(text);
      String localPath = '';
      if (pathMatch != null) {
        localPath = pathMatch.group(1)!;
      } else {
        // Fallbacks for specific files
        if (filePath.contains('property_management')) localPath = 'path';
        else if (filePath.contains('office_location')) localPath = 'file.path!';
        else if (filePath.contains('client_deals_view')) localPath = 'awsFile'; // wait, awsFile doesn't have path directly, but wait...
      }
      
      if (localPath.isEmpty) {
        // If we can't determine it, we just add a TODO or try generic
        return text;
      }
      
      if (localPath == 'awsFile') {
        // client_deals_view uses awsFile
        return '''$text
        try {
          final bytes = await File(result.files.single.path!).readAsBytes();
          SupabaseBackupService().backupFileInBackground($keyVar, bytes);
        } catch (_) {}''';
      }

      return '''$text
        try {
          final bytes = await File($localPath).readAsBytes();
          SupabaseBackupService().backupFileInBackground($keyVar, bytes);
        } catch (_) {}''';
    });

    file.writeAsStringSync(content);
    print('Patched: $filePath');
  }
}
