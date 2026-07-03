import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import '../theme.dart';
import '../widgets/premium_app_bar.dart';
import '../services/supabase_backup_service.dart';

class ContactBookScreen extends StatefulWidget {
  const ContactBookScreen({super.key});

  @override
  State<ContactBookScreen> createState() => _ContactBookScreenState();
}

class _ContactBookScreenState extends State<ContactBookScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      const graphQLDocument = '''
        query ListContacts {
          listContacts(limit: 1000) {
            items {
              id
              name
              designation
              office
              personal_number
              official_number
              email
              place
              native_place
              working_place
            }
          }
        }
      ''';
      
      final req = GraphQLRequest<String>(document: graphQLDocument);
      final res = await Amplify.API.query(request: req).response;
      
      if (res.errors.isNotEmpty) {
        debugPrint('GraphQL errors: ${res.errors}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'GraphQL Error: ${res.errors.first.message}';
          });
        }
        return;
      }
      
      if (res.data != null) {
        final data = json.decode(res.data!);
        final listContacts = data['listContacts'];
        
        if (listContacts == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Contacts table not found. Is the backend synced?';
            });
          }
          return;
        }

        final items = (listContacts['items'] as List?) ?? [];
        
        items.sort((a, b) => (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''));
        
        if (mounted) {
          setState(() {
            _contacts = items;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; _errorMessage = 'No data returned'; });
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      if (mounted) {
        setState(() {
          if (e.toString().contains('FieldUndefined')) {
            _errorMessage = 'The Contacts database table is currently being deployed to the cloud. Please wait a few minutes and refresh.';
          } else {
            _errorMessage = 'Failed to load contacts: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteContact(dynamic contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text('Are you sure you want to delete ${contact['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final id = contact['id'];
      final graphQLDocument = '''
        mutation DeleteContact {
          deleteContacts(input: {id: "$id"}) {
            id
          }
        }
      ''';
      final req = GraphQLRequest<String>(document: graphQLDocument);
      final res = await Amplify.API.mutate(request: req).response;
      
      if (res.errors.isNotEmpty) {
        throw Exception('GraphQL Error: ${res.errors.first.message}');
      }
      
      SupabaseBackupService().deleteRecord('Contacts', id);
      
      _fetchContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Error deleting contact: $e');
    }
  }

  void _showContactDialog([dynamic contact]) {
    showDialog(
      context: context,
      builder: (_) => _ContactDialog(
        contact: contact,
        onSave: () => _fetchContacts(),
      ),
    );
  }

  List<dynamic> get _filteredContacts {
    return _contacts.where((c) {
      final searchFields = [
        c['name'], c['designation'], c['office'], 
        c['personal_number'], c['official_number'], c['email']
      ];
      return searchFields.any((f) => (f?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const PremiumAppBar(title: Text('Contact Book')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : _filteredContacts.isEmpty 
                      ? const Center(child: Text('No contacts found', style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 16)))
                      : _buildContactsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Book', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            SizedBox(height: 4),
            Text('Manage external contacts and associates', style: TextStyle(color: AppTheme.mutedTextColor)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showContactDialog(),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Contact'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.surfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search contacts...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.mutedTextColor),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildContactsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3 / 1.7, // Adjust height
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = _filteredContacts[index];
            return _buildContactCard(contact).animate().fade().slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 50 * index));
          },
        );
      },
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    final int hash = name.codeUnitAt(0);
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.indigo, Colors.pink];
    return colors[hash % colors.length];
  }

  Widget _buildContactCard(dynamic contact) {
    final name = contact['name']?.toString() ?? 'Unknown';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    final avatarColor = _getAvatarColor(name);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: avatarColor.withOpacity(0.1),
                        foregroundColor: avatarColor,
                        child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            if (contact['designation'] != null && contact['designation'].toString().isNotEmpty)
                              Text(contact['designation']!, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.mutedTextColor),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') _showContactDialog(contact);
                    if (val == 'delete') _deleteContact(contact);
                  },
                ),
              ],
            ),
            const Spacer(),
            if (contact['official_number'] != null && contact['official_number'].toString().isNotEmpty)
              _infoRow(Icons.phone_in_talk_rounded, 'Official: ${contact['official_number']}'),
            if (contact['personal_number'] != null && contact['personal_number'].toString().isNotEmpty)
              _infoRow(Icons.phone_android_rounded, 'Personal: ${contact['personal_number']}'),
            if (contact['email'] != null && contact['email'].toString().isNotEmpty)
              _infoRow(Icons.email_outlined, contact['email']!),
            if (contact['office'] != null && contact['office'].toString().isNotEmpty)
              _infoRow(Icons.business_rounded, contact['office']!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.mutedTextColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final dynamic contact;
  final VoidCallback onSave;

  const _ContactDialog({this.contact, required this.onSave});

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _officeController = TextEditingController();
  final _personalNumberController = TextEditingController();
  final _officialNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _placeController = TextEditingController();
  final _nativePlaceController = TextEditingController();
  final _workingPlaceController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name'] ?? '';
      _designationController.text = widget.contact!['designation'] ?? '';
      _officeController.text = widget.contact!['office'] ?? '';
      _personalNumberController.text = widget.contact!['personal_number'] ?? '';
      _officialNumberController.text = widget.contact!['official_number'] ?? '';
      _emailController.text = widget.contact!['email'] ?? '';
      _placeController.text = widget.contact!['place'] ?? '';
      _nativePlaceController.text = widget.contact!['native_place'] ?? '';
      _workingPlaceController.text = widget.contact!['working_place'] ?? '';
    }
  }

  Future<void> _saveContact() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().toIso8601String();
      
      String escape(String text) => text.replaceAll('"', '\\"');
      
      final nameStr = escape(_nameController.text.trim());
      final desigStr = escape(_designationController.text.trim());
      final officeStr = escape(_officeController.text.trim());
      final personalStr = escape(_personalNumberController.text.trim());
      final officialStr = escape(_officialNumberController.text.trim());
      final emailStr = escape(_emailController.text.trim());
      final placeStr = escape(_placeController.text.trim());
      final nativeStr = escape(_nativePlaceController.text.trim());
      final workingStr = escape(_workingPlaceController.text.trim());

      if (widget.contact == null) {
        final graphQLDocument = '''
          mutation CreateContact {
            createContacts(input: {
              name: "$nameStr",
              designation: "$desigStr",
              office: "$officeStr",
              personal_number: "$personalStr",
              official_number: "$officialStr",
              email: "$emailStr",
              place: "$placeStr",
              native_place: "$nativeStr",
              working_place: "$workingStr",
              created_at: "$now"
            }) {
              id
            }
          }
        ''';
        final req = GraphQLRequest<String>(document: graphQLDocument);
        final res = await Amplify.API.mutate(request: req).response;
        if (res.errors.isNotEmpty) {
          throw Exception(res.errors.first.message);
        }
      } else {
        final id = widget.contact['id'];
        final graphQLDocument = '''
          mutation UpdateContact {
            updateContacts(input: {
              id: "$id",
              name: "$nameStr",
              designation: "$desigStr",
              office: "$officeStr",
              personal_number: "$personalStr",
              official_number: "$officialStr",
              email: "$emailStr",
              place: "$placeStr",
              native_place: "$nativeStr",
              working_place: "$workingStr"
            }) {
              id
            }
          }
        ''';
        final req = GraphQLRequest<String>(document: graphQLDocument);
        final res = await Amplify.API.mutate(request: req).response;
        if (res.errors.isNotEmpty) {
          throw Exception(res.errors.first.message);
        }
      }
      
      // Attempt to read the new ID or use the existing one
      // If we don't know the new ID from the mutate response, we can just backup what we have and let Supabase auto-assign an ID.
      final backupData = {
        'id': widget.contact?['id'],
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'office': _officeController.text.trim(),
        'personal_number': _personalNumberController.text.trim(),
        'official_number': _officialNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'place': _placeController.text.trim(),
        'native_place': _nativePlaceController.text.trim(),
        'working_place': _workingPlaceController.text.trim(),
        'created_at': now,
      };
      SupabaseBackupService().backupRecord('Contacts', backupData);
      
      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(widget.contact == null ? 'Add Contact' : 'Edit Contact', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField('Name *', _nameController, Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField('Designation', _designationController, Icons.badge),
                    const SizedBox(height: 16),
                    _buildTextField('Office', _officeController, Icons.business),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Personal Number', _personalNumberController, Icons.phone_android)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Official Number', _officialNumberController, Icons.phone_in_talk)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Email', _emailController, Icons.email),
                    const SizedBox(height: 16),
                    _buildTextField('Place', _placeController, Icons.location_city),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Native Place', _nativePlaceController, Icons.home)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Working Place', _workingPlaceController, Icons.work)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.surfaceColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.surfaceColor, strokeWidth: 2)) : const Text('Save Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
      ),
    );
  }
}
