import re
import os

def fix_file(filepath, replacements):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        for old, new in replacements:
            content = re.sub(old, new, content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")

# chat_screen
fix_file('lib/screens/chat_screen.dart', [
    (r'StreamSubscription<dynamic>\?', r'StreamSubscription<GraphQLResponse<String>>?'),
    (r'\.listen\([^,]+,\s*onData:\s*\(data\)', r'.listen((data)')
])

# billing_screen
fix_file('lib/screens/billing_screen.dart', [
    (r"import 'package:flutter/material\.dart';", "import 'package:flutter/material.dart';\nimport 'dart:convert';")
])

# client_files_dialog
fix_file('lib/screens/client_files_dialog.dart', [
    (r"AWSFile\.fromPath\(file\.path\)", "AWSFile.fromPath(pickedFile.path!)"),
    (r"uploadFile\(file,", "uploadFile(pickedFile,")
])

# delivery_dashboard_screen
fix_file('lib/screens/delivery_dashboard_screen.dart', [
    (r"DateTime\.now\(\)\.split", "DateTime.now().toIso8601String().split")
])

# dsc_management_screen
fix_file('lib/screens/dsc_management_screen.dart', [
    (r"dsc_expiry_date:\s*dscExpiryDate,", "dsc_expiry_date: dscExpiryDate?.toIso8601String(),"),
    (r"class3_expiry_date:\s*class3ExpiryDate,", "class3_expiry_date: class3ExpiryDate?.toIso8601String(),"),
    (r"dsc_expiry_date:\s*dscExpiryDate\s*\?\s*TemporalDate\(dscExpiryDate\)\s*:\s*null,", "dsc_expiry_date: dscExpiryDate?.toIso8601String(),"),
    (r"class3_expiry_date:\s*class3ExpiryDate\s*\?\s*TemporalDate\(class3ExpiryDate\)\s*:\s*null,", "class3_expiry_date: class3ExpiryDate?.toIso8601String(),"),
])

# task_management_screen
fix_file('lib/screens/task_management_screen.dart', [
    (r"due_date:\s*dueDate\s*\?\s*TemporalDate\(dueDate\)\s*:\s*null,", "due_date: dueDate?.toIso8601String(),"),
    (r"due_date:\s*dueDate,", "due_date: dueDate?.toIso8601String(),"),
    (r"a\['created_at'\].compareTo\(b\['created_at'\]\)", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')")
])

# staff_location_screen
fix_file('lib/screens/staff_location_screen.dart', [
    (r"String\s+loc\s*=\s*data\['location'\];", "String loc = data['location']?.toString() ?? '';"),
    (r"String\s+loc\s*=\s*log\['location'\];", "String loc = log['location']?.toString() ?? '';")
])

# manager_dashboard_screen
fix_file('lib/screens/manager_dashboard_screen.dart', [
    (r"\.hour", "?.hour"), # just to make it safe if it's string, wait string has no hour
    (r"checkInTime\.hour", "DateTime.tryParse(checkInTime.toString())?.hour"),
    (r"DateTime\.now\(\)\.isAfter\(lastLocTime", "DateTime.now().isAfter(DateTime.tryParse(lastLocTime.toString()) ?? DateTime.now()"),
    (r"a\['created_at'\].compareTo\(b\['created_at'\]\)", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')"),
    (r"a\['time'\].compareTo\(b\['time'\]\)", "(a['time']?.toString() ?? '').compareTo(b['time']?.toString() ?? '')"),
    (r"a\['date'\].compareTo\(b\['date'\]\)", "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')")
])

# license_management_screen
fix_file('lib/screens/license_management_screen.dart', [
    (r"status:\s*'Renewed',\s*,", "status: 'Renewed',"),
    (r"a\['expiry_date'\].compareTo\(b\['expiry_date'\]\)", "(a['expiry_date']?.toString() ?? '').compareTo(b['expiry_date']?.toString() ?? '')"),
    (r"a\.expiry_date\.compareTo\(b\.expiry_date\)", "(a.expiry_date ?? '').compareTo(b.expiry_date ?? '')"),
    (r"client_id:\s*int\.tryParse\(license\.clientId\.toString\(\)\)\s*\?\?\s*0,", "client_id: license.clientId.toString(),"),
    (r"license_type_id:\s*int\.tryParse\(license\.licenseTypeId\.toString\(\)\)\s*\?\?\s*0,", "license_type_id: license.licenseTypeId.toString(),"),
    (r"service_date:\s*amplify_core\.TemporalDate\(DateTime\.now\(\)\),", "service_date: DateTime.now().toIso8601String(),"),
    (r"expiry_date:\s*amplify_core\.TemporalDate\(nextExpiry\),", "expiry_date: nextExpiry?.toIso8601String(),"),
    (r"DateTime\?\s*_serviceDate\s*=\s*l\['service_date'\];", "String? _serviceDate = l['service_date']?.toString();"),
    (r"DateTime\?\s*_expiryDate\s*=\s*l\['expiry_date'\];", "String? _expiryDate = l['expiry_date']?.toString();"),
    (r"client_license_id:\s*int\.tryParse\(licenseId\.toString\(\)\)\s*\?\?\s*0,", "client_license_id: licenseId.toString(),"),
    (r"service_date:\s*DateTime\.now\(\),", "service_date: DateTime.now().toIso8601String(),"),
    (r"expiry_date:\s*nextExpiry,", "expiry_date: nextExpiry?.toIso8601String(),"),
    (r"DateTime\s+date\s*=\s*DateTime\.now\(\);", "DateTime date = DateTime.now();"),
    (r"serviceDate\s*\?\s*TemporalDate\(serviceDate\)\s*:\s*null", "serviceDate?.toIso8601String()"),
    (r"expiryDate\s*\?\s*TemporalDate\(expiryDate\)\s*:\s*null", "expiryDate?.toIso8601String()")
])

# license_dashboard_screen
fix_file('lib/screens/license_dashboard_screen.dart', [
    (r"DateTime\?\s*_serviceDate\s*=\s*l\['service_date'\];", "String? _serviceDate = l['service_date']?.toString();"),
    (r"DateTime\?\s*_expiryDate\s*=\s*l\['expiry_date'\];", "String? _expiryDate = l['expiry_date']?.toString();"),
    (r"DateTime\?\s*paymentDate\s*=\s*b\['payment_date'\];", "String? paymentDate = b['payment_date']?.toString();")
])

# travel_log_screen
fix_file('lib/screens/travel_log_screen.dart', [
    (r"a\['date'\].compareTo\(b\['date'\]\)", "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')")
])

# uploaded_files_screen
fix_file('lib/screens/uploaded_files_screen.dart', [
    (r"a\['created_at'\].compareTo\(b\['created_at'\]\)", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')")
])

# To fix ALL map `.compareTo` easily
import glob

def fix_all_maps():
    files = glob.glob('lib/screens/**/*.dart', recursive=True)
    for filepath in files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # general regex to fix a['field'].compareTo(b['field'])
        content = re.sub(r"([a-zA-Z_0-9]+)\['([^']+)'\]\.compareTo\(([a-zA-Z_0-9]+)\['([^']+)'\]\)", r"(\1['\2']?.toString() ?? '').compareTo(\3['\4']?.toString() ?? '')", content)
        
        # fix b['amount'] => b['amount']?.toString()
        # fix b['payment_date'] => b['payment_date']?.toString()
        # fix l['expiry_date'] => l['expiry_date']?.toString()
        # fix l['service_date'] => l['service_date']?.toString()
        
        # general type error where we assign Object to String
        content = re.sub(r"(String\s+[a-zA-Z0-9_]+\s*=\s*[a-zA-Z0-9_]+)\['([^']+)'\];", r"\1['\2']?.toString() ?? '';", content)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

fix_all_maps()
print("Done fixing with python script.")
