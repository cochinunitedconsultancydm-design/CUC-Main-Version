import 'dart:io';

void replaceInFile(String path, Map<String, String> replacements) {
  final file = File(path);
  if (!file.existsSync()) return;
  var text = file.readAsStringSync();
  bool changed = false;
  
  replacements.forEach((key, value) {
    if (text.contains(key)) {
      text = text.replaceAll(key, value);
      changed = true;
    }
  });
  
  if (changed) {
    file.writeAsStringSync(text);
    print('Fixed \$path');
  }
}

void main() {
  replaceInFile('lib/screens/manager_dashboard_screen.dart', {
    "a['date'].compareTo(b['date'])": "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')",
    "a['time'].compareTo(b['time'])": "(a['time']?.toString() ?? '').compareTo(b['time']?.toString() ?? '')",
    "a['created_at'].compareTo(b['created_at'])": "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')",
    "checkInTime.hour": "DateTime.tryParse(checkInTime.toString())?.hour ?? 0",
    "DateTime.now().isAfter(lastLocTime)": "DateTime.now().isAfter(DateTime.tryParse(lastLocTime.toString()) ?? DateTime.now())",
    "final res = await _client": "final res = null; /* await _client */",
  });

  replaceInFile('lib/screens/task_management_screen.dart', {
    "a['created_at'].compareTo(b['created_at'])": "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')",
    "due_date: dueDate != null ? TemporalDate(dueDate) : null,": "due_date: dueDate?.toIso8601String(),",
    "due_date: dueDate,": "due_date: dueDate?.toIso8601String(),",
  });

  replaceInFile('lib/screens/travel_log_screen.dart', {
    "a['date'].compareTo(b['date'])": "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')",
  });

  replaceInFile('lib/screens/uploaded_files_screen.dart', {
    "a['created_at'].compareTo(b['created_at'])": "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')",
    "S3GetUrlPluginOptions()": "const aws_s3.GetUrlOptions()", // Amplify Storage V2 options
  });

  replaceInFile('lib/screens/license_management_screen.dart', {
    "a.expiry_date.compareTo(b.expiry_date)": "(a.expiry_date ?? '').compareTo(b.expiry_date ?? '')",
    "a.expiry_date?.compareTo(b.expiry_date)": "(a.expiry_date ?? '').compareTo(b.expiry_date ?? '')",
    "a['expiry_date'].compareTo(b['expiry_date'])": "(a['expiry_date']?.toString() ?? '').compareTo(b['expiry_date']?.toString() ?? '')",
    "?.compareTo(b.expiryDate)": "?.compareTo(b.expiryDate ?? '')",
    "status: 'Renewed', ,": "status: 'Renewed',",
    "client_id: int.tryParse(license.clientId.toString()) ?? 0,": "client_id: license.clientId.toString(),",
    "license_type_id: int.tryParse(license.licenseTypeId.toString()) ?? 0,": "license_type_id: license.licenseTypeId.toString(),",
    "client_license_id: int.tryParse(licenseId.toString()) ?? 0,": "client_license_id: licenseId.toString(),",
    "service_date: amplify_core.TemporalDate(DateTime.now()),": "service_date: DateTime.now().toIso8601String(),",
    "expiry_date: amplify_core.TemporalDate(nextExpiry),": "expiry_date: nextExpiry?.toIso8601String(),",
    "DateTime? _serviceDate = l['service_date'];": "String? _serviceDate = l['service_date']?.toString();",
    "DateTime? _expiryDate = l['expiry_date'];": "String? _expiryDate = l['expiry_date']?.toString();",
    "service_date: DateTime.now(),": "service_date: DateTime.now().toIso8601String(),",
    "expiry_date: nextExpiry,": "expiry_date: nextExpiry?.toIso8601String(),",
  });

  replaceInFile('lib/screens/license_dashboard_screen.dart', {
    "DateTime? _serviceDate = l['service_date'];": "String? _serviceDate = l['service_date']?.toString();",
    "DateTime? _expiryDate = l['expiry_date'];": "String? _expiryDate = l['expiry_date']?.toString();",
    "DateTime? paymentDate = b['payment_date'];": "String? paymentDate = b['payment_date']?.toString();",
    "b['amount']": "b['amount']?.toString() ?? ''",
  });

  replaceInFile('lib/screens/dsc_management_screen.dart', {
    "dsc_expiry_date: dscExpiryDate,": "dsc_expiry_date: dscExpiryDate?.toIso8601String(),",
    "class3_expiry_date: class3ExpiryDate,": "class3_expiry_date: class3ExpiryDate?.toIso8601String(),",
    "dsc_expiry_date: dscExpiryDate != null ? TemporalDate(dscExpiryDate) : null,": "dsc_expiry_date: dscExpiryDate?.toIso8601String(),",
    "class3_expiry_date: class3ExpiryDate != null ? TemporalDate(class3ExpiryDate) : null,": "class3_expiry_date: class3ExpiryDate?.toIso8601String(),",
  });

  replaceInFile('lib/screens/delivery_dashboard_screen.dart', {
    "DateTime.now().split": "DateTime.now().toIso8601String().split",
  });

  replaceInFile('lib/screens/client_files_dialog.dart', {
    "AWSFile.fromPath(file.path)": "AWSFile.fromPath(pickedFile.path!)",
    "uploadFile(file, filePath)": "uploadFile(pickedFile, filePath)",
  });

  replaceInFile('lib/screens/chat_screen.dart', {
    "StreamSubscription<dynamic>?": "StreamSubscription<GraphQLResponse<String>>?",
    ".listen(onData: (data)": ".listen((data)",
  });

  replaceInFile('lib/screens/billing_screen.dart', {
    "import 'package:flutter/material.dart';": "import 'package:flutter/material.dart';\nimport 'dart:convert';",
  });

  replaceInFile('lib/screens/staff_location_screen.dart', {
    "String loc = data['location'];": "String loc = data['location']?.toString() ?? '';",
    "String loc = log['location'];": "String loc = log['location']?.toString() ?? '';",
  });
}
