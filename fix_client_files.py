import re

with open(r'f:\CUC Main Version\lib\screens\client_files_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _sortOption
if "String _sortOption" not in content:
    content = re.sub(
        r'(class _ClientFilesScreenState extends State<ClientFilesScreen> \{)',
        r"\1\n  String _sortOption = 'Newest First';",
        content
    )

# 2. Update _filterWorkFiles
old_filter = '''  void _filterWorkFiles(String query) {
    if (query.isEmpty) {
      setState(() => _filtered = _workFiles);
      return;
    }
    
    final lower = query.toLowerCase();
    setState(() {
      _filtered = _workFiles.where((w) => 
        (w.name?.toLowerCase().contains(lower) ?? false) || 
        (w.client_name?.toLowerCase().contains(lower) ?? false)
      ).toList();
    });
  }'''

new_filter = '''  void _applyFilterAndSort() {
    List<amplify_models.Deals> list = List.from(_workFiles);

    if (_sortOption == 'Legal Only') {
      list = list.where((w) => (w.work_type ?? '').toLowerCase().contains('legal')).toList();
    } else if (_sortOption == 'Consultancy Only') {
      list = list.where((w) => (w.work_type ?? '').toLowerCase().contains('consultancy')).toList();
    }

    final lower = _searchController.text.toLowerCase();
    if (lower.isNotEmpty) {
      list = list.where((w) => 
        (w.name?.toLowerCase().contains(lower) ?? false) || 
        (w.client_name?.toLowerCase().contains(lower) ?? false)
      ).toList();
    }

    if (_sortOption == 'Newest First' || _sortOption == 'Legal Only' || _sortOption == 'Consultancy Only') {
      list.sort((a, b) => (b.createdAt?.getDateTimeInUtc() ?? DateTime(2000)).compareTo(a.createdAt?.getDateTimeInUtc() ?? DateTime(2000)));
    } else if (_sortOption == 'Oldest First') {
      list.sort((a, b) => (a.createdAt?.getDateTimeInUtc() ?? DateTime(2000)).compareTo(b.createdAt?.getDateTimeInUtc() ?? DateTime(2000)));
    } else if (_sortOption == 'A-Z') {
      list.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    } else if (_sortOption == 'Z-A') {
      list.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
    } else if (_sortOption == 'Highest Amount') {
      list.sort((a, b) => (b.amount ?? 0.0).compareTo(a.amount ?? 0.0));
    } else if (_sortOption == 'Lowest Amount') {
      list.sort((a, b) => (a.amount ?? 0.0).compareTo(b.amount ?? 0.0));
    } else if (_sortOption == 'Invoice No (A-Z)') {
      list.sort((a, b) => (a.register_no ?? '').compareTo(b.register_no ?? ''));
    } else if (_sortOption == 'Invoice No (Z-A)') {
      list.sort((a, b) => (b.register_no ?? '').compareTo(a.register_no ?? ''));
    }

    setState(() {
      _filtered = list;
    });
  }

  void _filterWorkFiles(String query) {
    _applyFilterAndSort();
  }'''

content = content.replace(old_filter, new_filter)

# 3. Add Dropdown UI
dropdown_ui = '''                  Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterWorkFiles,
                      decoration: const InputDecoration(
                        hintText: 'Search work files by name or client...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor),
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortOption = newValue;
                          });
                          _applyFilterAndSort();
                        }
                      },
                      items: <String>[
                        'Newest First', 'Oldest First', 'A-Z', 'Z-A', 
                        'Highest Amount', 'Lowest Amount', 
                        'Invoice No (A-Z)', 'Invoice No (Z-A)',
                        'Legal Only', 'Consultancy Only'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),'''

content = re.sub(
    r'''                  Expanded\(\s*child: Container\(\s*decoration: BoxDecoration\(\s*color: Colors\.white,\s*borderRadius: BorderRadius\.circular\(16\),\s*boxShadow: \[BoxShadow\(color: Colors\.black\.withValues\(alpha: 0\.05\), blurRadius: 10\)\],\s*\),\s*child: TextField\(\s*controller: _searchController,\s*onChanged: _filterWorkFiles,\s*decoration: const InputDecoration\(\s*hintText: 'Search work files by name or client\.\.\.',\s*prefixIcon: Icon\(Icons\.search_rounded\),\s*border: InputBorder\.none,\s*contentPadding: EdgeInsets\.symmetric\(horizontal: 16, vertical: 16\),\s*\),\s*\),\s*\),\s*\),''',
    dropdown_ui,
    content
)

with open(r'f:\CUC Main Version\lib\screens\client_files_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
