import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';

class MetricDetailsScreen extends StatefulWidget {
  final String title;
  final List<amplify_models.ActivityLogs> logs;
  final Map<String, int> usernameToIdMap;
  final List<Map<String, dynamic>> staffList;

  const MetricDetailsScreen({
    super.key,
    required this.title,
    required this.logs,
    required this.usernameToIdMap,
    required this.staffList,
  });

  @override
  State<MetricDetailsScreen> createState() => _MetricDetailsScreenState();
}

class _MetricDetailsScreenState extends State<MetricDetailsScreen> {
  String _searchQuery = '';
  late List<amplify_models.ActivityLogs> _filteredLogs;

  @override
  void initState() {
    super.initState();
    _filteredLogs = widget.logs;
  }

  void _filterLogs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredLogs = widget.logs.where((log) {
        final details = (log.details ?? log.target_id ?? '').toLowerCase();
        final userName = _getUserName(log).toLowerCase();
        return details.contains(lowerQuery) || userName.contains(lowerQuery);
      }).toList();
    });
  }

  String _getUserName(amplify_models.ActivityLogs log) {
    if (log.user_id == null) return 'Unknown';
    final matchingEntry = widget.usernameToIdMap.entries.where((e) => e.value == log.user_id).toList();
    if (matchingEntry.isNotEmpty) {
      final keyOrEmail = matchingEntry.first.key.toLowerCase();
      final staffMatches = widget.staffList.where((s) {
        final uname = (s['username']?.toString() ?? '').toLowerCase();
        final email = (s['email']?.toString() ?? '').toLowerCase();
        final name = (s['name']?.toString() ?? '').toLowerCase();
        return uname == keyOrEmail || email == keyOrEmail || name.contains(keyOrEmail);
      }).toList();
      
      if (staffMatches.isNotEmpty) {
        return staffMatches.first['name'] ?? staffMatches.first['username'] ?? keyOrEmail;
      }
      return keyOrEmail;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Logs',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.logs.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 48),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              onChanged: _filterLogs,
              decoration: InputDecoration(
                hintText: 'Search by staff or details...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Logs List
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No data available' : 'No matches found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _filteredLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      final time = (log.created_at != null ? DateTime.tryParse(log.created_at!)?.toLocal() : null) ?? 
                                   log.createdAt?.getDateTimeInUtc().toLocal() ?? DateTime.now();
                      final timeStr = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
                      final userName = _getUserName(log);
                      final details = log.details ?? log.target_id ?? 'Action Recorded';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.history, color: AppTheme.primaryColor),
                          ),
                          title: Text(details, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(userName, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(timeStr, style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
