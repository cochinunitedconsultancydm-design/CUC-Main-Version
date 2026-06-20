import re
import codecs

with codecs.open("d:/Cochin United/Cochin United/CUC Main Version/lib/screens/deal_detail_screen.dart", "r", "utf-8") as f:
    content = f.read()

start_marker = "  void _openDriveLink() async {"
end_marker = "  Widget _buildUnifiedActivityPanel() {"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("Markers not found", start_idx, end_idx)
    exit(1)

new_methods = """  void _openDriveLink() {
    _showDocsListDialog();
  }

  void _showDocsListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 500,
                height: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Connected Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 28),
                          onPressed: () {
                            _showGoogleDocsConnectDialog(setDialogState);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _connectedDocs.isEmpty
                          ? const Center(child: Text('No documents connected yet.', style: TextStyle(color: AppTheme.mutedTextColor)))
                          : ListView.builder(
                              itemCount: _connectedDocs.length,
                              itemBuilder: (context, index) {
                                final doc = _connectedDocs[index];
                                return Card(
                                  elevation: 0,
                                  color: AppTheme.primaryColor.withOpacity(0.05),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                                  child: ListTile(
                                    leading: const Icon(Icons.description_rounded, color: Colors.blueAccent),
                                    title: Text(doc['name'] ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                                      onPressed: () async {
                                        setDialogState(() {
                                          _connectedDocs.removeAt(index);
                                        });
                                        setState(() {});
                                        _driveLinkController.text = jsonEncode(_connectedDocs);
                                        await _saveDeal();
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GoogleDocsWebviewScreen(url: doc['url']!, title: doc['name']!),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE', style: TextStyle(color: AppTheme.mutedTextColor)),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _showGoogleDocsConnectDialog(StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner_rounded, size: 32, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                const Text('Connect Google Doc', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor, fontFamily: 'Montserrat')),
                const SizedBox(height: 8),
                const Text('Create a new document or link an existing one from your Google Docs Vault.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.mutedTextColor, fontFamily: 'Montserrat')),
                const SizedBox(height: 32),
                
                // Option 1: Create New
                Opacity(
                  opacity: _clientController.text.trim().isEmpty ? 0.5 : 1.0,
                  child: _buildDocOption(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Create New Document',
                    subtitle: _clientController.text.trim().isEmpty ? 'Please select a Client first' : 'Automatically connects to this Work',
                    onTap: () async {
                      if (_clientController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Client before creating a new document.', style: TextStyle(fontFamily: 'Montserrat'))));
                        return;
                      }
                      Navigator.pop(context);
                      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                      final docName = _nameController.text.trim().isNotEmpty ? '${_nameController.text.trim()} Doc' : 'New Work Doc';
                      final url = await GoogleDocsService.createNewDocument(docName);
                      if (context.mounted) Navigator.pop(context); // hide loading
                      if (url != null) {
                        parentSetState(() {
                          _connectedDocs.add({"name": docName, "url": url});
                        });
                        setState(() {});
                        _driveLinkController.text = jsonEncode(_connectedDocs);
                        await _saveDeal();
                      } else {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create document.')));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                
                // Option 2: Select Existing
                _buildDocOption(
                  icon: Icons.folder_open_rounded,
                  title: 'Select from Vault',
                  subtitle: 'Pick an existing Google Doc',
                  onTap: () {
                    Navigator.pop(context);
                    _showVaultSelectionDialog(parentSetState);
                  },
                ),
                const SizedBox(height: 12),
                
                // Option 3: Paste Manually
                _buildDocOption(
                  icon: Icons.link_rounded,
                  title: 'Paste Link Manually',
                  subtitle: 'Paste any external document URL',
                  onTap: () {
                    Navigator.pop(context);
                    _showManualPasteDialog(parentSetState);
                  },
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppTheme.mutedTextColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDocOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedTextColor)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.mutedTextColor),
          ],
        ),
      ),
    );
  }

  void _showManualPasteDialog(StateSetter parentSetState) {
    final TextEditingController tempLinkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Paste Link', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        content: TextField(
          controller: tempLinkController,
          decoration: InputDecoration(
            hintText: 'https://docs.google.com/...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.mutedTextColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tempLinkController.text.trim().isEmpty) return;
              Navigator.pop(context);
              parentSetState(() {
                _connectedDocs.add({"name": "Connected Document", "url": tempLinkController.text.trim()});
              });
              setState(() {});
              _driveLinkController.text = jsonEncode(_connectedDocs);
              await _saveDeal();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ADD & SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showVaultSelectionDialog(StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Select Document', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<drive.File>>(
                  future: GoogleDocsService.getDriveFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No documents found in Vault.'));
                    }
                    final docs = snapshot.data!;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return Card(
                          elevation: 0,
                          color: AppTheme.primaryColor.withOpacity(0.03),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            leading: const Icon(Icons.description, color: Colors.blueAccent),
                            title: Text(doc.name ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                            subtitle: Text('Modified: ${doc.modifiedTime?.toLocal().toString().split('.')[0] ?? ''}', style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
                            onTap: () async {
                              Navigator.pop(context);
                              parentSetState(() {
                                _connectedDocs.add({"name": doc.name ?? 'Untitled', "url": doc.webViewLink ?? ''});
                              });
                              setState(() {});
                              _driveLinkController.text = jsonEncode(_connectedDocs);
                              await _saveDeal();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: AppTheme.mutedTextColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

"""

new_content = content[:start_idx] + new_methods + content[end_idx:]

with codecs.open("d:/Cochin United/Cochin United/CUC Main Version/lib/screens/deal_detail_screen.dart", "w", "utf-8") as f:
    f.write(new_content)

print("Replaced successfully")
