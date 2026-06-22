import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
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
  
  dynamic _selectedUserId;
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
      final uReq = ModelQueries.list(amplify_models.Users.classType);
      final uRes = await Amplify.API.query(request: uReq).response;
      final users = uRes.data?.items.whereType<amplify_models.Users>().toList() ?? [];
      final userMap = {for (var u in users) u.id.toString(): u};

      final lReq = ModelQueries.list(amplify_models.StaffLocations.classType);
      final lRes = await Amplify.API.query(request: lReq).response;
      final locations = lRes.data?.items.whereType<amplify_models.StaffLocations>().toList() ?? [];

      final List<Map<String, dynamic>> combined = locations.map((loc) {
        final u = userMap[loc.user_id?.toString()];
        return {
          'id': loc.id,
          'user_id': loc.user_id,
          'latitude': loc.latitude,
          'longitude': loc.longitude,
          'updated_at': loc.updated_at,
          'users': u != null ? {
            'name': u.name,
            'role': u.role,
          } : null,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _staffLocations = combined;
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

  Future<void> _fetchUserRoute(dynamic userId) async {
    setState(() {
      _selectedUserId = userId;
      _selectedUserRoute = [];
    });
    
    try {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      
      final req = ModelQueries.list(amplify_models.LocationHistory.classType);
      final res = await Amplify.API.query(request: req).response;
      final allHist = res.data?.items.whereType<amplify_models.LocationHistory>().toList() ?? [];
      
      final filtered = allHist.where((h) {
        if (h.user_id?.toString() != userId?.toString()) return false;
        if (h.recorded_at == null) return false;
        final t = DateTime.tryParse(h.recorded_at!)?.toLocal();
        if (t == null) return false;
        return t.isAfter(startOfDay) && t.isBefore(endOfDay);
      }).toList();
      
      filtered.sort((a, b) {
        final ta = DateTime.tryParse(a.recorded_at!) ?? DateTime(2000);
        final tb = DateTime.tryParse(b.recorded_at!) ?? DateTime(2000);
        return ta.compareTo(tb);
      });
          
      if (mounted) {
        setState(() {
          _selectedUserRoute = filtered.map((row) {
            return LatLng(row.latitude ?? 0.0, row.longitude ?? 0.0);
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
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                                    String dateString = loc['updated_at']?.toString() ?? DateTime.now().toIso8601String();
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
                                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Offline', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text('$role\nLast updated: $timeString'),
                                      isThreeLine: true,
                                      selected: _selectedUserId == loc['user_id'],
                                      selectedTileColor: Colors.green.withValues(alpha: 0.1),
                                      onTap: () {
                                        _fetchUserRoute(loc['user_id']);
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
                          String dateStr = loc['updated_at']?.toString() ?? DateTime.now().toIso8601String();
                          if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
                            dateStr += 'Z';
                          }
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
                                      color: DateTime.now().difference(DateTime.parse(dateStr).toLocal()).inMinutes < 15 
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
                                Icon(Icons.location_on, color: DateTime.now().difference(DateTime.parse(dateStr).toLocal()).inMinutes < 15 ? Colors.green : Colors.grey, size: 40),
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

