import re
import codecs

with codecs.open("d:/Cochin United/Cochin United/CUC Main Version/lib/screens/deal_detail_screen.dart", "r", "utf-8") as f:
    content = f.read()

# 1. Remove _draftLinkController from initialization and dispose
content = content.replace("      _draftLinkController = TextEditingController(text: parsedVer.draftLink ?? '');\n", "")
content = content.replace("      _draftLinkController = TextEditingController();\n", "")
content = content.replace("      _draftLinkController.dispose();\n", "")

# 2. Modify _updateVerification to stop writing DraftLink to the string block
content = content.replace("""        if (verifierId != null && verifierName != null) {
          final dLink = draftLink ?? _draftLinkController.text.trim();
          final linkLine = dLink.isNotEmpty ? "\\nDraftLink: $dLink" : "";
          block = "\\n\\n[VERIFICATION]\\nVerifierID: $verifierId\\nVerifierName: $verifierName\\nStatus: $status$linkLine";
        }""", """        if (verifierId != null && verifierName != null) {
          block = "\\n\\n[VERIFICATION]\\nVerifierID: $verifierId\\nVerifierName: $verifierName\\nStatus: $status";
        }""")

# 3. Modify _completeWorkAndShareDraft to stop writing DraftLink
content = content.replace("""      try {
        final cleanDesc = _descriptionController.text.trim();
        final dLink = _draftLinkController.text.trim();
        String newDesc = cleanDesc;

        if (_selectedVerifierId != null) {
          final vUser = _allUsers.firstWhere((u) => u['id'] as int == _selectedVerifierId);
          final vName = vUser['name'].toString();
          final linkLine = dLink.isNotEmpty ? "\\nDraftLink: $dLink" : "";
          newDesc = "$cleanDesc\\n\\n[VERIFICATION]\\nVerifierID: $_selectedVerifierId\\nVerifierName: $vName\\nStatus: Draft$linkLine";
        }""", """      try {
        final cleanDesc = _descriptionController.text.trim();
        String newDesc = cleanDesc;

        if (_selectedVerifierId != null) {
          final vUser = _allUsers.firstWhere((u) => u['id'] as int == _selectedVerifierId);
          final vName = vUser['name'].toString();
          newDesc = "$cleanDesc\\n\\n[VERIFICATION]\\nVerifierID: $_selectedVerifierId\\nVerifierName: $vName\\nStatus: Draft";
        }""")

# 4. Add _buildConnectedDocsSection()
docs_section = """  Widget _buildConnectedDocsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Connected Documents',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569)),
            ),
            IconButton(
              onPressed: () => _showGoogleDocsConnectDialog((_) => setState(() {})),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_connectedDocs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text('No documents connected yet', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _connectedDocs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, index) {
                final doc = _connectedDocs[index];
                return ListTile(
                  leading: const Icon(Icons.description_rounded, color: Colors.blueAccent, size: 20),
                  title: Text(doc['name'] ?? 'Document', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  dense: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 16),
                    onPressed: () async {
                      setState(() {
                        _connectedDocs.removeAt(index);
                      });
                      _driveLinkController.text = import_json.jsonEncode(_connectedDocs);
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
                );
              },
            ),
          ),
      ],
    );
  }

"""

if "_buildConnectedDocsSection()" not in content:
    idx = content.find("  Widget _buildUnifiedActivityPanel() {")
    content = content[:idx] + docs_section + content[idx:]
    
    # We also need to import json if it's not already, wait it is imported as jsonDecode/jsonEncode. 
    # Actually `jsonEncode` is enough, let's fix the import_json in the text
    content = content.replace("import_json.jsonEncode", "jsonEncode")


# 5. Replace UI elements
# Instead of Regex, let's just find the exact blocks.
# Block 1: "Work Draft Link (Optional)" TextField block
# There are two of these blocks. We'll replace both.

tf_block_pattern = r"const SizedBox\(height: 16\),\s*const Text\(\s*'Work Draft Link \(Optional\)',\s*style: TextStyle\(fontWeight: FontWeight.w600, fontSize: 13, color: Color\(0xFF475569\)\),\s*\),\s*const SizedBox\(height: 8\),\s*TextField\(\s*controller: _draftLinkController,\s*keyboardType: TextInputType.url,[\s\S]*?enabledBorder: OutlineInputBorder\([\s\S]*?borderSide: const BorderSide\(color: Color\(0xFFE2E8F0\)\),\s*\),\s*\),\s*\),"

content = re.sub(tf_block_pattern, "const SizedBox(height: 16),\n                                      _buildConnectedDocsSection(),\n", content)

# Block 2: Read-only block
readonly_pattern = r"Row\(\s*children: \[\s*const Icon\(Icons.link_rounded, color: Color\(0xFF6366F1\), size: 20\),\s*const SizedBox\(width: 8\),\s*const Text\(\s*'Work Draft Link',\s*style: TextStyle\(\s*fontWeight: FontWeight.bold,\s*fontSize: 13,\s*color: Color\(0xFF1E293B\),\s*\),\s*\),\s*\],\s*\),\s*const SizedBox\(height: 8\),\s*Row\(\s*children: \[\s*Expanded\(\s*child: Container\([\s\S]*?child: Text\(\s*_draftLinkController\.text,\s*style: const TextStyle\(\s*color: Color\(0xFF2563EB\),\s*fontSize: 13,\s*decoration: TextDecoration.underline,\s*\),\s*\),\s*\),\s*\),\s*\],\s*\),"

content = re.sub(readonly_pattern, "_buildConnectedDocsSection(),", content)

with codecs.open("d:/Cochin United/Cochin United/CUC Main Version/lib/screens/deal_detail_screen.dart", "w", "utf-8") as f:
    f.write(content)

print("Replacement complete.")
