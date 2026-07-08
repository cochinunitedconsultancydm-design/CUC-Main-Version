import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/OfficeLocations.dart';
import '../services/office_location_service.dart';
import 'add_office_location_screen.dart';

class OfficeDetailsScreen extends StatefulWidget {
  const OfficeDetailsScreen({super.key});

  @override
  State<OfficeDetailsScreen> createState() => _OfficeDetailsScreenState();
}

class _OfficeDetailsScreenState extends State<OfficeDetailsScreen> {
  final OfficeLocationService _service = OfficeLocationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<OfficeLocations> _allLocations = [];
  List<OfficeLocations> _filteredLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    final locations = await _service.getLocations();
    if (mounted) {
      setState(() {
        _allLocations = locations;
        _filteredLocations = locations;
        _isLoading = false;
      });
      _filterLocations();
    }
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLocations = _allLocations.where((loc) {
        final matchName = loc.name?.toLowerCase().contains(query) ?? false;
        final matchPlace = loc.place?.toLowerCase().contains(query) ?? false;
        return matchName || matchPlace;
      }).toList();
    });
  }

  Future<void> _deleteLocation(OfficeLocations location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete Office?'),
          ],
        ),
        content: Text('Are you sure you want to delete ${location.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteLocation(location);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Office location deleted successfully')));
        _fetchLocations();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Premium light background
      appBar: AppBar(
        title: const Text('Office Locations', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by office name or place...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
              child: SizedBox(width: 850, child: AddOfficeLocationScreen()),
            ),
          );
          if (result == true) _fetchLocations();
        },
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Office', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _allLocations.isEmpty
              ? _buildEmptyState('No offices added yet.\nClick "Add Office" to get started.', Icons.business_outlined)
              : _filteredLocations.isEmpty
                  ? _buildEmptyState('No offices match your search.', Icons.search_off_rounded)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive layout: grid for wide screens, list for narrow
                        int crossAxisCount = constraints.maxWidth > 1200 ? 3 : constraints.maxWidth > 800 ? 2 : 1;
                        
                        return GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 450, // Fixed height for cards
                          ),
                          itemCount: _filteredLocations.length,
                          itemBuilder: (context, index) {
                            return _buildPremiumOfficeCard(_filteredLocations[index]);
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
            child: Icon(icon, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumOfficeCard(OfficeLocations loc) {
    List<dynamic> officers = [];
    if (loc.officers_contacts != null && loc.officers_contacts!.isNotEmpty) {
      try {
        officers = jsonDecode(loc.officers_contacts!);
      } catch (_) {}
    }

    List<dynamic> officePhones = [];
    if (loc.office_phone_numbers != null && loc.office_phone_numbers!.isNotEmpty) {
      try {
        officePhones = jsonDecode(loc.office_phone_numbers!);
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor.withValues(alpha: 0.1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                    child: const Icon(Icons.apartment_rounded, color: AppTheme.primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.name ?? 'Unnamed', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (loc.place != null && loc.place!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(loc.place!, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteLocation(loc),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            
            // Body Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (officePhones.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: officePhones.map((p) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.2))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone, color: Colors.green, size: 14),
                              const SizedBox(width: 6),
                              Text('${p['designation']}: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green)),
                              Text(p['phone'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ],
                    if (loc.location_link != null && loc.location_link!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(loc.location_link!);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.map, color: Colors.blue, size: 16)),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('View on Map', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, decoration: TextDecoration.underline))),
                          ],
                        ),
                      ),
                    ],
                    
                    if (officers.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 8),
                        child: Text('KEY CONTACTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: officers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final o = officers[idx];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), child: const Icon(Icons.person, size: 16, color: AppTheme.primaryColor)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(o['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(o['designation'], style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  Text(o['phone'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                    ],
                  ],
                ),
              ),
            ),
            
            // Footer Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (loc.front_view_photo != null) _buildPhotoChip('Front View', _getPhotoCount(loc.front_view_photo!)),
                    if (loc.designation_boards_photos != null) _buildPhotoChip('Designations', _getPhotoCount(loc.designation_boards_photos!)),
                    if (loc.notice_boards_photos != null) _buildPhotoChip('Notices', _getPhotoCount(loc.notice_boards_photos!)),
                    if (loc.other_photos != null) _buildPhotoChip('Other', _getPhotoCount(loc.other_photos!)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getPhotoCount(String jsonArrayStr) {
    try {
      final List list = jsonDecode(jsonArrayStr);
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildPhotoChip(String label, int count) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text('$label ($count)', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}
