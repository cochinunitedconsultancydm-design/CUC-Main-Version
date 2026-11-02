import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiscalYearService {
  static const String period2025_2026 = '2025-2026';
  static const String period2026_2027 = '2026-2027';
  static const String periodAll = 'All';

  // November 1, 2026 cutoff date
  static final DateTime nov1Cutoff = DateTime(2026, 11, 1);

  static const String _prefKey = 'active_fiscal_year_period';

  static final ValueNotifier<String> currentPeriod = ValueNotifier<String>(period2026_2027);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == period2025_2026) {
        currentPeriod.value = period2025_2026;
      } else {
        currentPeriod.value = period2026_2027;
      }
    } catch (_) {
      currentPeriod.value = period2026_2027;
    }
  }

  static Future<void> setPeriod(String period) async {
    currentPeriod.value = period;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, period);
    } catch (_) {}
  }

  static bool isOldFile(DateTime? dt) {
    if (dt == null) return true;
    return dt.isBefore(nov1Cutoff);
  }

  static bool isCurrentPeriod(DateTime? dt) {
    if (dt == null) return false;
    return !dt.isBefore(nov1Cutoff);
  }

  static bool matchesCurrentPeriod(DateTime? dt) {
    if (currentPeriod.value == period2025_2026) {
      return isOldFile(dt);
    }
    // 2026-2027 (Fresh Clean): STRICTLY require record date to be on or after nov1Cutoff
    return isCurrentPeriod(dt);
  }

  /// Returns a valid creation date for new or imported records.
  /// If in 2026-2027 period, ensures date is on or after nov1Cutoff.
  static DateTime getEffectiveCreationDate() {
    if (currentPeriod.value == period2026_2027) {
      if (DateTime.now().isBefore(nov1Cutoff)) {
        return DateTime(2026, 11, 1, 0, 0, 1);
      }
    }
    return DateTime.now();
  }

  static String get displayLabel {
    if (currentPeriod.value == period2025_2026) {
      return '2025-2026 (Old Files)';
    } else if (currentPeriod.value == period2026_2027) {
      return '2026-2027 (Fresh Clean)';
    }
    return 'All Records';
  }

  /// Shows the selection dialog for choosing between 2025-2026 and 2026-2027
  static Future<String?> showSelectionDialog(BuildContext context, {bool isLoginPrompt = false}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: !isLoginPrompt,
      builder: (ctx) => FiscalYearSelectionDialog(isLoginPrompt: isLoginPrompt),
    );
  }
}

class FiscalYearSelectionDialog extends StatefulWidget {
  final bool isLoginPrompt;
  const FiscalYearSelectionDialog({super.key, this.isLoginPrompt = false});

  @override
  State<FiscalYearSelectionDialog> createState() => _FiscalYearSelectionDialogState();
}

class _FiscalYearSelectionDialogState extends State<FiscalYearSelectionDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = FiscalYearService.currentPeriod.value;
  }

  void _choose(String period) async {
    setState(() => _selected = period);
    await FiscalYearService.setPeriod(period);
    if (mounted) {
      Navigator.of(context).pop(period);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.25),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A028).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC5A028).withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFD4AF37), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELECT FINANCIAL YEAR',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isLoginPrompt
                              ? 'Choose which workspace to open for this session'
                              : 'Switch active workspace period',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isLoginPrompt)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),

            // Content Body: Two Options
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  // Option 1: 2025-2026 (Old Files)
                  _buildOptionCard(
                    id: FiscalYearService.period2025_2026,
                    title: '2025 - 2026',
                    badgeText: 'OLD FILES & ARCHIVE',
                    description: 'Access previous cases, client records, and historical work files (Till Nov 1, 2026)',
                    icon: Icons.history_rounded,
                    accentColor: const Color(0xFFB45309),
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeBorder: const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 18),

                  // Option 2: 2026-2027 (Fresh Clean)
                  _buildOptionCard(
                    id: FiscalYearService.period2026_2027,
                    title: '2026 - 2027',
                    badgeText: 'FRESH CLEAN WORKSPACE',
                    description: 'Start fresh with a clean slate from Nov 1, 2026 onward for new works and clients',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: const Color(0xFF047857),
                    badgeBg: const Color(0xFFD1FAE5),
                    badgeBorder: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String id,
    required String title,
    required String badgeText,
    required String description,
    required IconData icon,
    required Color accentColor,
    required Color badgeBg,
    required Color badgeBorder,
  }) {
    final isSelected = _selected == id;

    return InkWell(
      onTap: () => _choose(id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFC5A028) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC5A028).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeBorder.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeBorder, width: 0.8),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFC5A028) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFC5A028) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact, interactive pill button placed near Check In to show and toggle active period
class FiscalYearHeaderPill extends StatelessWidget {
  final VoidCallback? onSwitched;
  const FiscalYearHeaderPill({super.key, this.onSwitched});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: FiscalYearService.currentPeriod,
      builder: (context, period, _) {
        final isOld = period == FiscalYearService.period2025_2026;
        final bg = isOld ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5);
        final border = isOld ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
        final textCol = isOld ? const Color(0xFFB45309) : const Color(0xFF047857);
        final icon = isOld ? Icons.history_rounded : Icons.auto_awesome_rounded;
        final label = isOld ? '2025-2026' : '2026-2027';
        final sublabel = isOld ? 'Old Files' : 'Fresh';

        return Tooltip(
          message: isOld
              ? 'Active: 2025-2026 (Old Files). Click to switch to 2026-2027 (Fresh).'
              : 'Active: 2026-2027 (Fresh Clean). Click to switch to 2025-2026 (Old Files).',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final targetPeriod = isOld
                    ? FiscalYearService.period2026_2027
                    : FiscalYearService.period2025_2026;
                await FiscalYearService.setPeriod(targetPeriod);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            isOld ? Icons.auto_awesome_rounded : Icons.history_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOld
                                ? 'Switched to 2026–2027 (Fresh Clean Workspace)'
                                : 'Switched to 2025–2026 (Old Files)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: isOld ? const Color(0xFF047857) : const Color(0xFFB45309),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                onSwitched?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: border.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: textCol),
                    const SizedBox(width: 6),
                    Text(
                      '$label ($sublabel)',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textCol,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.swap_horiz_rounded, size: 13, color: textCol.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

