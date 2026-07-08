import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';
import '../models/OfficeLocations.dart';
import '../services/office_location_service.dart';

class AddOfficeLocationScreen extends StatefulWidget {
  final OfficeLocations? existingLocation;
  const AddOfficeLocationScreen({super.key, this.existingLocation});

  @override
  State<AddOfficeLocationScreen> createState() => _AddOfficeLocationScreenState();
}

class _AddOfficeLocationScreenState extends State<AddOfficeLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _linkController = TextEditingController();
  List<Map<String, String>> _officePhones = [];
  final _officePhoneDesigController = TextEditingController();
  final _officePhoneNumController = TextEditingController();
  
  List<File> _frontViewPhotos = [];
  List<File> _designationBoards = [];
  List<File> _noticeBoards = [];
  List<File> _otherPhotos = [];
  
  List<Map<String, String>> _officers = [];
  final _officerNameController = TextEditingController();
  final _officerDesigController = TextEditingController();
  final _officerPhoneController = TextEditingController();

  bool _isLoading = false;
  final OfficeLocationService _service = OfficeLocationService();

  // For retaining old photos
  String? _existingFrontViews;
  String? _existingDesignations;
  String? _existingNotices;
  String? _existingOthers;

  @override
  void initState() {
    super.initState();
    if (widget.existingLocation != null) {
      final loc = widget.existingLocation!;
      _nameController.text = loc.name ?? '';
      _placeController.text = loc.place ?? '';
      _linkController.text = loc.location_link ?? '';
      
      if (loc.office_phone_numbers != null && loc.office_phone_numbers!.isNotEmpty) {
        try {
          final List list = jsonDecode(loc.office_phone_numbers!);
          _officePhones = list.map((e) => Map<String, String>.from(e)).toList();
        } catch (_) {}
      }
      
      if (loc.officers_contacts != null && loc.officers_contacts!.isNotEmpty) {
        try {
          final List list = jsonDecode(loc.officers_contacts!);
          _officers = list.map((e) => Map<String, String>.from(e)).toList();
        } catch (_) {}
      }

      _existingFrontViews = loc.front_view_photo;
      _existingDesignations = loc.designation_boards_photos;
      _existingNotices = loc.notice_boards_photos;
      _existingOthers = loc.other_photos;
    }
  }

  Future<void> _pickMultipleImages(List<File> targetList) async {
    final result = await FilePicker.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null) {
      setState(() {
        targetList.addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
    }
  }

  void _addOfficePhone() {
    if (_officePhoneDesigController.text.isNotEmpty && _officePhoneNumController.text.isNotEmpty) {
      setState(() {
        _officePhones.add({
          'designation': _officePhoneDesigController.text.trim(),
          'phone': _officePhoneNumController.text.trim(),
        });
        _officePhoneDesigController.clear();
        _officePhoneNumController.clear();
      });
    }
  }

  void _addOfficer() {
    if (_officerNameController.text.isNotEmpty && _officerPhoneController.text.isNotEmpty) {
      setState(() {
        _officers.add({
          'name': _officerNameController.text.trim(),
          'designation': _officerDesigController.text.trim(),
          'phone': _officerPhoneController.text.trim(),
        });
        _officerNameController.clear();
        _officerDesigController.clear();
        _officerPhoneController.clear();
      });
    }
  }

  List<String> _combinePhotos(String? existingJson, List<String> newPaths) {
    List<String> combined = [];
    if (existingJson != null && existingJson.isNotEmpty) {
       try {
         final List list = jsonDecode(existingJson);
         // Filter out corrupted paths that were uploaded from Windows with C:/ before the fix
         final validPaths = list.cast<String>().where((p) => !p.contains('C:/') && !p.contains('C:\\')).toList();
         combined.addAll(validPaths);
       } catch (_) {}
    }
    combined.addAll(newPaths);
    return combined;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      List<String> frontViewPaths = [];
      for (var file in _frontViewPhotos) {
        final p = await _service.uploadImage(file, 'public/office_locations/front_views');
        if (p != null) frontViewPaths.add(p);
      }

      List<String> designationPaths = [];
      for (var file in _designationBoards) {
        final p = await _service.uploadImage(file, 'public/office_locations/designation_boards');
        if (p != null) designationPaths.add(p);
      }

      List<String> noticePaths = [];
      for (var file in _noticeBoards) {
        final p = await _service.uploadImage(file, 'public/office_locations/notice_boards');
        if (p != null) noticePaths.add(p);
      }

      List<String> otherPaths = [];
      for (var file in _otherPhotos) {
        final p = await _service.uploadImage(file, 'public/office_locations/other_photos');
        if (p != null) otherPaths.add(p);
      }

      final isEditing = widget.existingLocation != null;
      final location = OfficeLocations(
        id: isEditing ? widget.existingLocation!.id : null,
        name: _nameController.text.trim(),
        place: _placeController.text.trim(),
        location_link: _linkController.text.trim(),
        office_phone_numbers: jsonEncode(_officePhones),
        front_view_photo: jsonEncode(_combinePhotos(_existingFrontViews, frontViewPaths)),
        designation_boards_photos: jsonEncode(_combinePhotos(_existingDesignations, designationPaths)),
        notice_boards_photos: jsonEncode(_combinePhotos(_existingNotices, noticePaths)),
        officers_contacts: jsonEncode(_officers),
        other_photos: jsonEncode(_combinePhotos(_existingOthers, otherPaths)),
      );

      final success = isEditing ? await _service.updateLocation(location) : await _service.createLocation(location);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Office Location updated successfully!' : 'Office Location saved successfully!')));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save office location.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Premium light gray background
      appBar: AppBar(
        title: const Text('Add Office Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCard(
                          icon: Icons.business,
                          title: 'Basic Details',
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Name of Office',
                                icon: Icons.badge_outlined,
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _placeController,
                                label: 'Place',
                                icon: Icons.location_city_outlined,
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _linkController,
                                label: 'Location Link (Google Maps etc.)',
                                icon: Icons.map_outlined,
                                isRequired: false,
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(height: 24),
                              if (_officePhones.isNotEmpty)
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _officePhones.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final phone = _officePhones[index];
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, color: AppTheme.primaryColor, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(phone['designation']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                                          Text(phone['phone']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 12),
                                          InkWell(onTap: () => setState(() => _officePhones.removeAt(index)), child: const Icon(Icons.close, color: Colors.red, size: 20)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              if (_officePhones.isNotEmpty) const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('Add Office Phone Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField(controller: _officePhoneDesigController, label: 'Designation (e.g. Front Desk)', icon: Icons.badge_outlined, isRequired: false)),
                                        const SizedBox(width: 12),
                                        Expanded(child: _buildTextField(controller: _officePhoneNumController, label: 'Phone Number', icon: Icons.phone_outlined, isRequired: false)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: _addOfficePhone,
                                      icon: const Icon(Icons.add_circle_outline),
                                      label: const Text('Add Phone Number'),
                                      style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Office Photos',
                          child: Column(
                            children: [
                              _buildImageUploader('Front View of Office', _frontViewPhotos, () => _pickMultipleImages(_frontViewPhotos), Icons.storefront),
                              const SizedBox(height: 20),
                              _buildImageUploader('Designation Boards', _designationBoards, () => _pickMultipleImages(_designationBoards), Icons.branding_watermark_outlined),
                              const SizedBox(height: 20),
                              _buildImageUploader('Notice Boards', _noticeBoards, () => _pickMultipleImages(_noticeBoards), Icons.assignment_outlined),
                              const SizedBox(height: 20),
                              _buildImageUploader('Other Photos', _otherPhotos, () => _pickMultipleImages(_otherPhotos), Icons.collections_outlined),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCard(
                          icon: Icons.contact_phone_outlined,
                          title: 'Officers & Contacts',
                          child: Column(
                            children: [
                              if (_officers.isNotEmpty)
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _officers.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final officer = _officers[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        child: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      ),
                                      title: Text(officer['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${officer['designation']} • ${officer['phone']}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                        onPressed: () => setState(() => _officers.removeAt(index)),
                                      ),
                                    );
                                  },
                                ),
                              if (_officers.isNotEmpty) const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('Add New Contact', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField(controller: _officerNameController, label: 'Officer Name', icon: Icons.person_outline, isRequired: false)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField(controller: _officerDesigController, label: 'Designation', icon: Icons.work_outline, isRequired: false)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(controller: _officerPhoneController, label: 'Phone Number', icon: Icons.phone_outlined, isRequired: false),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primaryColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: const BorderSide(color: AppTheme.primaryColor),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: _addOfficer,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitForm,
                          child: const Text('Save Office Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08), 
            blurRadius: 24, 
            spreadRadius: 0,
            offset: const Offset(0, 12)
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.primaryColor.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 26),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required bool isRequired}) {
    return TextFormField(
      controller: controller,
      validator: isRequired ? (val) => (val == null || val.isEmpty) ? 'Required' : null : null,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)
        ),
      ),
    );
  }

  Widget _buildImageUploader(String label, List<File> files, VoidCallback onPick, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 12),
        if (files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: files.map((f) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(f, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (label.contains('Front View')) _frontViewPhotos.remove(f);
                                else files.remove(f);
                              });
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ),
                        ),
                      )
                    ],
                  )).toList(),
            ),
          ),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.5), size: 32),
                const SizedBox(height: 8),
                Text('Tap to select ${label.toLowerCase()}', style: TextStyle(color: AppTheme.primaryColor.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

