import 'dart:io';

void main() {
  final file = File('lib/screens/license_management_screen.dart');
  var content = file.readAsStringSync();
  
  // Fix imports
  if (!content.contains("import '../theme.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../theme.dart';");
  }

  // Fix ClientLicense to amplify_models.ClientLicenses
  content = content.replaceAll("void _showLicenseForm([ClientLicense? license])", "void _showLicenseForm([amplify_models.ClientLicenses? license])");
  
  // Fix the extra/missing braces at the end of the file.
  // Currently the file ends with:
  // 963:    },
  // 964:  );
  // 965:}
  // 966:
  // 967:
  // 968:}
  // 969:
  
  // This means there's an extra `}`!
  // Let's just remove the last `}`.
  final lines = content.split('\n');
  while (lines.isNotEmpty && lines.last.trim().isEmpty) {
    lines.removeLast();
  }
  if (lines.isNotEmpty && lines.last.trim() == '}') {
    lines.removeLast(); // Remove the extra }
  }
  
  file.writeAsStringSync(lines.join('\n') + '\n');
  print('Fixed license_management_screen.dart');
}
