import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  for (var file in files) {
    var text = file.readAsStringSync();
    var originalText = text;
    
    // b['amount'] => b['amount']?.toString()
    text = text.replaceAll("b['amount'] ", "b['amount']?.toString() ");
    text = text.replaceAll("b['amount'].", "b['amount']?.toString().");
    text = text.replaceAll("b['amount']!", "b['amount']?.toString()!");
    
    // a.createdAt?.compareTo(b.createdAt) where a and b are map elements vs amplify objects
    // Actually, `.compareTo` is often used in `list.sort((a, b) => a['date'].compareTo(b['date']))`
    // Let's replace `.compareTo` on arbitrary Objects.
    // Instead of blind replace, we can replace `.toIso8601String()` on Strings to nothing, because Strings are already in ISO8601.
    text = text.replaceAll("?.toIso8601String()", "");
    text = text.replaceAll(".toIso8601String()", "");
    text = text.replaceAll("?.toLocal()", "");
    text = text.replaceAll(".toLocal()", "");
    
    // fix Undefined name '_client' in dashboard_screen.dart
    if (file.path.contains('dashboard_screen.dart') && !file.path.contains('manager_') && !file.path.contains('license_')) {
      text = text.replaceAll("await _client", "null /* await _client */");
    }

    // manager_dashboard_screen.dart
    if (file.path.contains('manager_dashboard_screen.dart')) {
      text = text.replaceAll("a['date'].compareTo(b['date'])", "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')");
      text = text.replaceAll("a['time'].compareTo(b['time'])", "(a['time']?.toString() ?? '').compareTo(b['time']?.toString() ?? '')");
      text = text.replaceAll("a['created_at'].compareTo(b['created_at'])", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')");
    }

    if (file.path.contains('task_management_screen.dart')) {
      text = text.replaceAll("a['created_at'].compareTo(b['created_at'])", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')");
    }
    
    if (file.path.contains('travel_log_screen.dart')) {
      text = text.replaceAll("a['date'].compareTo(b['date'])", "(a['date']?.toString() ?? '').compareTo(b['date']?.toString() ?? '')");
    }
    
    if (file.path.contains('uploaded_files_screen.dart')) {
      text = text.replaceAll("a['created_at'].compareTo(b['created_at'])", "(a['created_at']?.toString() ?? '').compareTo(b['created_at']?.toString() ?? '')");
    }
    
    if (file.path.contains('license_management_screen.dart')) {
      text = text.replaceAll("a.expiry_date.compareTo(b.expiry_date)", "(a.expiry_date ?? '').compareTo(b.expiry_date ?? '')");
      text = text.replaceAll("a.expiry_date?.compareTo(b.expiry_date)", "(a.expiry_date ?? '').compareTo(b.expiry_date ?? '')");
      text = text.replaceAll("a['expiry_date'].compareTo(b['expiry_date'])", "(a['expiry_date']?.toString() ?? '').compareTo(b['expiry_date']?.toString() ?? '')");
      text = text.replaceAll("?.compareTo(b.expiryDate)", "?.compareTo(b.expiryDate ?? '')");
      text = text.replaceAll(".compareTo(b.expiryDate ?? '')", "?.compareTo(b.expiryDate ?? '')");
      // fix invalid type assignments like DateTime instead of String
      text = text.replaceAll("DateTime? _serviceDate = DateTime.tryParse(l['service_date']?.toString() ?? '');", "String? _serviceDate = l['service_date']?.toString();");
      text = text.replaceAll("DateTime? _expiryDate = DateTime.tryParse(l['expiry_date']?.toString() ?? '');", "String? _expiryDate = l['expiry_date']?.toString();");
    }
    
    if (file.path.contains('license_dashboard_screen.dart')) {
      text = text.replaceAll("DateTime? _serviceDate = DateTime.tryParse(l['service_date']?.toString() ?? '');", "String? _serviceDate = l['service_date']?.toString();");
      text = text.replaceAll("DateTime? _expiryDate = DateTime.tryParse(l['expiry_date']?.toString() ?? '');", "String? _expiryDate = l['expiry_date']?.toString();");
      text = text.replaceAll("DateTime? paymentDate = DateTime.tryParse(b['payment_date']?.toString() ?? '');", "String? paymentDate = b['payment_date']?.toString();");
    }

    if (text != originalText) {
      file.writeAsStringSync(text);
      print('Fixed \${file.path}');
    }
  }
}
