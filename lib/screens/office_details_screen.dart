import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
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
                        
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: _filteredLocations.map((loc) {
                              // Calculate responsive width
                              double availableWidth = constraints.maxWidth - 48; // minus padding
                              double cardWidth;
                              if (constraints.maxWidth > 1200) {
                                cardWidth = (availableWidth - 48) / 3;
                              } else if (constraints.maxWidth > 800) {
                                cardWidth = (availableWidth - 24) / 2;
                              } else {
                                cardWidth = availableWidth;
                              }
                              
                              return SizedBox(
                                width: cardWidth,
                                child: _buildPremiumOfficeCard(loc),
                              );
                            }).toList(),
                          ),
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

  void _showOfficeDetailsModal(OfficeLocations loc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(child: Text(loc.name ?? 'Office Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor))),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editLocation(loc);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Re-use the existing card layout but expand on photos
                      _buildPremiumOfficeCard(loc, isModal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editLocation(OfficeLocations loc) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(width: 850, child: AddOfficeLocationScreen(existingLocation: loc)),
      ),
    );
    if (result == true) {
      _fetchLocations();
    }
  }

  Widget _buildPremiumOfficeCard(OfficeLocations loc, {bool isModal = false}) {
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

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
        boxShadow: isModal ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 8)),
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.02), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isModal ? null : () => _showOfficeDetailsModal(loc),
            hoverColor: AppTheme.primaryColor.withOpacity(0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // Hug content vertically!
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.apartment_rounded, color: AppTheme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.name ?? 'Unnamed', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            if (loc.place != null && loc.place!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: AppTheme.primaryColor.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(loc.place!, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (!isModal)
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteLocation(loc),
                            splashRadius: 24,
                            tooltip: 'Delete Office',
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Body Section
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (officePhones.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: officePhones.map((p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined, color: Colors.black54, size: 14),
                                const SizedBox(width: 6),
                                Text('${p['designation']}: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
                                Text(p['phone'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ],
                      if (loc.location_link != null && loc.location_link!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final uri = Uri.parse(loc.location_link!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map_rounded, color: Colors.blue.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  Text('View on Map', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      if (officers.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 24, bottom: 12),
                          child: Text('KEY CONTACTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: officers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final o = officers[idx];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 18, backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: const Icon(Icons.person, size: 18, color: AppTheme.primaryColor)),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.phone, size: 12, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(o['phone'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Footer Section (Photos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50, 
                    border: Border(top: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (loc.front_view_photo != null) _buildPhotoChip(context, 'Front View', loc.front_view_photo!),
                        if (loc.designation_boards_photos != null) _buildPhotoChip(context, 'Designations', loc.designation_boards_photos!),
                        if (loc.notice_boards_photos != null) _buildPhotoChip(context, 'Notices', loc.notice_boards_photos!),
                        if (loc.other_photos != null) _buildPhotoChip(context, 'Other', loc.other_photos!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
           ),
        ),
      ),
    );

    return cardContent;
  }

  int _getPhotoCount(String jsonArrayStr) {
    try {
      final List list = jsonDecode(jsonArrayStr);
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildPhotoChip(BuildContext context, String label, String jsonArrayStr) {
    int count = _getPhotoCount(jsonArrayStr);
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPhotoGallery(context, label, jsonArrayStr),
          hoverColor: AppTheme.primaryColor.withOpacity(0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text('$label ($count)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoGallery(BuildContext context, String label, String jsonArrayStr) {
    List<String> paths = [];
    try {
      paths = List<String>.from(jsonDecode(jsonArrayStr));
    } catch (_) {}
    if (paths.isEmpty) return;

    final pageController = PageController();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      barrierLabel: 'Gallery',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: StatefulBuilder(builder: (context, setState) {
            int currentIndex = 0;
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // PageView for Images
                  PageView.builder(
                    controller: pageController,
                    itemCount: paths.length,
                    onPageChanged: (idx) {
                      setState(() {
                        currentIndex = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      return FutureBuilder<dynamic>(
                        future: Amplify.Storage.getUrl(path: StoragePath.fromString(paths[idx])).result,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_rounded, color: Colors.white24, size: 80),
                                  SizedBox(height: 16),
                                  Text('Image could not be loaded', style: TextStyle(color: Colors.white54, fontSize: 16)),
                                ],
                              ),
                            );
                          }
                          return InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Container(
                              alignment: Alignment.center,
                              child: Image.network(
                                snapshot.data!.url.toString(),
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.broken_image_rounded, color: Colors.white24, size: 80),
                                        SizedBox(height: 16),
                                        Text('Image could not be loaded', style: TextStyle(color: Colors.white54, fontSize: 16)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Left/Right Navigation Arrows for Desktop
                  if (paths.length > 1)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentIndex > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                                      onPressed: () {
                                        pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 80), // Placeholder to keep spacing
                          
                          if (currentIndex < paths.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                                      onPressed: () {
                                        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 80), // Placeholder
                        ],
                      ),
                    ),
                  
                  // Top gradient overlay for text readability
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  
                  // Top Header (Title & Close Button)
                  Positioned(
                    top: 48, left: 24, right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            if (paths.length > 1)
                              Text('${currentIndex + 1} of ${paths.length}', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom Pills Indicator
                  if (paths.length > 1)
                    Positioned(
                      bottom: 48, left: 0, right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(paths.length, (i) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    height: 8,
                                    width: currentIndex == i ? 24 : 8,
                                    decoration: BoxDecoration(
                                      color: currentIndex == i ? AppTheme.primaryColor : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
