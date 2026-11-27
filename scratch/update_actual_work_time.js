const fs = require('fs');

const attPath = 'lib/screens/attendance_screen.dart';
let content = fs.readFileSync(attPath, 'utf8');

// 1. Update registerActivityLog
const oldReg = `    // Map of latest activity log per staffKey per day (for MNC Last-Activity Resolution)
    final Map<String, Map<int, DateTime>> latestLogByStaffAndDay = {};
    void registerActivityLog(dynamic uid, dynamic uname, dynamic rawTs) {
      final staffKey = resolveStaff(uid, uname);
      if (staffKey == null) return;
      final ts = _parseIST(rawTs);
      if (ts == null) return;
      if (ts.year == _selectedMonth.year && ts.month == _selectedMonth.month) {
        final day = ts.day;
        final existing = latestLogByStaffAndDay.putIfAbsent(staffKey, () => {})[day];
        if (existing == null || ts.isAfter(existing)) {
          latestLogByStaffAndDay[staffKey]![day] = ts;
        }
      }
    }

    for (var l in ampLogs) {
      registerActivityLog(l.user_id, l.target_id, l.created_at ?? l.createdAt?.format());
    }
    for (var l in sbLogs) {
      registerActivityLog(l['user_id'], l['user_name'] ?? l['username'], l['created_at']);
    }`;

const newReg = `    // Map of latest activity log per staffKey per day (for MNC Last-Activity Resolution)
    final Map<String, Map<int, DateTime>> latestLogByStaffAndDay = {};
    void registerActivityLog(dynamic uid, dynamic uname, dynamic rawTs, [dynamic details]) {
      String? staffKey = resolveStaff(uid, uname);
      if (staffKey == null && details != null) {
        final match = RegExp(r'\\[User:\\s*([^\\]]+)\\]', caseSensitive: false).firstMatch(details.toString());
        if (match != null && match.group(1) != null) {
          staffKey = resolveStaff(null, match.group(1)!.trim());
        }
      }
      if (staffKey == null) return;
      final ts = _parseIST(rawTs);
      if (ts == null) return;
      if (ts.year == _selectedMonth.year && ts.month == _selectedMonth.month) {
        final day = ts.day;
        final existing = latestLogByStaffAndDay.putIfAbsent(staffKey, () => {})[day];
        if (existing == null || ts.isAfter(existing)) {
          latestLogByStaffAndDay[staffKey]![day] = ts;
        }
      }
    }

    for (var l in ampLogs) {
      registerActivityLog(l.user_id, l.target_id, l.created_at ?? l.createdAt?.format(), l.details);
    }
    for (var l in sbLogs) {
      registerActivityLog(l['user_id'], l['user_name'] ?? l['username'] ?? l['target_id'], l['created_at'], l['details']);
    }`;

// 2. Update checkout time logic (removing 6 PM / 5:30 PM default)
const oldCheckout = `            } else if (dayDate.isBefore(todayStart)) {
              // Priority 3: Past Work Day (Standard Shift Auto-Reconciliation)
              record.isAutoReconciled = true;
              if (inTime.hour < 12) {
                // Morning check-in -> Standard 05:30 PM (standard 8-hour workday)
                record.checkOutTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 17, 30);
                record.checkoutReason = 'Standard Shift Policy (Auto-Completed at 5:30 PM)';
              } else if (inTime.hour < 16) {
                // Afternoon check-in -> Standard 06:00 PM shift end
                record.checkOutTime = DateTime(dayDate.year, dayDate.month, dayDate.day, 18, 0);
                record.checkoutReason = 'Afternoon Shift Policy (Auto-Completed at 6:00 PM)';
              } else {
                // Late check-in (> 4:00 PM) -> 2h 30m shift
                record.checkOutTime = inTime.add(const Duration(hours: 2, minutes: 30));
                record.checkoutReason = 'Evening Session (Auto-Completed)';
              }

              record.events.add(AttendanceEvent(
                title: 'Auto-Reconciled Shift Conclusion',
                time: record.checkOutTime!,
                type: 'OUT',
                source: 'Enterprise Shift Policy',
                status: 'Auto-Completed',
              ));
            }`;

const newCheckout = `            } else if (dayDate.isBefore(todayStart)) {
              // Priority 3: Past Work Day (Mark time till they actually worked, never a default 6 PM)
              record.isAutoReconciled = true;
              DateTime actualOutTime = inTime;

              // Check if latest activity log on that day has a time after check-in
              final lastAct = latestLogByStaffAndDay[staffKey]?[record.day];
              if (lastAct != null && lastAct.isAfter(actualOutTime) && lastAct.day == inTime.day) {
                actualOutTime = lastAct;
              }

              // Check if any registered session or log event has a later time
              for (var ev in record.events) {
                if (ev.time.isAfter(actualOutTime) && ev.time.day == inTime.day) {
                  actualOutTime = ev.time;
                }
              }

              if (actualOutTime.isAfter(inTime)) {
                record.checkOutTime = actualOutTime;
                record.checkoutReason = 'Last Recorded System Activity';
              } else {
                // If only check-in occurred with no further activity, mark session completion
                record.checkOutTime = inTime.add(const Duration(minutes: 45));
                record.checkoutReason = 'Session Completed';
              }

              record.events.add(AttendanceEvent(
                title: 'Work Concluded',
                time: record.checkOutTime!,
                type: 'OUT',
                source: 'Actual Work Activity',
              ));
            }`;

function tryReplace(src, target, repl) {
  if (src.includes(target)) return src.replace(target, repl);
  const targetCRLF = target.replace(/\n/g, '\r\n');
  const replCRLF = repl.replace(/\n/g, '\r\n');
  if (src.includes(targetCRLF)) return src.replace(targetCRLF, replCRLF);
  return null;
}

let updated1 = tryReplace(content, oldReg, newReg);
if (!updated1) {
  console.error('Failed to replace oldReg');
  process.exit(1);
}

let updated2 = tryReplace(updated1, oldCheckout, newCheckout);
if (!updated2) {
  console.error('Failed to replace oldCheckout');
  process.exit(1);
}

fs.writeFileSync(attPath, updated2, 'utf8');
console.log('Successfully updated attendance_screen.dart to remove default 6 PM and mark actual work time!');
