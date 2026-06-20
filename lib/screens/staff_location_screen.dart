import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class StaffLocationScreen extends StatefulWidget {
  const StaffLocationScreen({super.key});

  @override
  State<StaffLocationScreen> createState() => _StaffLocationScreenState();
}

class _StaffLocationScreenState extends State<StaffLocationScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _staffLocations = [];
  bool _isLoading = true;
  
  int? _selectedUserId;
  List<LatLng> _selectedUserRoute = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client
          .from('staff_locations')
          .select('*, users(name, role)');
      
      if (mounted) {
        setState(() {
          _staffLocations = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });

        if (_staffLocations.isNotEmpty) {
          // Center map on the first staff location after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final first = _staffLocations.first;
              _mapController.move(
                LatLng(first['latitude'] as double, first['longitude'] as double),
                12.0,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: $e')),
        );
      }
    }
  }

  Future<void> _fetchUserRoute(int userId) async {
    setState(() {
      _selectedUserId = userId;
      _selectedUserRoute = [];
    });
    
    try {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      
      final res = await Supabase.instance.client
          .from('location_history')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', startOfDay.toUtc().toIso8601String())
          .lte('recorded_at', endOfDay.toUtc().toIso8601String())
          .order('recorded_at', ascending: true);
          
      if (mounted) {
        setState(() {
          _selectedUserRoute = (res as List).map((row) {
            return LatLng(row['latitude'] as double, row['longitude'] as double);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Locations'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() => _selectedDate = picked);
                if (_selectedUserId != null) {
                  _fetchUserRoute(_selectedUserId!);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchLocations();
              if (_selectedUserId != null) {
                _fetchUserRoute(_selectedUserId!);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // List Panel
                Expanded(
                  flex: 1,
                  child: Material(
                    color: AppTheme.surfaceColor,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          width: double.infinity,
                          child: Text(
                            'Staff Locations (${_staffLocations.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: _staffLocations.isEmpty
                              ? const Center(child: Text('No active locations'))
                              : ListView.builder(
                                  itemCount: _staffLocations.length,
                                  itemBuilder: (context, index) {
                                    final loc = _staffLocations[index];
                                    final user = loc['users'] as Map<String, dynamic>?;
                                    final name = user?['name'] ?? 'Unknown Staff';
                                    final role = user?['role'] ?? 'Staff';
                                    String dateString = loc['updated_at'];
                                    if (!dateString.endsWith('Z') && !dateString.contains('+')) {
                                      dateString += 'Z';
                                    }
                                    final updatedAt = DateTime.parse(dateString).toLocal();
                                    final timeString = DateFormat('hh:mm a, MMM dd').format(updatedAt);

                                    final isActive = DateTime.now().difference(updatedAt).inMinutes < 15;

                                    return ListTile(
                                      leading: Stack(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _selectedUserId == loc['user_id'] ? Colors.green : AppTheme.primaryColor,
                                            child: const Icon(Icons.person, color: Colors.white),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: isActive ? Colors.green : Colors.grey,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: _selectedUserId == loc['user_id'] ? Colors.green : null)),
                                          ),
                                          if (isActive)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Offline', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text('$role\nLast updated: $timeString'),
                                      isThreeLine: true,
                                      selected: _selectedUserId == loc['user_id'],
                                      selectedTileColor: Colors.green.withOpacity(0.1),
                                      onTap: () {
                                        _fetchUserRoute(loc['user_id'] as int);
                                        _mapController.move(
                                          LatLng(loc['latitude'] as double, loc['longitude'] as double),
                                          15.0,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Map Panel
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: LatLng(9.9312, 76.2673), // Default to Cochin
                      initialZoom: 10.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.cochinunited.cuc',
                      ),
                      if (_selectedUserRoute.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline<Object>(
                              points: _selectedUserRoute,
                              color: Colors.blueAccent,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: _staffLocations.map((loc) {
                          final user = loc['users'] as Map<String, dynamic>?;
                          final name = user?['name'] ?? 'Staff';
                          return Marker(
                            point: LatLng(loc['latitude'] as double, loc['longitude'] as double),
                            width: 80,
                            height: 80,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                    border: Border.all(
                                      color: DateTime.now().difference(DateTime.parse(loc['updated_at']).toLocal()).inMinutes < 15 
                                          ? Colors.green 
                                          : Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.location_on, color: DateTime.now().difference(DateTime.parse(loc['updated_at']).toLocal()).inMinutes < 15 ? Colors.green : Colors.grey, size: 40),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
