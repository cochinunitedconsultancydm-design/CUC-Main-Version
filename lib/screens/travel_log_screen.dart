import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class TravelLogScreen extends StatefulWidget {
  const TravelLogScreen({super.key});

  @override
  State<TravelLogScreen> createState() => _TravelLogScreenState();
}

class _TravelLogScreenState extends State<TravelLogScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(TravelLogs.classType);
      final res = await Amplify.API.query(request: req).response;
      var logs = res.data?.items.whereType<TravelLogs>().toList() ?? [];
      
      logs.sort((a, b) {
        final dateA = a.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        final dateB = b.createdAt?.getDateTimeInUtc() ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      
      // Also fetch users to join
      final uReq = ModelQueries.list(Users.classType);
      final uRes = await Amplify.API.query(request: uReq).response;
      final users = uRes.data?.items.whereType<Users>().toList() ?? [];
      final userMap = {for (var u in users) u.id.toString(): u};

      if (mounted) {
        setState(() {
          _logs = logs.map((log) {
            final user = userMap[log.user_id?.toString()];
            return {
              'id': log.id,
              'destination': log.destination,
              'created_at': log.createdAt?.getDateTimeInUtc().toIso8601String() ?? DateTime.now().toIso8601String(),
              'users': user != null ? {
                'name': user.name,
                'role': user.role,
              } : null,
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching travel logs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load travel logs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No travel logs found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final user = log['users'] as Map<String, dynamic>?;
                    final name = user?['name'] ?? 'Unknown Staff';
                    final role = user?['role'] ?? 'Staff';
                    final destination = log['destination'] as String? ?? 'Unknown Destination';
                    String dateString = log['created_at'];
                    if (!dateString.endsWith('Z') && !dateString.contains('+')) {
                      dateString += 'Z';
                    }
                    final createdAt = DateTime.parse(dateString).toLocal();
                    final timeString = DateFormat('hh:mm a, MMM dd yyyy').format(createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.directions_car, color: Colors.white),
                        ),
                        title: Text(
                          destination,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('$name ($role)', style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(timeString, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
