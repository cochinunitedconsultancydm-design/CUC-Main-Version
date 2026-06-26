import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart' as amplify_models;
import '../theme.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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
      final result = res.data?.items.whereType<amplify_models.Properties>().toList() ?? [];
      
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditPropertyForm(
        property: property,
        onSaved: () {
          if (mounted) Navigator.pop(context);
          _fetchProperties();
          _showSuccess(property == null ? 'Property added successfully' : 'Property updated successfully');
        },
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
      await Amplify.API.mutate(request: ModelMutations.delete(property)).response;
      _showSuccess('Property deleted successfully');
      _fetchProperties();
    } catch (e) {
      _showError('Failed to delete property: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _properties.where((p) {
      final t = _searchTerm.toLowerCase();
      final pName = (p.property_name ?? '').toLowerCase();
      final cName = (p.client_name ?? '').toLowerCase();
      final oName = (p.owner_name ?? '').toLowerCase();
      return pName.contains(t) || cName.contains(t) || oName.contains(t);
    }).toList();

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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(bottom: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search properties, clients, owners...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.mutedTextColor),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (val) => setState(() => _searchTerm = val),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showEditForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Property'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No properties found.', style: TextStyle(color: AppTheme.mutedTextColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final prop = filtered[index];
                          return _buildPropertyCard(prop).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(amplify_models.Properties prop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    prop.property_name ?? 'Unnamed Property',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    prop.status ?? 'Active',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.mutedTextColor),
                      onPressed: () => _showEditForm(prop),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProperty(prop),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppTheme.mutedTextColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Owner: ${prop.owner_name ?? "N/A"}', style: const TextStyle(color: AppTheme.mutedTextColor))),
                const Icon(Icons.location_on, size: 16, color: AppTheme.mutedTextColor),
                const SizedBox(width: 8),
                Expanded(child: Text(prop.location ?? 'No location', style: const TextStyle(color: AppTheme.mutedTextColor))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: AppTheme.mutedTextColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Type: ${prop.property_type ?? "N/A"}', style: const TextStyle(color: AppTheme.mutedTextColor))),
                const Icon(Icons.square_foot, size: 16, color: AppTheme.mutedTextColor),
                const SizedBox(width: 8),
                Expanded(child: Text('Area: ${prop.area ?? "N/A"}', style: const TextStyle(color: AppTheme.mutedTextColor))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: AppTheme.mutedTextColor),
                const SizedBox(width: 8),
                Text('Price: ${prop.price ?? 0.0}', style: const TextStyle(color: AppTheme.mutedTextColor, fontWeight: FontWeight.bold)),
                if (prop.is_negotiable == true)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Negotiable', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            if (prop.notes != null && prop.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor, fontSize: 13)),
              const SizedBox(height: 4),
              Text(prop.notes!, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
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
  late TextEditingController _statusCtrl;
  late TextEditingController _notesCtrl;

  // Owner & Contacts
  late TextEditingController _ownerNameCtrl;
  List<TextEditingController> _ownerPhoneCtrls = [];
  late TextEditingController _brokerCtrl;
  late TextEditingController _careOfCtrl;

  // Pricing & Area
  late TextEditingController _areaCtrl;
  late TextEditingController _priceCtrl;
  bool _isNegotiable = false;

  // Property Details
  late TextEditingController _floorCtrl;
  bool _hasBalcony = false;
  late TextEditingController _balconyCountCtrl;
  bool _isFurnished = false;
  bool _hasCarParking = false;
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
    if (p?.property_type != null && _propertyTypes.contains(p!.property_type)) {
      _propertyType = p.property_type!;
    }
    _statusCtrl = TextEditingController(text: p?.status ?? 'Active');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');

    // Owner & Contacts
    _ownerNameCtrl = TextEditingController(text: p?.owner_name ?? '');
    if (p?.owner_phone_numbers != null && p!.owner_phone_numbers!.isNotEmpty) {
      _ownerPhoneCtrls = p.owner_phone_numbers!.map((num) => TextEditingController(text: num)).toList();
    } else {
      _ownerPhoneCtrls.add(TextEditingController());
    }
    _brokerCtrl = TextEditingController(text: p?.broker_details ?? '');
    _careOfCtrl = TextEditingController(text: p?.care_of ?? '');

    // Pricing & Area
    _areaCtrl = TextEditingController(text: p?.area ?? '');
    _priceCtrl = TextEditingController(text: p?.price?.toString() ?? '');
    _isNegotiable = p?.is_negotiable ?? false;

    // Property Details
    _floorCtrl = TextEditingController(text: p?.floor ?? '');
    _hasBalcony = p?.has_balcony ?? false;
    _balconyCountCtrl = TextEditingController(text: p?.balcony_count?.toString() ?? '');
    _isFurnished = p?.is_furnished ?? false;
    _hasCarParking = p?.has_car_parking ?? false;
    _expensesCtrl = TextEditingController(text: p?.expenses ?? '');

    // Media
    if (p?.photos != null && p!.photos!.isNotEmpty) {
      _uploadedPhotos = List.from(p!.photos!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _locationCtrl.dispose();
    _statusCtrl.dispose();
    _notesCtrl.dispose();
    _ownerNameCtrl.dispose();
    for (var c in _ownerPhoneCtrls) { c.dispose(); }
    _brokerCtrl.dispose();
    _careOfCtrl.dispose();
    _areaCtrl.dispose();
    _priceCtrl.dispose();
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
      final balconyCountVal = int.tryParse(_balconyCountCtrl.text.trim());
      
      final ownerPhones = _ownerPhoneCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      final photos = _uploadedPhotos;
      
      if (widget.property == null) {
        final newProp = amplify_models.Properties(
          property_name: _nameCtrl.text.trim(),
          client_name: _clientCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          property_type: _propertyType,
          status: _statusCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          owner_name: _ownerNameCtrl.text.trim(),
          owner_phone_numbers: ownerPhones,
          broker_details: _brokerCtrl.text.trim(),
          care_of: _careOfCtrl.text.trim(),
          area: _areaCtrl.text.trim(),
          price: priceVal,
          is_negotiable: _isNegotiable,
          floor: _floorCtrl.text.trim(),
          has_balcony: _hasBalcony,
          balcony_count: balconyCountVal,
          is_furnished: _isFurnished,
          has_car_parking: _hasCarParking,
          expenses: _expensesCtrl.text.trim(),
          photos: photos,
        );
        await Amplify.API.mutate(request: ModelMutations.create(newProp)).response;
      } else {
        final updated = widget.property!.copyWith(
          property_name: _nameCtrl.text.trim(),
          client_name: _clientCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          property_type: _propertyType,
          status: _statusCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          owner_name: _ownerNameCtrl.text.trim(),
          owner_phone_numbers: ownerPhones,
          broker_details: _brokerCtrl.text.trim(),
          care_of: _careOfCtrl.text.trim(),
          area: _areaCtrl.text.trim(),
          price: priceVal,
          is_negotiable: _isNegotiable,
          floor: _floorCtrl.text.trim(),
          has_balcony: _hasBalcony,
          balcony_count: balconyCountVal,
          is_furnished: _isFurnished,
          has_car_parking: _hasCarParking,
          expenses: _expensesCtrl.text.trim(),
          photos: photos,
        );
        await Amplify.API.mutate(request: ModelMutations.update(updated)).response;
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
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    const SizedBox(height: 16),
                    _buildField('Location', _locationCtrl),
                    const SizedBox(height: 16),
                    _buildField('Status (e.g. Active, Sold)', _statusCtrl),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Pricing & Area'),
                    Row(
                      children: [
                        Expanded(child: _buildField('Area (e.g. 1500 sqft)', _areaCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField('Price', _priceCtrl, isNumber: true)),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Price is Negotiable', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _isNegotiable,
                      onChanged: (val) => setState(() => _isNegotiable = val),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Owner & Contact Details'),
                    _buildField('Owner Name', _ownerNameCtrl),
                    const SizedBox(height: 16),
                    const Text('Owner Phone Numbers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedTextColor)),
                    const SizedBox(height: 8),
                    ..._ownerPhoneCtrls.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: _buildField('', e.value, isNumber: true)),
                            if (_ownerPhoneCtrls.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setState(() => _ownerPhoneCtrls.removeAt(e.key)),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                    TextButton.icon(
                      onPressed: () => setState(() => _ownerPhoneCtrls.add(TextEditingController())),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Phone Number'),
                    ),
                    const SizedBox(height: 16),
                    _buildField('Broker Details', _brokerCtrl, maxLines: 2),
                    const SizedBox(height: 16),
                    _buildField('Care Of', _careOfCtrl),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Detailed Specifications'),
                    _buildField('Floor Level', _floorCtrl),
                    SwitchListTile(
                      title: const Text('Has Balcony', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasBalcony,
                      onChanged: (val) => setState(() => _hasBalcony = val),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.primaryColor,
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
                      activeColor: AppTheme.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Has Car Parking', style: TextStyle(color: AppTheme.mutedTextColor)),
                      value: _hasCarParking,
                      onChanged: (val) => setState(() => _hasCarParking = val),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.primaryColor,
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
                      }).toList(),
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
          value: value,
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
