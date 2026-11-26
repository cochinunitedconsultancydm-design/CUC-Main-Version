import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../theme.dart';
import '../models/OfficeLocations.dart';
import '../models/company_vault.dart';
import '../services/office_location_service.dart';
import '../services/company_vault_service.dart';
import '../services/logging_service.dart';
import 'add_office_location_screen.dart';

class OfficeDetailsScreen extends StatefulWidget {
  final int initialTabIndex;
  const OfficeDetailsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OfficeDetailsScreen> createState() => _OfficeDetailsScreenState();
}

class _OfficeDetailsScreenState extends State<OfficeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OfficeLocationService _locationService = OfficeLocationService();
  final CompanyVaultService _vaultService = CompanyVaultService();

  // Field Offices state
  final TextEditingController _searchController = TextEditingController();
  List<OfficeLocations> _allLocations = [];
  List<OfficeLocations> _filteredLocations = [];
  bool _isLoadingLocations = true;

  // Vault state
  bool _isLoadingVault = true;
  String _selectedDocCategory = 'All';
  final TextEditingController _docSearchController = TextEditingController();
  final TextEditingController _partnerSearchController = TextEditingController();

  final List<String> _docCategories = [
    'All',
    'Deed',
    'Registration & Tax',
    'Banking & Mandate',
    'Compliance & Licenses',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _fetchLocations();
    _fetchVaultData();
    _searchController.addListener(_filterLocations);
    _docSearchController.addListener(() => setState(() {}));
    _partnerSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _docSearchController.dispose();
    _partnerSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVaultData() async {
    setState(() => _isLoadingVault = true);
    await _vaultService.init();
    if (mounted) {
      setState(() => _isLoadingVault = false);
    }
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoadingLocations = true);
    final locations = await _locationService.getLocations();
    if (mounted) {
      setState(() {
        _allLocations = locations;
        _filteredLocations = locations;
        _isLoadingLocations = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.corporate_fare_rounded, color: AppTheme.primaryColor, size: 26),
            SizedBox(width: 10),
            Text(
              'Our Office & Company Vault',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: Color(0xFF0F172A),
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            tooltip: 'Refresh Data',
            onPressed: () {
              _fetchVaultData();
              _fetchLocations();
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              color: Colors.white,
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.black54,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                Tab(
                  icon: const Icon(Icons.article_rounded, size: 20),
                  text: 'Company Deeds & Documentation (${_vaultService.documents.length})',
                ),
                Tab(
                  icon: const Icon(Icons.badge_rounded, size: 20),
                  text: 'Partners & IDs (${_vaultService.partners.length})',
                ),
                const Tab(
                  icon: Icon(Icons.business_center_rounded, size: 20),
                  text: 'Our Office Profile',
                ),
                Tab(
                  icon: const Icon(Icons.apartment_rounded, size: 20),
                  text: 'Field Offices Directory (${_allLocations.length})',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompanyDocsTab(),
          _buildPartnersTab(),
          _buildCompanyProfileTab(),
          _buildOfficeLocationsTab(),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => _showAddEditDocumentDialog(),
          icon: const Icon(Icons.note_add_rounded),
          label: const Text('Add Document / Deed', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _showAddEditPartnerDialog(),
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Add Partner / Director', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () => _showEditProfileDialog(),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Office Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
        );
      case 3:
        return FloatingActionButton.extended(
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
          label: const Text('Add Field Office', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        );
      default:
        return null;
    }
  }

  // ==========================================
  // TAB 1: COMPANY DEEDS & DOCUMENTATION
  // ==========================================
  Widget _buildCompanyDocsTab() {
    if (_isLoadingVault) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final query = _docSearchController.text.trim().toLowerCase();
    final allDocs = _vaultService.documents;
    final filtered = allDocs.where((doc) {
      final matchesCategory = _selectedDocCategory == 'All' || doc.category == _selectedDocCategory;
      final matchesQuery = query.isEmpty ||
          doc.title.toLowerCase().contains(query) ||
          doc.documentNumber.toLowerCase().contains(query) ||
          doc.notes.toLowerCase().contains(query) ||
          doc.fileName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner summary
          _buildVaultHeaderBanner(),
          const SizedBox(height: 20),

          // Search and Category Filter Chips
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _docSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search deeds, registration docs, agreements...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _docSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _docSearchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDocumentDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _docCategories.map((cat) {
                final isSelected = _selectedDocCategory == cat;
                final count = cat == 'All'
                    ? allDocs.length
                    : allDocs.where((d) => d.category == cat).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('$cat ($count)'),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedDocCategory = cat),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Documents Grid
          if (filtered.isEmpty)
            _buildEmptyState(
              allDocs.isEmpty
                  ? 'No company deeds or documents added yet.\nClick "Add Document / Deed" to upload your Partnership Deed, Title Deed, GST, or Licenses.'
                  : 'No documents match the selected filters.',
              Icons.folder_open_rounded,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200
                    ? 3
                    : constraints.maxWidth > 750
                        ? 2
                        : 1;
                double cardWidth = (constraints.maxWidth - (20 * (crossAxisCount - 1))) / crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: filtered.map((doc) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildCompanyDocCard(doc),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVaultHeaderBanner() {
    final prof = _vaultService.profile;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prof.companyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prof.legalEntityType} • Corporate Deeds & Legal Vault',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              if (prof.gstin.isNotEmpty) _buildBannerBadge('GSTIN', prof.gstin),
              if (prof.pan.isNotEmpty) _buildBannerBadge('PAN', prof.pan),
              if (prof.registrationNumber.isNotEmpty) _buildBannerBadge('Reg No', prof.registrationNumber),
              if (prof.msmeUdyam.isNotEmpty) _buildBannerBadge('MSME', prof.msmeUdyam),
              _buildBannerBadge('Total Deeds & Docs', '${_vaultService.documents.length} Files'),
              _buildBannerBadge('Active Partners', '${_vaultService.partners.length} Partners'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerBadge(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildCompanyDocCard(CompanyDocument doc) {
    final hasFile = doc.fileUrl.isNotEmpty;
    Color categoryColor;
    IconData categoryIcon;

    switch (doc.category) {
      case 'Deed':
        categoryColor = const Color(0xFFDC2626);
        categoryIcon = Icons.gavel_rounded;
        break;
      case 'Registration & Tax':
        categoryColor = const Color(0xFF2563EB);
        categoryIcon = Icons.verified_rounded;
        break;
      case 'Banking & Mandate':
        categoryColor = const Color(0xFF059669);
        categoryIcon = Icons.account_balance_rounded;
        break;
      case 'Compliance & Licenses':
        categoryColor = const Color(0xFFD97706);
        categoryIcon = Icons.shield_rounded;
        break;
      default:
        categoryColor = const Color(0xFF6B7280);
        categoryIcon = Icons.insert_drive_file_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doc.category,
                          style: TextStyle(color: categoryColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.black45),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showAddEditDocumentDialog(doc);
                    } else if (val == 'delete') {
                      _confirmDeleteDocument(doc);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit Document'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Document'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (doc.documentNumber.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.tag_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Doc No: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Expanded(
                        child: Text(
                          doc.documentNumber,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (doc.issueDate.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Issued: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(doc.issueDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      if (doc.expiryDate.isNotEmpty) ...[
                        const Text(' • Exp: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(doc.expiryDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (doc.notes.isNotEmpty) ...[
                  Text(
                    doc.notes,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasFile) ...[
                  Row(
                    children: [
                      const Icon(Icons.attachment_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doc.fileName.isNotEmpty ? doc.fileName : 'Attached File',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (doc.fileSize.isNotEmpty)
                        Text(doc.fileSize, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                if (hasFile) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vaultService.openVaultDocument(
                        context,
                        doc.fileUrl,
                        fileName: doc.fileName,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: const Text('View / Open', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddEditDocumentDialog(doc),
                      icon: const Icon(Icons.upload_file_rounded, size: 15),
                      label: const Text('Attach File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                  tooltip: 'Edit',
                  onPressed: () => _showAddEditDocumentDialog(doc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: PARTNERS & DIRECTORS VAULT
  // ==========================================
  Widget _buildPartnersTab() {
    if (_isLoadingVault) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final query = _partnerSearchController.text.trim().toLowerCase();
    final allPartners = _vaultService.partners;
    final filtered = allPartners.where((p) {
      return query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.designation.toLowerCase().contains(query) ||
          p.phone.toLowerCase().contains(query) ||
          p.aadhaarNumber.contains(query) ||
          p.panNumber.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _partnerSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search partner by name, phone, Aadhaar or PAN...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _partnerSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _partnerSearchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddEditPartnerDialog(),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (filtered.isEmpty)
            _buildEmptyState(
              allPartners.isEmpty
                  ? 'No partners added yet.\nClick "Add Partner / Director" to register partners, their Aadhaar cards, PAN cards, and shareholding details.'
                  : 'No partners match your search query.',
              Icons.people_outline_rounded,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1100 ? 2 : 1;
                double cardWidth = (constraints.maxWidth - (20 * (crossAxisCount - 1))) / crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: filtered.map((partner) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildPartnerCard(partner),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(PartnerDocument partner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    partner.name.isNotEmpty ? partner.name.substring(0, 1).toUpperCase() : 'P',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              partner.designation,
                              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          if (partner.sharePercentage.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Share: ${partner.sharePercentage}',
                                style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  tooltip: 'Edit Partner',
                  onPressed: () => _showAddEditPartnerDialog(partner),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Partner',
                  onPressed: () => _confirmDeletePartner(partner),
                ),
              ],
            ),
          ),

          // Body & Credentials Vault
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Info
                if (partner.phone.isNotEmpty || partner.email.isNotEmpty) ...[
                  Row(
                    children: [
                      if (partner.phone.isNotEmpty) ...[
                        const Icon(Icons.phone_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(partner.phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                      ],
                      if (partner.email.isNotEmpty) ...[
                        const Icon(Icons.email_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            partner.email,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                if (partner.address.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.home_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          partner.address,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                const Divider(height: 1),
                const SizedBox(height: 14),
                const Text('IDENTIFICATION & CREDENTIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
                const SizedBox(height: 10),

                // Aadhaar Card Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.fingerprint_rounded, color: Colors.green.shade800, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aadhaar Card', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                            Text(
                              partner.aadhaarNumber.isNotEmpty ? partner.aadhaarNumber : 'Not Specified',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      if (partner.aadhaarDocUrl.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: () => _vaultService.openVaultDocument(
                            context,
                            partner.aadhaarDocUrl,
                            fileName: partner.aadhaarDocName.isNotEmpty ? partner.aadhaarDocName : '${partner.name}_Aadhaar.pdf',
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                          label: const Text('View Aadhaar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ] else ...[
                        Text('No File', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // PAN Card Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.credit_card_rounded, color: Colors.blue.shade800, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Permanent Account Number (PAN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                            Text(
                              partner.panNumber.isNotEmpty ? partner.panNumber : 'Not Specified',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      if (partner.panDocUrl.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: () => _vaultService.openVaultDocument(
                            context,
                            partner.panDocUrl,
                            fileName: partner.panDocName.isNotEmpty ? partner.panDocName : '${partner.name}_PAN.pdf',
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                          label: const Text('View PAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ] else ...[
                        Text('No File', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),

                // Other Attached Document
                if (partner.otherDocUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attachment_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            partner.otherDocName.isNotEmpty ? partner.otherDocName : 'Additional ID / Document',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _vaultService.openVaultDocument(
                            context,
                            partner.otherDocUrl,
                            fileName: partner.otherDocName,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                          label: const Text('View', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: OUR OFFICE PROFILE
  // ==========================================
  Widget _buildCompanyProfileTab() {
    final prof = _vaultService.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.corporate_fare_rounded, color: AppTheme.primaryColor, size: 36),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prof.companyName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Entity Type: ${prof.legalEntityType}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showEditProfileDialog(),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Statutory & Registration Numbers Grid
              const Text('STATUTORY REGISTRATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildProfileInfoTile('Firm Registration / CIN', prof.registrationNumber.isNotEmpty ? prof.registrationNumber : 'Not Specified', Icons.app_registration_rounded, constraints.maxWidth),
                      _buildProfileInfoTile('GSTIN (GST Number)', prof.gstin.isNotEmpty ? prof.gstin : 'Not Specified', Icons.receipt_long_rounded, constraints.maxWidth),
                      _buildProfileInfoTile('Company PAN', prof.pan.isNotEmpty ? prof.pan : 'Not Specified', Icons.credit_card_rounded, constraints.maxWidth),
                      _buildProfileInfoTile('Company TAN', prof.tan.isNotEmpty ? prof.tan : 'Not Specified', Icons.account_balance_rounded, constraints.maxWidth),
                      _buildProfileInfoTile('MSME / Udyam Reg No', prof.msmeUdyam.isNotEmpty ? prof.msmeUdyam : 'Not Specified', Icons.business_center_rounded, constraints.maxWidth),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Addresses
              const Text('OFFICE ADDRESSES & CONTACT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAddressRow(Icons.location_on_rounded, 'Registered Office Address', prof.registeredAddress),
                      const Divider(height: 24),
                      _buildAddressRow(Icons.business_rounded, 'Corporate / Branch Office Address', prof.corporateAddress),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAddressRow(Icons.phone_rounded, 'Official Phone', prof.contactPhone),
                          ),
                          Expanded(
                            child: _buildAddressRow(Icons.email_rounded, 'Official Email', prof.contactEmail),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bank Details
              const Text('OFFICIAL BANK ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildAddressRow(Icons.account_balance_rounded, 'Bank Name', prof.bankName.isNotEmpty ? prof.bankName : 'Not Set')),
                          Expanded(child: _buildAddressRow(Icons.tag_rounded, 'Account Number', prof.accountNumber.isNotEmpty ? prof.accountNumber : 'Not Set')),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildAddressRow(Icons.code_rounded, 'IFSC Code', prof.ifscCode.isNotEmpty ? prof.ifscCode : 'Not Set')),
                          Expanded(child: _buildAddressRow(Icons.place_rounded, 'Branch', prof.branch.isNotEmpty ? prof.branch : 'Not Set')),
                        ],
                      ),
                      if (prof.upiId.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildAddressRow(Icons.qr_code_rounded, 'UPI ID / VPA', prof.upiId),
                      ],
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

  Widget _buildProfileInfoTile(String title, String value, IconData icon, double maxWidth) {
    double width = maxWidth > 600 ? (maxWidth - 16) / 2 : maxWidth;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not Set',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: FIELD & GOVT OFFICES DIRECTORY (Existing)
  // ==========================================
  Widget _buildOfficeLocationsTab() {
    return _isLoadingLocations
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
        : Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by office name or place (e.g. Krishi Bhavan, Taluk Office)...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                ),
              ),
              Expanded(
                child: _allLocations.isEmpty
                    ? _buildEmptyState('No field offices added yet.\nClick "Add Field Office" to record government offices, contacts, and photos.', Icons.business_outlined)
                    : _filteredLocations.isEmpty
                        ? _buildEmptyState('No offices match your search.', Icons.search_off_rounded)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 1200
                                  ? 3
                                  : constraints.maxWidth > 800
                                      ? 2
                                      : 1;

                              return SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                                child: Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  children: _filteredLocations.map((loc) {
                                    double availableWidth = constraints.maxWidth - 48;
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
              ),
            ],
          );
  }

  // ==========================================
  // DIALOGS: ADD / EDIT COMPANY DOCUMENT
  // ==========================================
  void _showAddEditDocumentDialog([CompanyDocument? existingDoc]) {
    final titleCtrl = TextEditingController(text: existingDoc?.title);
    String selectedCategory = existingDoc?.category ?? 'Deed';
    final docNumCtrl = TextEditingController(text: existingDoc?.documentNumber);
    final issueDateCtrl = TextEditingController(text: existingDoc?.issueDate);
    final expiryDateCtrl = TextEditingController(text: existingDoc?.expiryDate);
    final notesCtrl = TextEditingController(text: existingDoc?.notes);

    PlatformFile? pickedFile;
    String currentFileUrl = existingDoc?.fileUrl ?? '';
    String currentFileName = existingDoc?.fileName ?? '';
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: 650,
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.note_add_rounded, color: AppTheme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            existingDoc != null ? 'Edit Company Document' : 'Add Company Document / Deed',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Document Title *',
                        hintText: 'e.g. Partnership Deed 2024, Office Rent Agreement, GST Certificate',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category & Doc Number
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _docCategories
                                .where((c) => c != 'All')
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedCategory = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: docNumCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Document / Reg / Cert No',
                              hintText: 'e.g. 1234/2024, 32AABC...1Z5',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: issueDateCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Issue / Execution Date',
                              suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1980),
                                lastDate: DateTime(2050),
                              );
                              if (picked != null) {
                                issueDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: expiryDateCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Expiry / Renewal Date (Optional)',
                              suffixIcon: Icon(Icons.calendar_month_rounded, size: 18),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2050),
                              );
                              if (picked != null) {
                                expiryDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Description',
                        hintText: 'Optional details, terms, location where hard copy is filed...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // File Upload Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          if (currentFileUrl.isNotEmpty || pickedFile != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pickedFile?.name ?? currentFileName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (pickedFile != null)
                                        Text('${(pickedFile!.size / 1024).toStringAsFixed(1)} KB (Ready to upload)', style: const TextStyle(fontSize: 11, color: Colors.green))
                                      else
                                        const Text('Cloud Attached File', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                                  onPressed: () {
                                    setDialogState(() {
                                      pickedFile = null;
                                      currentFileUrl = '';
                                      currentFileName = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          OutlinedButton.icon(
                            onPressed: () async {
                              final res = await FilePicker.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
                              );
                              if (res != null && res.files.isNotEmpty) {
                                setDialogState(() {
                                  pickedFile = res.files.first;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text(currentFileUrl.isNotEmpty || pickedFile != null ? 'Change Attached File' : 'Pick PDF or Image File'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final title = titleCtrl.text.trim();
                                  if (title.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter a document title')),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isUploading = true);

                                  String fileUrl = currentFileUrl;
                                  String fileName = currentFileName;
                                  String fileSize = existingDoc?.fileSize ?? '';

                                  if (pickedFile != null) {
                                    final uploadedKey = await _vaultService.uploadVaultFile(
                                      pickedFile!,
                                      subfolder: 'deeds',
                                    );
                                    if (uploadedKey != null) {
                                      fileUrl = uploadedKey;
                                      fileName = pickedFile!.name;
                                      fileSize = '${(pickedFile!.size / 1024).toStringAsFixed(1)} KB';
                                    }
                                  }

                                  final doc = CompanyDocument(
                                    id: existingDoc?.id ?? UUID.getUUID(),
                                    title: title,
                                    category: selectedCategory,
                                    documentNumber: docNumCtrl.text.trim(),
                                    issueDate: issueDateCtrl.text.trim(),
                                    expiryDate: expiryDateCtrl.text.trim(),
                                    notes: notesCtrl.text.trim(),
                                    fileUrl: fileUrl,
                                    fileName: fileName,
                                    fileSize: fileSize,
                                    createdAt: existingDoc?.createdAt ?? DateTime.now().toIso8601String(),
                                  );

                                  if (existingDoc != null) {
                                    await _vaultService.updateCompanyDocument(doc);
                                  } else {
                                    await _vaultService.addCompanyDocument(doc);
                                  }

                                  await LoggingService().logAction(
                                    action: existingDoc != null ? 'COMPANY_DOC_UPDATED' : 'COMPANY_DOC_ADDED',
                                    targetType: 'Company Vault',
                                    targetId: doc.id,
                                    details: 'Saved company document: ${doc.title} (${doc.category})',
                                  );

                                  if (context.mounted) Navigator.pop(dialogCtx);
                                  setState(() {});
                                },
                          icon: isUploading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(isUploading ? 'Uploading...' : 'Save Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
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

  void _confirmDeleteDocument(CompanyDocument doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _vaultService.deleteCompanyDocument(doc.id);
      await LoggingService().logAction(
        action: 'COMPANY_DOC_DELETED',
        targetType: 'Company Vault',
        targetId: doc.id,
        details: 'Deleted company document: ${doc.title}',
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully')),
        );
      }
    }
  }

  // ==========================================
  // DIALOGS: ADD / EDIT PARTNER & IDS
  // ==========================================
  void _showAddEditPartnerDialog([PartnerDocument? existingPartner]) {
    final nameCtrl = TextEditingController(text: existingPartner?.name);
    final desigCtrl = TextEditingController(text: existingPartner?.designation ?? 'Partner');
    final shareCtrl = TextEditingController(text: existingPartner?.sharePercentage);
    final phoneCtrl = TextEditingController(text: existingPartner?.phone);
    final emailCtrl = TextEditingController(text: existingPartner?.email);
    final addrCtrl = TextEditingController(text: existingPartner?.address);
    final aadhaarCtrl = TextEditingController(text: existingPartner?.aadhaarNumber);
    final panCtrl = TextEditingController(text: existingPartner?.panNumber);
    final notesCtrl = TextEditingController(text: existingPartner?.notes);

    PlatformFile? pickedAadhaar;
    String currentAadhaarUrl = existingPartner?.aadhaarDocUrl ?? '';
    String currentAadhaarName = existingPartner?.aadhaarDocName ?? '';

    PlatformFile? pickedPan;
    String currentPanUrl = existingPartner?.panDocUrl ?? '';
    String currentPanName = existingPartner?.panDocName ?? '';

    PlatformFile? pickedOther;
    String currentOtherUrl = existingPartner?.otherDocUrl ?? '';
    String currentOtherName = existingPartner?.otherDocName ?? '';

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: 700,
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.person_pin_rounded, color: Colors.blue.shade800, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            existingPartner != null ? 'Edit Partner / Director' : 'Add Partner / Director',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name & Designation
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Partner / Director Full Name *',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: desigCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Designation',
                              hintText: 'e.g. Managing Partner',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: shareCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Share %',
                              hintText: '50%',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone & Email
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Contact Phone Number',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextField(
                      controller: addrCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Residential Address',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('IDENTIFICATION DOCUMENTS (AADHAAR & PAN)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 14),

                    // Aadhaar Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fingerprint_rounded, color: Colors.green.shade800, size: 20),
                              const SizedBox(width: 8),
                              const Text('Aadhaar Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: aadhaarCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Aadhaar Number (12 Digits)',
                                    hintText: 'e.g. 1234 5678 9012',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final res = await FilePicker.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                                    );
                                    if (res != null && res.files.isNotEmpty) {
                                      setDialogState(() => pickedAadhaar = res.files.first);
                                    }
                                  },
                                  icon: const Icon(Icons.attach_file, size: 16),
                                  label: Text(
                                    pickedAadhaar != null
                                        ? pickedAadhaar!.name
                                        : currentAadhaarUrl.isNotEmpty
                                            ? 'Change File'
                                            : 'Attach Aadhaar',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green.shade800,
                                    side: BorderSide(color: Colors.green.shade400),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PAN Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.credit_card_rounded, color: Colors.blue.shade800, size: 20),
                              const SizedBox(width: 8),
                              const Text('PAN Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: panCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'PAN Number (10 Characters)',
                                    hintText: 'e.g. ABCDE1234F',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final res = await FilePicker.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                                    );
                                    if (res != null && res.files.isNotEmpty) {
                                      setDialogState(() => pickedPan = res.files.first);
                                    }
                                  },
                                  icon: const Icon(Icons.attach_file, size: 16),
                                  label: Text(
                                    pickedPan != null
                                        ? pickedPan!.name
                                        : currentPanUrl.isNotEmpty
                                            ? 'Change File'
                                            : 'Attach PAN',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue.shade800,
                                    side: BorderSide(color: Colors.blue.shade400),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Other Document
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: notesCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Notes / DIN / Passport Details',
                              hintText: 'Optional notes, DIN number, etc.',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final res = await FilePicker.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                            );
                            if (res != null && res.files.isNotEmpty) {
                              setDialogState(() => pickedOther = res.files.first);
                            }
                          },
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: Text(
                            pickedOther != null
                                ? pickedOther!.name
                                : currentOtherUrl.isNotEmpty
                                    ? 'Change Other Doc'
                                    : 'Attach Other Doc',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  if (name.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter partner name')),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSaving = true);

                                  String aadhaarUrl = currentAadhaarUrl;
                                  String aadhaarName = currentAadhaarName;
                                  if (pickedAadhaar != null) {
                                    final up = await _vaultService.uploadVaultFile(pickedAadhaar!, subfolder: 'aadhaar');
                                    if (up != null) {
                                      aadhaarUrl = up;
                                      aadhaarName = pickedAadhaar!.name;
                                    }
                                  }

                                  String panUrl = currentPanUrl;
                                  String panName = currentPanName;
                                  if (pickedPan != null) {
                                    final up = await _vaultService.uploadVaultFile(pickedPan!, subfolder: 'pan');
                                    if (up != null) {
                                      panUrl = up;
                                      panName = pickedPan!.name;
                                    }
                                  }

                                  String otherUrl = currentOtherUrl;
                                  String otherName = currentOtherName;
                                  if (pickedOther != null) {
                                    final up = await _vaultService.uploadVaultFile(pickedOther!, subfolder: 'other');
                                    if (up != null) {
                                      otherUrl = up;
                                      otherName = pickedOther!.name;
                                    }
                                  }

                                  final partner = PartnerDocument(
                                    id: existingPartner?.id ?? UUID.getUUID(),
                                    name: name,
                                    designation: desigCtrl.text.trim().isNotEmpty ? desigCtrl.text.trim() : 'Partner',
                                    sharePercentage: shareCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    address: addrCtrl.text.trim(),
                                    aadhaarNumber: aadhaarCtrl.text.trim(),
                                    aadhaarDocUrl: aadhaarUrl,
                                    aadhaarDocName: aadhaarName,
                                    panNumber: panCtrl.text.trim().toUpperCase(),
                                    panDocUrl: panUrl,
                                    panDocName: panName,
                                    otherDocUrl: otherUrl,
                                    otherDocName: otherName,
                                    notes: notesCtrl.text.trim(),
                                    createdAt: existingPartner?.createdAt ?? DateTime.now().toIso8601String(),
                                  );

                                  if (existingPartner != null) {
                                    await _vaultService.updatePartner(partner);
                                  } else {
                                    await _vaultService.addPartner(partner);
                                  }

                                  await LoggingService().logAction(
                                    action: existingPartner != null ? 'PARTNER_UPDATED' : 'PARTNER_ADDED',
                                    targetType: 'Company Vault',
                                    targetId: partner.id,
                                    details: 'Saved partner profile: ${partner.name} (${partner.designation})',
                                  );

                                  if (context.mounted) Navigator.pop(dialogCtx);
                                  setState(() {});
                                },
                          icon: isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(isSaving ? 'Saving...' : 'Save Partner Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
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

  void _confirmDeletePartner(PartnerDocument partner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Partner Record?'),
        content: Text('Are you sure you want to remove "${partner.name}" from company partners?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _vaultService.deletePartner(partner.id);
      await LoggingService().logAction(
        action: 'PARTNER_DELETED',
        targetType: 'Company Vault',
        targetId: partner.id,
        details: 'Deleted partner profile: ${partner.name}',
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partner removed successfully')),
        );
      }
    }
  }

  // ==========================================
  // DIALOGS: EDIT COMPANY PROFILE
  // ==========================================
  void _showEditProfileDialog() {
    final prof = _vaultService.profile;
    final nameCtrl = TextEditingController(text: prof.companyName);
    final typeCtrl = TextEditingController(text: prof.legalEntityType);
    final regNumCtrl = TextEditingController(text: prof.registrationNumber);
    final gstinCtrl = TextEditingController(text: prof.gstin);
    final panCtrl = TextEditingController(text: prof.pan);
    final tanCtrl = TextEditingController(text: prof.tan);
    final msmeCtrl = TextEditingController(text: prof.msmeUdyam);
    final regAddrCtrl = TextEditingController(text: prof.registeredAddress);
    final corpAddrCtrl = TextEditingController(text: prof.corporateAddress);
    final phoneCtrl = TextEditingController(text: prof.contactPhone);
    final emailCtrl = TextEditingController(text: prof.contactEmail);
    final webCtrl = TextEditingController(text: prof.website);
    final bankNameCtrl = TextEditingController(text: prof.bankName);
    final accNumCtrl = TextEditingController(text: prof.accountNumber);
    final ifscCtrl = TextEditingController(text: prof.ifscCode);
    final branchCtrl = TextEditingController(text: prof.branch);
    final upiCtrl = TextEditingController(text: prof.upiId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 750,
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.corporate_fare_rounded, color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('Edit Our Office & Company Profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name & Type
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Company / Firm Name *', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: typeCtrl,
                        decoration: const InputDecoration(labelText: 'Entity Type (e.g. Partnership Firm)', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reg & GST
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: regNumCtrl,
                        decoration: const InputDecoration(labelText: 'Registration / Firm Number', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: gstinCtrl,
                        decoration: const InputDecoration(labelText: 'GSTIN (GST Number)', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // PAN, TAN, MSME
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: panCtrl,
                        decoration: const InputDecoration(labelText: 'Company PAN', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: tanCtrl,
                        decoration: const InputDecoration(labelText: 'Company TAN', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: msmeCtrl,
                        decoration: const InputDecoration(labelText: 'MSME / Udyam No', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Addresses
                TextField(
                  controller: regAddrCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Registered Office Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: corpAddrCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Corporate / Branch Office Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Contact
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Official Phone', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Official Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bank
                const Divider(),
                const SizedBox(height: 10),
                const Text('OFFICIAL BANK ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bankNameCtrl,
                        decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: accNumCtrl,
                        decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ifscCtrl,
                        decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: branchCtrl,
                        decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: upiCtrl,
                        decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = prof.copyWith(
                          companyName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Cochin United Consultancy',
                          legalEntityType: typeCtrl.text.trim(),
                          registrationNumber: regNumCtrl.text.trim(),
                          gstin: gstinCtrl.text.trim().toUpperCase(),
                          pan: panCtrl.text.trim().toUpperCase(),
                          tan: tanCtrl.text.trim().toUpperCase(),
                          msmeUdyam: msmeCtrl.text.trim(),
                          registeredAddress: regAddrCtrl.text.trim(),
                          corporateAddress: corpAddrCtrl.text.trim(),
                          contactPhone: phoneCtrl.text.trim(),
                          contactEmail: emailCtrl.text.trim(),
                          website: webCtrl.text.trim(),
                          bankName: bankNameCtrl.text.trim(),
                          accountNumber: accNumCtrl.text.trim(),
                          ifscCode: ifscCtrl.text.trim().toUpperCase(),
                          branch: branchCtrl.text.trim(),
                          upiId: upiCtrl.text.trim(),
                        );

                        await _vaultService.updateCompanyProfile(updated);
                        await LoggingService().logAction(
                          action: 'COMPANY_PROFILE_UPDATED',
                          targetType: 'Company Vault',
                          targetId: 'cuc_company_profile',
                          details: 'Updated official company details for ${updated.companyName}',
                        );

                        if (context.mounted) Navigator.pop(dialogCtx);
                        setState(() {});
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FIELD OFFICES METHODS (Preserved)
  // ==========================================
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Icon(icon, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
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
      final success = await _locationService.deleteLocation(location);
      if (success && mounted) {
        await LoggingService().logAction(
          action: 'OFFICE_LOCATION_DELETED',
          targetType: 'Office Location',
          targetId: location.id,
          details: 'Deleted office location: ${location.name}',
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Office location deleted successfully')));
        _fetchLocations();
      }
    }
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
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1.5),
        boxShadow: isModal ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 8)),
          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.02), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isModal ? null : () => _showOfficeDetailsModal(loc),
            hoverColor: AppTheme.primaryColor.withValues(alpha: 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.primaryColor.withValues(alpha: 0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
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
                                  Icon(Icons.location_on, size: 14, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
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
                            color: Colors.red.withValues(alpha: 0.1),
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
                          color: Colors.blue.withValues(alpha: 0.08),
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
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final o = officers[idx];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 18, backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), child: const Icon(Icons.person, size: 18, color: AppTheme.primaryColor)),
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
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPhotoGallery(context, label, jsonArrayStr),
          hoverColor: AppTheme.primaryColor.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library_rounded, size: 16, color: AppTheme.primaryColor),
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
      barrierColor: Colors.black.withValues(alpha: 0.9),
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
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
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
                            const SizedBox(width: 80),
                          if (currentIndex < paths.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
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
                            const SizedBox(width: 80),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 48,
                    left: 24,
                    right: 24,
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
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
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
                  if (paths.length > 1)
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                                      color: currentIndex == i ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.4),
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
