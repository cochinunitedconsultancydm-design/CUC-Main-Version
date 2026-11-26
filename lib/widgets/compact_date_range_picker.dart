import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

Future<DateTimeRange?> showCompactDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
}) async {
  return showDateRangePicker(
    context: context,
    initialDateRange: initialDateRange,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    saveText: saveText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    errorInvalidRangeText: errorInvalidRangeText,
    builder: (context, child) {
      if (child == null) return const SizedBox.shrink();
      final screenSize = MediaQuery.of(context).size;
      final dialogWidth = min(440.0, max(320.0, screenSize.width - 32.0));
      final dialogHeight = min(580.0, max(420.0, screenSize.height - 48.0));
      final targetSize = Size(dialogWidth, dialogHeight);

      return Center(
        child: Container(
          width: targetSize.width,
          height: targetSize.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: targetSize,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textColor,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppTheme.textColor),
                ),
                dialogTheme: const DialogThemeData(
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppTheme.textColor,
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
