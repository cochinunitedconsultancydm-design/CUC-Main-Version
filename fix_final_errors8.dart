import 'dart:io';

void main() {
  final log = File(r'C:\Users\Admin\.gemini\antigravity-ide\brain\808a46b1-9cc1-4933-a1a9-62bd8b5b0541\.system_generated\tasks\task-1820.log').readAsStringSync();
  final errorLines = log.split('\n').where((l) => l.contains('error - ')).toList();

  Map<String, List<int>> errorsByFile = {};
  for (var line in errorLines) {
    try {
      final match = RegExp(r'error - (.*?):(\d+):').firstMatch(line);
      if (match != null) {
        final filePath = match.group(1)!;
        final lineNum = int.parse(match.group(2)!);
        errorsByFile.putIfAbsent(filePath, () => []).add(lineNum);
      }
    } catch (e) {}
  }

  for (var entry in errorsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) continue;
    var lines = file.readAsLinesSync();
    
    // Sort descending to not mess up line numbers if we were inserting (we are just replacing)
    var linesToFix = entry.value.toSet().toList();
    for (var ln in linesToFix) {
      if (ln - 1 >= 0 && ln - 1 < lines.length) {
        var text = lines[ln - 1];
        
        // common fixes based on the error text:
        text = text.replaceAll(RegExp(r'TemporalDate\([^)]+\)'), "DateTime.now().toIso8601String()");
        text = text.replaceAll(".compareTo(b.expiryDate", "?.compareTo(b.expiryDate");
        
        if (text.contains('client_id:')) {
          text = text.replaceAll(RegExp(r'client_id:.*'), "client_id: license.clientId.toString(),");
        }
        if (text.contains('license_type_id:')) {
          text = text.replaceAll(RegExp(r'license_type_id:.*'), "license_type_id: license.licenseTypeId.toString(),");
        }
        if (text.contains('client_license_id:')) {
          text = text.replaceAll(RegExp(r'client_license_id:.*'), "client_license_id: licenseId.toString(),");
        }
        if (text.contains("b['amount']")) {
           text = text.replaceAll("b['amount']", "b['amount']?.toString() ?? ''");
        }
        if (text.contains("b['payment_date']")) {
           text = text.replaceAll("b['payment_date']", "b['payment_date']?.toString() ?? ''");
        }
        if (text.contains("l['expiry_date']")) {
           text = text.replaceAll("l['expiry_date']", "l['expiry_date']?.toString() ?? ''");
        }
        if (text.contains("l['service_date']")) {
           text = text.replaceAll("l['service_date']", "l['service_date']?.toString() ?? ''");
        }
        
        lines[ln - 1] = text;
      }
    }
    
    file.writeAsStringSync(lines.join('\n'));
    print('Fixed \${entry.key}');
  }
}
