import 'package:amplify_api/amplify_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/ModelProvider.dart';
import '../theme.dart';

class SopScreen extends StatefulWidget {
  const SopScreen({super.key});

  @override
  State<SopScreen> createState() => _SopScreenState();
}

class _SopScreenState extends State<SopScreen> {
  bool _isLoading = true;
  List<ServiceContent> _sops = [];
  List<ServiceContent> _filteredSops = [];
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  static const int _sopServiceId = 999999; // Identifier for SOPs

  @override
  void initState() {
    super.initState();
    _fetchSops();
    _searchController.addListener(_filterSops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSops = List.from(_sops);
      } else {
        _filteredSops = _sops.where((sop) {
          final title = sop.title?.toLowerCase() ?? '';
          final desc = sop.description?.toLowerCase() ?? '';
          final details = sop.details?.toLowerCase() ?? '';
          return title.contains(query) || desc.contains(query) || details.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchSops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final req = ModelQueries.list(
        ServiceContent.classType,
        where: ServiceContent.SERVICE_ID.eq(_sopServiceId),
      );
      final res = await Amplify.API.query(request: req).response;
      if (res.hasErrors) {
        throw Exception(res.errors.first.message);
      }
      final sopsList = (res.data?.items ?? []).whereType<ServiceContent>().toList();
      sopsList.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      if (mounted) {
        setState(() {
          _sops = sopsList;
          _filteredSops = List.from(sopsList);
          _isLoading = false;
        });
        _filterSops();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSop(ServiceContent sop) async {
    try {
      final req = ModelMutations.delete(sop);
      await Amplify.API.mutate(request: req).response;
      _fetchSops();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red.shade800,
        ));
      }
    }
  }

  void _showAddEditSopDialog([ServiceContent? sop]) {
    final titleController = TextEditingController(text: sop?.title);
    final descController = TextEditingController(text: sop?.description);
    final contentController = TextEditingController(text: sop?.details);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 20,
              backgroundColor: AppTheme.backgroundColor,
              child: Container(
                width: 650,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sop == null ? Icons.post_add_rounded : Icons.edit_document,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          sop == null ? 'Create New SOP' : 'Edit SOP',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: titleController,
                      label: 'SOP Title',
                      hint: 'e.g. Employee Onboarding Process',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: descController,
                      label: 'Short Description',
                      hint: 'Brief summary of what this SOP covers...',
                      icon: Icons.short_text,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: contentController,
                      label: 'Detailed Content',
                      hint: 'Step-by-step procedure...',
                      icon: Icons.subject_rounded,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            foregroundColor: AppTheme.mutedTextColor,
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (titleController.text.trim().isEmpty) return;
                                  setDialogState(() => isSaving = true);
                                  try {
                                    final newSop = ServiceContent(
                                      id: sop?.id ?? UUID.getUUID(),
                                      service_id: _sopServiceId,
                                      title: titleController.text.trim(),
                                      description: descController.text.trim(),
                                      details: contentController.text.trim(),
                                    );

                                    final req = sop == null
                                        ? ModelMutations.create(newSop)
                                        : ModelMutations.update(newSop);

                                    await Amplify.API.mutate(request: req).response;
                                    if (mounted) {
                                      Navigator.pop(context);
                                      _fetchSops();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red.shade800,
                                      ));
                                    }
                                  } finally {
                                    if (mounted) setDialogState(() => isSaving = false);
                                  }
                                },
                          icon: isSaving 
                              ? const SizedBox(
                                  width: 18, 
                                  height: 18, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : const Icon(Icons.check_circle_outline_rounded, size: 20),
                          label: Text(
                            isSaving ? 'Saving...' : 'Save SOP',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.95, 0.95), 
              end: const Offset(1, 1), 
              curve: Curves.easeOutCubic, 
              duration: 300.ms,
            ).fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.notoSansMalayalam(
        textStyle: const TextStyle(),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.mutedTextColor.withValues(alpha: 0.5)),
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.primaryColor.withValues(alpha: 0.7)) : null,
        filled: true,
        fillColor: AppTheme.surfaceColor,
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
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  void _confirmDelete(ServiceContent sop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete SOP?'),
        content: Text('Are you sure you want to delete "${sop.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSop(sop);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Standard Operating Procedures',
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: -0.5,
                        color: AppTheme.textColor,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage and view all internal company procedures',
                      style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 15),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditSopDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create SOP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search SOPs by title, description, or content...',
                  hintStyle: TextStyle(color: AppTheme.mutedTextColor.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.mutedTextColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.mutedTextColor),
                          onPressed: () {
                            _searchController.clear();
                          },
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
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text('Failed to load data: $_error', style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        )
                      : _filteredSops.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No SOPs found',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Try adjusting your search or click "Create SOP".',
                                    style: TextStyle(color: AppTheme.mutedTextColor),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms)
                          : ListView.separated(
                              itemCount: _filteredSops.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                final sop = _filteredSops[index];
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor),
                                      ),
                                      title: Text(
                                        sop.title ?? 'Untitled',
                                        style: GoogleFonts.notoSansMalayalam(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                                      ),
                                      subtitle: (sop.description != null && sop.description!.isNotEmpty)
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                sop.description!,
                                                style: GoogleFonts.notoSansMalayalam(textStyle: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 14)),
                                              ),
                                            )
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                                            tooltip: 'Edit',
                                            onPressed: () => _showAddEditSopDialog(sop),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
                                            tooltip: 'Delete',
                                            onPressed: () => _confirmDelete(sop),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                        ],
                                      ),
                                      children: [
                                        if (sop.details != null && sop.details!.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceColor,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Text(
                                              sop.details!,
                                              style: GoogleFonts.notoSansMalayalam(
                                                textStyle: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.6,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
