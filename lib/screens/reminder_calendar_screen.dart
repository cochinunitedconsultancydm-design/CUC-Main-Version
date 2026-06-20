import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../widgets/add_reminder_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CalendarEvent {
  final DateTime date;
  final String title;
  final String type; // 'Task', 'License', 'DSC'
  final String? subtitle;
  final String? status;
  final String eventId;

  CalendarEvent({
    required this.date,
    required this.title,
    required this.type,
    this.subtitle,
    this.status,
    String? eventId,
  }) : eventId = eventId ?? 'EVENT-${DateTime.now().millisecondsSinceEpoch}';
}

class ReminderCalendarScreen extends StatefulWidget {
  const ReminderCalendarScreen({super.key});

  @override
  State<ReminderCalendarScreen> createState() => _ReminderCalendarScreenState();
}

class _ReminderCalendarScreenState extends State<ReminderCalendarScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDay;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<CalendarEvent> _allEvents = [];
  List<Map<String, dynamic>> _allUsers = [];
  int? _currentUserId;
  bool _isLoading = true;

  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _initData();
  }

  Future<void> _initData() async {
    try {
      final userId = await AuthService().getUserId();
      if (userId != null) {
        _currentUserId = userId;
      }
      
      final res = await _client.from('users').select('id, name').order('name', ascending: true);
      _allUsers = List<Map<String, dynamic>>.from(res);
      
      await _loadEvents();
    } catch (e) {
      debugPrint('Error initing calendar data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final List<CalendarEvent> events = [];

      // 1. Fetch Tasks (Treating them as Reminders)
      final tasksRes = await _client
          .from('tasks')
          .select('id, title, description, due_date, status, assigned_to_user:users!tasks_assigned_to_fkey(name)')
          .neq('status', 'Completed');
      
      for (var t in tasksRes) {
        if (t['due_date'] != null) {
          try {
            final date = DateTime.parse(t['due_date'].toString()).toLocal();
            final assignedTo = t['assigned_to_user']?['name'] ?? 'Unassigned';
            events.add(CalendarEvent(
              date: date,
              title: t['title'] ?? 'Task Reminder',
              type: 'Task',
              subtitle: 'Assigned to: $assignedTo\n${t['description'] ?? ""}'.trim(),
              status: t['status'],
              eventId: 'TASK-${t['id']}',
            ));
          } catch (_) {}
        }
      }

      // 2. Fetch Licenses Expiry
      final licenseRes = await _client
          .from('client_licenses')
          .select('id, expiry_date, manual_client_name, clients(name), license_types(name)')
          .eq('status', 'Active');
      
      for (var l in licenseRes) {
        if (l['expiry_date'] != null) {
          try {
            final date = DateTime.parse(l['expiry_date'].toString()).toLocal();
            String clientName = l['manual_client_name'] ?? 'Unknown Client';
            if (l['clients'] != null) {
              final c = l['clients'];
              clientName = (c is List && c.isNotEmpty) ? c[0]['name'] : (c is Map ? c['name'] : clientName);
            }

            String licenseType = 'License';
            if (l['license_types'] != null) {
              final lt = l['license_types'];
              licenseType = (lt is List && lt.isNotEmpty) ? lt[0]['name'] : (lt is Map ? lt['name'] : licenseType);
            }

            events.add(CalendarEvent(
              date: date,
              title: '$clientName - License Expiry',
              type: 'License',
              subtitle: 'Type: $licenseType',
              eventId: 'LIC-${l['id']}',
            ));
          } catch (_) {}
        }
      }

      // 3. Fetch DSC Expiry
      final dscRes = await _client
          .from('dsc_records')
          .select('id, client_name, dsc_expiry_date');
      
      for (var d in dscRes) {
        if (d['dsc_expiry_date'] != null) {
          try {
            final date = DateTime.parse(d['dsc_expiry_date'].toString()).toLocal();
            events.add(CalendarEvent(
              date: date,
              title: '${d['client_name']} - DSC Expiry',
              type: 'DSC',
              eventId: 'DSC-${d['id']}',
            ));
          } catch (_) {}
        }
      }

      events.sort((a, b) => a.date.compareTo(b.date));

      if (mounted) {
        setState(() {
          _allEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading calendar events: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddEventDialog() {
    if (_currentUserId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) => AddReminderDialog(
        currentUserId: _currentUserId!,
        allUsers: _allUsers,
        onSaved: () {
          _loadEvents();
        },
      ),
    );
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  int _getFirstWeekdayOffset(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    return firstDay.weekday % 7;
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'Task': return AppTheme.primaryColor;
      case 'License': return Colors.purple;
      case 'DSC': return Colors.teal;
      default: return Colors.blueGrey;
    }
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  List<CalendarEvent> _getFilteredEvents() {
    return _allEvents.where((e) {
      final matchesCategory = _selectedCategory == 'All' || e.type == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.subtitle != null && e.subtitle!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    final daysCount = _getDaysInMonth(_selectedMonth);
    final offset = _getFirstWeekdayOffset(_selectedMonth);
    final totalGridItems = daysCount + offset;

    final filteredEvents = _getFilteredEvents();

    final eventsForSelectedDay = filteredEvents.where((e) {
      return e.date.year == _selectedDay.year &&
          e.date.month == _selectedDay.month &&
          e.date.day == _selectedDay.day;
    }).toList();

    final List<String> weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    Widget categoryFilterRow = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['All', 'Task', 'License', 'DSC'].map((cat) {
        final isSelected = _selectedCategory == cat;
        Color chipColor;
        if (cat == 'Task') chipColor = AppTheme.primaryColor;
        else if (cat == 'License') chipColor = Colors.purple;
        else if (cat == 'DSC') chipColor = Colors.teal;
        else chipColor = Colors.blueGrey;

        return ChoiceChip(
          label: Text(
            cat == 'All' ? 'ALL' : (cat == 'Task' ? 'TASKS/REMINDERS' : '$cat EXPIRIES'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedCategory = cat);
          },
          selectedColor: chipColor,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide.none,
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );

    Widget calendarGrid = LayoutBuilder(
      builder: (context, constraints) {
        final double gridMaxHeight = constraints.maxHeight;
        final double gridMaxWidth = constraints.maxWidth;

        final rowsCount = (totalGridItems / 7).ceil();
        final cellWidth = (gridMaxWidth - 48) / 7;
        
        // Handle constrained height vs unbounded
        final double cellHeight = isDesktop ? ((gridMaxHeight - 80) / rowsCount).clamp(60.0, 150.0) : 80.0;
        
        double dynamicAspectRatio = cellWidth / cellHeight;
        if (dynamicAspectRatio < 0.6) dynamicAspectRatio = 0.6;
        if (dynamicAspectRatio > 2.0) dynamicAspectRatio = 2.0;

        Widget buildGridCell(int index) {
          if (index < offset) return const SizedBox.shrink();

          final dayNum = index - offset + 1;
          final currentDay = DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
          final isSelected = currentDay.year == _selectedDay.year && currentDay.month == _selectedDay.month && currentDay.day == _selectedDay.day;
          
          final now = DateTime.now();
          final isToday = currentDay.year == now.year && currentDay.month == now.month && currentDay.day == now.day;

          final dayEvents = filteredEvents.where((e) {
            return e.date.year == currentDay.year && e.date.month == currentDay.month && e.date.day == currentDay.day;
          }).toList();

          final taskCount = dayEvents.where((e) => e.type == 'Task').length;
          final expCount = dayEvents.where((e) => e.type == 'License' || e.type == 'DSC').length;

          Color borderColor = Colors.grey.shade200;
          if (isSelected) borderColor = AppTheme.primaryColor;
          else if (isToday) borderColor = AppTheme.primaryColor.withOpacity(0.4);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = currentDay),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : const Color(0xFFF1F5F9), width: isSelected ? 2 : 1),
                boxShadow: isSelected 
                  ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)] 
                  : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : (isToday ? AppTheme.primaryColor.withOpacity(0.15) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isToday ? AppTheme.primaryColor : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  if (dayEvents.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      left: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (taskCount > 0)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('$taskCount Task', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryColor), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          if (expCount > 0)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Text('$expCount Exp', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red.shade700), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        final gridWidget = GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: dynamicAspectRatio,
          ),
          itemCount: totalGridItems,
          itemBuilder: (context, index) => buildGridCell(index).animate().fadeIn(duration: 300.ms, delay: (index * 10).ms).scale(begin: const Offset(0.95, 0.95)),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: _prevMonth),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: _nextMonth),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: weekdays.map((day) {
                return Center(
                  child: Text(day, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            isDesktop ? Expanded(child: gridWidget) : gridWidget,
          ],
        );
      },
    );

    Widget searchField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: _searchQuery),
        style: const TextStyle(fontSize: 14),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
          hintText: 'Search reminders...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );

    Widget mainContent = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Calendar
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: calendarGrid,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
              ),
              const SizedBox(width: 24),
              // Right: Selected Day Events
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: searchField),
                      ],
                    ),
                    const SizedBox(height: 16),
                    categoryFilterRow,
                    const SizedBox(height: 24),
                    Expanded(child: _buildEventsList(eventsForSelectedDay)),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05),
              ),
            ],
          )
        : Column(
            children: [
              searchField,
              const SizedBox(height: 16),
              categoryFilterRow,
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: calendarGrid,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildEventsList(eventsForSelectedDay)),
            ],
          );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
        : Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reminder Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    if (isDesktop)
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _openAddEventDialog,
                          icon: const Icon(Icons.add_task),
                          label: const Text('Add Reminder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(child: mainContent),
              ],
            ),
          ),
    );
  }

  Widget _buildEventsList(List<CalendarEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No Reminders on ${DateFormat('MMM dd').format(_selectedDay)}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Add Reminder" to create one.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders for ${DateFormat('EEEE, MMM dd').format(_selectedDay)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final event = events[index];
              final color = _getEventColor(event.type);
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border(left: BorderSide(color: color, width: 6)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                      event.type == 'Task' ? Icons.assignment : (event.type == 'License' ? Icons.verified_user : Icons.vpn_key),
                      color: color,
                    ),
                  ),
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      if (event.subtitle != null) Text(event.subtitle!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(DateFormat('hh:mm a').format(event.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          if (event.status != null) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.status!,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                              ),
                            ),
                          ],
                        ],
                      ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}
