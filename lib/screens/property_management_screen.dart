import 'dart:io';
import '../services/supabase_backup_service.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cuc_app/services/backup_aware_api.dart';
class PropertyManagementScreen extends StatefulWidget {
  const PropertyManagementScreen({super.key});

  @override
  State<PropertyManagementScreen> createState() => _PropertyManagementScreenState();
}

class _PropertyManagementScreenState extends State<PropertyManagementScreen> {
  List<amplify_models.Properties> _properties = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() => _isLoading = true);
    try {
      final req = ModelQueries.list(amplify_models.Properties.classType);
      final res = await Amplify.API.query(request: req).response;
      final result = (res.data?.items ?? []).whereType<amplify_models.Properties>().toList() ?? [];
      
      result.sort((a, b) => (a.property_name ?? '').compareTo(b.property_name ?? ''));
      
      if (mounted) {
        setState(() {
          _properties = result;
        });
      }
    } catch (e) {
      debugPrint('PropertyMgmt: Query failed: $e');
      _showError('Failed to fetch properties: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showEditForm([amplify_models.Properties? property]) {
    final formWidget = _EditPropertyForm(
      property: property,
      onSaved: () {
        if (mounted) Navigator.pop(context);
        _fetchProperties();
        _showSuccess(property == null ? 'Property added successfully' : 'Property updated successfully');
      },
    );

    if (MediaQuery.of(context).size.width > 800) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: formWidget,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => formWidget,
      );
    }
  }

  void _showDetails(amplify_models.Properties initialProperty) {
    int currentIndex = _filteredProperties.indexWhere((p) => p.id == initialProperty.id);
    if (currentIndex == -1) currentIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final property = _filteredProperties.isNotEmpty ? _filteredProperties[currentIndex] : initialProperty;
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apartment_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Property Details', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(property.property_name ?? 'Unnamed Property', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                            ],
                          ),
                        ),
                        if (_filteredProperties.length > 1) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            tooltip: 'Previous',
                            onPressed: () {
                              setState(() {
                                currentIndex = (currentIndex - 1) % _filteredProperties.length;
                                if (currentIndex < 0) currentIndex += _filteredProperties.length;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                            tooltip: 'Next',
                            onPressed: () {
                              setState(() {
                                currentIndex = (currentIndex + 1) % _filteredProperties.length;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow('Client Name', property.client_name, Icons.person_rounded),
                          _detailRow('Location', property.location, Icons.location_on_rounded),
                          _detailRow('Property Type', property.property_type, Icons.category_rounded),
                          _detailRow('Owner Name', property.owner_name, Icons.manage_accounts_rounded),
                          _phoneDetailRow('Owner Phone', property.owner_phone_numbers, Icons.phone_rounded),
                          _detailRow('Multiple Owners', property.has_multiple_owners != null ? (property.has_multiple_owners! ? 'Yes' : 'No') : null, Icons.group_rounded),
                          _detailRow('Broker Details', property.broker_details, Icons.handshake_rounded),
                          _detailRow('Care Of', property.care_of, Icons.supervised_user_circle_rounded),
                          _detailRow('Legal Disputes', property.has_legal_disputes != null ? (property.has_legal_disputes! ? 'Yes' : 'No') : null, Icons.gavel_rounded),
                          _detailRow('Transaction Type', property.transaction_type, Icons.swap_horiz_rounded),
                          _detailRow('Area', property.area, Icons.square_foot_rounded),
                          _detailRow('Price', property.price != null ? _formatPrice(property.price) : null, Icons.currency_rupee_rounded),
                          _detailRow('Advance Amount', property.advance_amount != null ? _formatPrice(property.advance_amount) : null, Icons.account_balance_wallet_rounded),
                          _detailRow('Negotiable', property.is_negotiable != null ? (property.is_negotiable! ? 'Yes' : 'No') : null, Icons.price_change_rounded),
                          _detailRow('Period', property.period, Icons.timer_rounded),
                          _detailRow('Floor', property.floor, Icons.stairs_rounded),
                          _detailRow('Balcony', property.has_balcony != null ? (property.has_balcony! ? 'Yes' : 'No') : null, Icons.balcony_rounded),
                          _detailRow('Balcony Count', property.balcony_count?.toString(), Icons.numbers_rounded),
                          _detailRow('Furnished', property.is_furnished != null ? (property.is_furnished! ? 'Yes' : 'No') : null, Icons.chair_rounded),
                          _detailRow('Car Parking', property.has_car_parking != null ? (property.has_car_parking! ? 'Yes' : 'No') : null, Icons.local_parking_rounded),
                          _detailRow('Expenses', property.expenses, Icons.receipt_long_rounded),
                          _detailRow('Status', property.status, Icons.info_outline_rounded),
                          _detailRow('Notes', property.notes, Icons.notes_rounded),
                          if (property.photos != null && property.photos!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: property.photos!.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      return InkWell(
                                        onTap: () => _previewPropertyImage(property.photos!, idx),
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.image, color: AppTheme.primaryColor, size: 32),
                                              SizedBox(height: 8),
                                              Text('View', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _detailRow(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[^\s]*)');
    final match = urlRegex.firstMatch(value);
    final hasUrl = match != null;

    Widget valueWidget;
    if (hasUrl) {
      final urlStr = match.group(0)!;
      final uriStr = urlStr.startsWith('http') ? urlStr : 'https://$urlStr';
      valueWidget = InkWell(
        onTap: () async {
          final uri = Uri.parse(uriStr);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Text(
          value,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 14),
        ),
      );
    } else {
      valueWidget = Text(value, style: const TextStyle(color: AppTheme.textColor, fontSize: 14));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneDetailRow(String label, List<String>? phones, IconData icon) {
    if (phones == null || phones.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedTextColor, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                ...phones.map((phoneStr) {
                  final phoneRegex = RegExp(r'\+?[0-9][0-9\s-]{7,}');
                  final match = phoneRegex.firstMatch(phoneStr);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(phoneStr.trim(), style: const TextStyle(color: AppTheme.textColor, fontSize: 14)),
                        ),
                        if (match != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.call, color: Colors.green, size: 20),
                              onPressed: () async {
                                final telStr = 'tel:${match.group(0)!.replaceAll(RegExp(r'[^\d+]'), '')}';
                                final uri = Uri.parse(telStr);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              tooltip: 'Call',
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProperty(amplify_models.Properties property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete ${property.property_name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await BackupAwareApi().delete(property);
      _showSuccess('Property deleted successfully');
      _fetchProperties();
    } catch (e) {
      _showError('Failed to delete property: $e');
      setState(() => _isLoading = false);
    }
  }

  List<amplify_models.Properties> get _filteredProperties {
    return _properties.where((p) {
      final t = _searchTerm.toLowerCase();
      final pName = (p.property_name ?? '').toLowerCase();
      final cName = (p.client_name ?? '').toLowerCase();
      final oName = (p.owner_name ?? '').toLowerCase();
      return pName.contains(t) || cName.contains(t) || oName.contains(t);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProperties;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Property Management', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: Column(
        children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final searchField = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search properties, clients, owners...',
                        hintStyle: const TextStyle(color: AppTheme.mutedTextColor),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: (val) => setState(() => _searchTerm = val),
                    ),
                  );
                  final addButton = Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditForm(),
                      icon: const Icon(Icons.add_home_work_outlined),
                      label: const Text('Add Property', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );

                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 16),
                        addButton,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 16),
                        addButton,
                      ],
                    );
                  }
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No properties found.', style: TextStyle(color: AppTheme.mutedTextColor)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = (constraints.maxWidth / 400).floor();
                          if (crossAxisCount < 1) crossAxisCount = 1;

                          if (crossAxisCount == 1) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final prop = filtered[index];
                                return _buildPropertyCard(prop, margin: const EdgeInsets.only(bottom: 16)).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
                              },
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: filtered.asMap().entries.map((entry) {
                                final index = entry.key;
                                final prop = entry.value;
                                final cardWidth = (constraints.maxWidth - 48 - (16 * (crossAxisCount - 1))) / crossAxisCount;
                                return SizedBox(
                                  width: cardWidth,
                                  child: _buildPropertyCard(prop, margin: EdgeInsets.zero).animate().fadeIn(delay: Duration(milliseconds: 50 * index)),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(amplify_models.Properties prop, {EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 16)}) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetails(prop),
            hoverColor: AppTheme.primaryColor.withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.accentColor.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 32,
                        color: AppTheme.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                prop.property_name ?? 'Unnamed Property',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(prop.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(prop.status).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                (prop.status ?? 'Active').toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(prop.status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(Icons.person_outline, prop.owner_name ?? "N/A"),
                            const SizedBox(width: 16),
                            _buildInfoChip(Icons.location_on_outlined, prop.location ?? "No location"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(Icons.category_outlined, prop.property_type ?? "N/A"),
                            const SizedBox(width: 16),
                            _buildInfoChip(Icons.square_foot_outlined, prop.area ?? "N/A"),
                          ],
                        ),
                        if (prop.notes != null && prop.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(prop.notes!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
                        ],
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.withValues(alpha: 0.15)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PRICE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.mutedTextColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      '₹ ',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                    Text(
                                      _formatPrice(prop.price),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                    if (prop.is_negotiable == true)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                                        child: Text(
                                          '(Negotiable)',
                                          style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.mutedTextColor),
                                  onPressed: () => _showEditForm(prop),
                                  tooltip: 'Edit',
                                  hoverColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteProperty(prop),
                                  tooltip: 'Delete',
                                  hoverColor: Colors.red.withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('sold') || s.contains('rented') || s.contains('leased')) return Colors.blue.shade600;
    if (s.contains('inactive')) return Colors.grey.shade600;
    if (s.contains('negotiation')) return Colors.orange.shade600;
    return AppTheme.primaryColor;
  }

  String _formatPrice(double? price) {
    if (price == null) return '0';
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lac';
    }
    return price.toStringAsFixed(0);
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.mutedTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _previewPropertyImage(List<String> photos, int initialIndex) async {
    showDialog(
      context: context,
      builder: (c) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setState) {
            final key = photos[currentIndex];
            final isUrl = key.startsWith('http://') || key.startsWith('https://');

            Future<String> getUrl() async {
              if (isUrl) return key;
              final result = await Amplify.Storage.getUrl(path: StoragePath.fromString(key)).result;
              return result.url.toString();
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder<String>(
                    future: getUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(child: Text('Could not load image', style: TextStyle(color: Colors.white)));
                      }
                      return InteractiveViewer(
                        child: Image.network(snapshot.data!),
                      );
                    }
                  ),
                  if (photos.length > 1) ...[
                    Positioned(
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 48),
                        onPressed: () {
                          setState(() {
                            currentIndex = (currentIndex - 1) % photos.length;
                            if (currentIndex < 0) currentIndex += photos.length;
                          });
                        }
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 48),
                        onPressed: () {
                          setState(() {
                            currentIndex = (currentIndex + 1) % photos.length;
                          });
                        }
                      ),
                    ),
                  ],
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(c),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}

class _PhoneContact {
  final TextEditingController designationCtrl;
  final TextEditingController phoneCtrl;

  _PhoneContact({String designation = '', String phone = ''})
      : designationCtrl = TextEditingController(text: designation),
        phoneCtrl = TextEditingController(text: phone);

  void dispose() {
    designationCtrl.dispose();
    phoneCtrl.dispose();
  }
}

class _EditPropertyForm extends StatefulWidget {
  final amplify_models.Properties? property;
  final VoidCallback onSaved;

  const _EditPropertyForm({this.property, required this.onSaved});

  @override
  State<_EditPropertyForm> createState() => _EditPropertyFormState();
}

class _EditPropertyFormState extends State<_EditPropertyForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Basic Info
  late TextEditingController _nameCtrl;
  late TextEditingController _clientCtrl;
  late TextEditingController _locationCtrl;
  String _propertyType = 'Apartment/flat';
  late TextEditingController _otherPropertyTypeCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _notesCtrl;

  // Owner & Contacts
  late TextEditingController _ownerNameCtrl;
  List<_PhoneContact> _ownerPhoneContacts = [];
  bool _hasMultipleOwners = false;
  late TextEditingController _brokerCtrl;
  late TextEditingController _careOfCtrl;

  // Pricing & Area
  String _transactionType = 'Sale';
  late TextEditingController _areaCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _advanceAmountCtrl;
  late TextEditingController _periodCtrl;
  bool _isNegotiable = false;

  // Property Details
  late TextEditingController _floorCtrl;
  bool _hasBalcony = false;
  late TextEditingController _balconyCountCtrl;
  bool _isFurnished = false;
  bool _hasCarParking = false;
  bool _hasLegalDisputes = false;
  late TextEditingController _expensesCtrl;

  // Media
  List<String> _uploadedPhotos = [];
  bool _isUploadingPhoto = false;

  Future<void> _uploadPhotosToAWS() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploadingPhoto = true);
        
        for (var file in result.files) {
          if (file.path != null) {
            final path = file.path!;
            final key = 'public/property_photos/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            
            final localFile = AWSFile.fromPath(path);
            await Amplify.Storage.uploadFile(
              localFile: localFile,
              path: StoragePath.fromString(key),
            ).result;
        try {
          final bytes = await File(path).readAsBytes();
          SupabaseBackupService().backupFileInBackground(key, bytes);
        } catch (_) {}
            
            setState(() {
              _uploadedPhotos.add(key);
            });
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photos uploaded successfully!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _previewImage(String key) async {
    bool isUrl = key.startsWith('http://') || key.startsWith('https://');
    String urlToLoad = key;

    if (!isUrl) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
      try {
        final result = await Amplify.Storage.getUrl(path: StoragePath.fromString(key)).result;
        urlToLoad = result.url.toString();
        if (mounted) Navigator.pop(context); // close loader
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // close loader
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load image: $e')));
        }
        return;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(urlToLoad),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _propertyTypes = [
    'Apartment/flat',
    'Plain land',
    'Plain land with commercial building',
    'Plain land with residential building',
    'Commercial room',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    
    // Basic Info
    _nameCtrl = TextEditingController(text: p?.property_name ?? '');
    _clientCtrl = TextEditingController(text: p?.client_name ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    if (p?.property_type != null) {
      if (_propertyTypes.contains(p!.property_type)) {
        _propertyType = p.property_type!;
        _otherPropertyTypeCtrl = TextEditingController();
      } else {
        _propertyType = 'Other';
        _otherPropertyTypeCtrl = TextEditingController(text: p.property_type);
      }
    } else {
      _otherPropertyTypeCtrl = TextEditingController();
    }
    _statusCtrl = TextEditingController(text: p?.status ?? 'Active');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');

    // Owner & Contacts
    _ownerNameCtrl = TextEditingController(text: p?.owner_name ?? '');
    if (p?.owner_phone_numbers != null && p!.owner_phone_numbers!.isNotEmpty) {
      _ownerPhoneContacts = p.owner_phone_numbers!.map((numStr) {
        if (numStr.contains(':')) {
           final parts = numStr.split(':');
           return _PhoneContact(designation: parts[0].trim(), phone: parts.sublist(1).join(':').trim());
        }
        return _PhoneContact(phone: numStr);
      }).toList();
    } else {
      _ownerPhoneContacts.add(_PhoneContact());
    }
    _brokerCtrl = TextEditingController(text: p?.broker_details ?? '');
    _careOfCtrl = TextEditingController(text: p?.care_of ?? '');

    // Pricing & Area
    _transactionType = p?.transaction_type ?? 'Sale';
    _areaCtrl = TextEditingController(text: p?.area ?? '');
    _priceCtrl = TextEditingController(text: p?.price?.toString() ?? '');
    _advanceAmountCtrl = TextEditingController(text: p?.advance_amount?.toString() ?? '');
    _periodCtrl = TextEditingController(text: p?.period ?? '');
    _isNegotiable = p?.is_negotiable ?? false;

    // Property Details
    _floorCtrl = TextEditingController(text: p?.floor ?? '');
    _hasBalcony = p?.has_balcony ?? false;
    _balconyCountCtrl = TextEditingController(text: p?.balcony_count?.toString() ?? '');
    _isFurnished = p?.is_furnished ?? false;
    _hasCarParking = p?.has_car_parking ?? false;
    _hasMultipleOwners = p?.has_multiple_owners ?? false;
    _hasLegalDisputes = p?.has_legal_disputes ?? false;
    _expensesCtrl = TextEditingController(text: p?.expenses ?? '');

    // Media
    if (p?.photos != null && p!.photos!.isNotEmpty) {
      _uploadedPhotos = List.from(p.photos!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _locationCtrl.dispose();
    _otherPropertyTypeCtrl.dispose();
    _statusCtrl.dispose();
    _notesCtrl.dispose();
    _ownerNameCtrl.dispose();
    for (var c in _ownerPhoneContacts) { c.dispose(); }
    _brokerCtrl.dispose();
    _careOfCtrl.dispose();
    _areaCtrl.dispose();
    _priceCtrl.dispose();
    _advanceAmountCtrl.dispose();
    _periodCtrl.dispose();
    _floorCtrl.dispose();
    _balconyCountCtrl.dispose();
    _expensesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final priceVal = double.tryParse(_priceCtrl.text.trim());
      final advanceAmountVal = double.tryParse(_advanceAmountCtrl.text.trim());
      final balconyCountVal = int.tryParse(_balconyCountCtrl.text.trim());
      
      final ownerPhones = _ownerPhoneContacts.map((c) {
        final des = c.designationCtrl.text.trim();
        final ph = c.phoneCtrl.text.trim();
        if (ph.isEmpty) return '';
        if (des.isNotEmpty) return '$des: $ph';
        return ph;
      }).where((t) => t.isNotEmpty).toList();
      final photos = _uploadedPhotos;
      
      if (widget.property == null) {
        final newProp = amplify_models.Properties(
          property_name: _nameCtrl.text.trim(),
          client_name: _clientCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          property_type: _propertyType == 'Other' ? _otherPropertyTypeCtrl.text.trim() : _propertyType,
          status: _statusCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          owner_name: _ownerNameCtrl.text.trim(),
          owner_phone_numbers: ownerPhones,
          has_multiple_owners: _hasMultipleOwners,
          broker_details: _brokerCtrl.text.trim(),
          care_of: _careOfCtrl.text.trim(),
          has_legal_disputes: _hasLegalDisputes,
          transaction_type: _transactionType,
          area: _areaCtrl.text.trim(),
          price: priceVal,
          advance_amount: advanceAmountVal,
          period: _periodCtrl.text.trim(),
          is_negotiable: _isNegotiable,
          floor: _floorCtrl.text.trim(),
          has_balcony: _hasBalcony,
          balcony_count: balconyCountVal,
          is_furnished: _isFurnished,
          has_car_parking: _hasCarParking,
          expenses: _expensesCtrl.text.trim(),
          photos: photos,
        );
        await BackupAwareApi().create(newProp);
      } else {
        final updated = widget.property!.copyWith(
          property_name: _nameCtrl.text.trim(),
          client_name: _clientCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          property_type: _propertyType == 'Other' ? _otherPropertyTypeCtrl.text.trim() : _propertyType,
          status: _statusCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          owner_name: _ownerNameCtrl.text.trim(),
          owner_phone_numbers: ownerPhones,
          has_multiple_owners: _hasMultipleOwners,
          broker_details: _brokerCtrl.text.trim(),
          care_of: _careOfCtrl.text.trim(),
          has_legal_disputes: _hasLegalDisputes,
          transaction_type: _transactionType,
          area: _areaCtrl.text.trim(),
          price: priceVal,
          advance_amount: advanceAmountVal,
          period: _periodCtrl.text.trim(),
          is_negotiable: _isNegotiable,
          floor: _floorCtrl.text.trim(),
          has_balcony: _hasBalcony,
          balcony_count: balconyCountVal,
          is_furnished: _isFurnished,
          has_car_parking: _hasCarParking,
          expenses: _expensesCtrl.text.trim(),
          photos: photos,
        );
        await BackupAwareApi().update(updated);
      }
      widget.onSaved();
    } catch (e) {
      debugPrint('Error saving property: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.property == null ? 'Add Property' : 'Edit Property',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildField('Property Name', _nameCtrl, required: true),
                    const SizedBox(height: 16),
                    _buildDropdown('Property Type', _propertyType, _propertyTypes, (val) => setState(() => _propertyType = val!)),
                    if (_propertyType == 'Other') ...[
                      const SizedBox(height: 16),
                      _buildField('Specify Property Type', _otherPropertyTypeCtrl, required: true),
                    ],
                    const SizedBox(height: 16),
                    _buildField('Location', _locationCtrl),
                    const SizedBox(height: 16),
                    _buildField('Status (e.g. Active, Sold)', _statusCtrl),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Pricing & Area'),
                    _buildField('Area (e.g. 1500 sqft)', _areaCtrl),
                    const SizedBox(height: 16),
                    _buildDropdown('Transaction Type', _transactionType, ['Sale', 'Rent', 'Lease'], (val) => setState(() => _transactionType = val!)),
                    const SizedBox(height: 16),
                    if (_transactionType == 'Rent' || _transactionType == 'Lease') ...[
                      _buildField(_transactionType == 'Rent' ? 'Rent Amount' : 'Lease Amount', _priceCtrl, isNumber: true),
                      const SizedBox(height: 16),
                      if (_transactionType == 'Rent') ...[
                        _buildField('Advance Amount', _advanceAmountCtrl, isNumber: true),
                        const SizedBox(height: 16),
                      ],
                      _buildField('Period (e.g. 11 months, 3 years)', _periodCtrl),
                    ] else ...[
                      _buildField('Price', _priceCtrl, isNumber: true),
                    ],
                    SwitchListTile(
                      title: const Text('Price is Negotiable', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _isNegotiable,
                      onChanged: (val) => setState(() => _isNegotiable = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Owner & Contact Details'),
                    SwitchListTile(
                      title: const Text('Has Multiple Owners', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasMultipleOwners,
                      onChanged: (val) => setState(() => _hasMultipleOwners = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    _buildField('Owner Name', _ownerNameCtrl),
                    const SizedBox(height: 16),
                    const Text('Owner Phone Numbers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedTextColor)),
                    const SizedBox(height: 8),
                    ..._ownerPhoneContacts.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildField(e.key == 0 ? 'Designation' : '', e.value.designationCtrl),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: _buildField(e.key == 0 ? 'Phone Number' : '', e.value.phoneCtrl, isNumber: true),
                            ),
                            if (_ownerPhoneContacts.length > 1)
                              Padding(
                                padding: EdgeInsets.only(top: e.key == 0 ? 24.0 : 0.0),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => setState(() => _ownerPhoneContacts.removeAt(e.key)),
                                ),
                              )
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setState(() => _ownerPhoneContacts.add(_PhoneContact())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Phone Number'),
                    ),
                    const SizedBox(height: 16),
                    _buildField('Broker Details', _brokerCtrl, maxLines: 2),
                    const SizedBox(height: 16),
                    _buildField('Care Of', _careOfCtrl),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Detailed Specifications'),
                    SwitchListTile(
                      title: const Text('Has Legal Disputes', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasLegalDisputes,
                      onChanged: (val) => setState(() => _hasLegalDisputes = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    _buildField('Floor Level', _floorCtrl),
                    SwitchListTile(
                      title: const Text('Has Balcony', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasBalcony,
                      onChanged: (val) => setState(() => _hasBalcony = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    if (_hasBalcony) ...[
                      _buildField('Balcony Count', _balconyCountCtrl, isNumber: true),
                      const SizedBox(height: 16),
                    ],
                    SwitchListTile(
                      title: const Text('Is Furnished', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _isFurnished,
                      onChanged: (val) => setState(() => _isFurnished = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Has Car Parking', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasCarParking,
                      onChanged: (val) => setState(() => _hasCarParking = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildField('Expenses / Maintenance Details', _expensesCtrl, maxLines: 2),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Photos'),
                    if (_uploadedPhotos.isNotEmpty)
                      ..._uploadedPhotos.asMap().entries.map((e) {
                        final fileName = e.value.split('/').last;
                        return ListTile(
                          leading: const Icon(Icons.image, color: AppTheme.primaryColor),
                          title: Text(fileName, style: const TextStyle(fontSize: 14)),
                          onTap: () => _previewImage(e.value),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () => _previewImage(e.value),
                                tooltip: 'Preview Image',
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setState(() => _uploadedPhotos.removeAt(e.key)),
                                tooltip: 'Remove',
                              ),
                            ],
                          ),
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isUploadingPhoto ? null : _uploadPhotosToAWS,
                      icon: _isUploadingPhoto
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.upload_file),
                      label: Text(_isUploadingPhoto ? 'Uploading...' : 'Upload Photos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Other'),
                    _buildField('Client Name (if linked)', _clientCtrl),
                    const SizedBox(height: 16),
                    _buildField('Notes', _notesCtrl, maxLines: 3),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.property == null ? 'Add Property' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedTextColor),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedTextColor),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
