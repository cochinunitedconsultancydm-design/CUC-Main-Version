import 'package:flutter/material.dart';
import '../theme.dart';

class FormatsScreen extends StatelessWidget {
  const FormatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.format_list_bulleted_rounded, size: 80, color: AppTheme.primaryColor),
          SizedBox(height: 24),
          Text(
            'Formats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Formats and templates will appear here.',
            style: TextStyle(color: AppTheme.mutedTextColor),
          ),
        ],
      ),
    );
  }
}
