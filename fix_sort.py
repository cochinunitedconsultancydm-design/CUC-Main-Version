import re

with open(r'f:\CUC Main Version\lib\screens\work_management_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace dropdown items
content = content.replace(
    \"items: ['Newest First', 'Oldest First', 'A-Z', 'Z-A']\",
    \"items: ['Newest First', 'Oldest First', 'A-Z', 'Z-A', 'Highest Amount', 'Lowest Amount', 'Invoice No (A-Z)', 'Invoice No (Z-A)', 'Legal First', 'Consultancy First']\"
)

# Replace sorting logic
sort_logic = '''if (_sortOption == 'Newest First') {
                            list.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
                          } else if (_sortOption == 'Oldest First') {
                            list.sort((a, b) => (a.createdAt ?? DateTime(2000)).compareTo(b.createdAt ?? DateTime(2000)));
                          } else if (_sortOption == 'A-Z') {
                            list.sort((a, b) => a.name.compareTo(b.name));
                          } else if (_sortOption == 'Z-A') {
                            list.sort((a, b) => b.name.compareTo(a.name));
                          } else if (_sortOption == 'Highest Amount') {
                            list.sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
                          } else if (_sortOption == 'Lowest Amount') {
                            list.sort((a, b) => (a.amount ?? 0).compareTo(b.amount ?? 0));
                          } else if (_sortOption == 'Invoice No (A-Z)') {
                            list.sort((a, b) => (a.registerNo ?? '').compareTo(b.registerNo ?? ''));
                          } else if (_sortOption == 'Invoice No (Z-A)') {
                            list.sort((a, b) => (b.registerNo ?? '').compareTo(a.registerNo ?? ''));
                          } else if (_sortOption == 'Legal First') {
                            list.sort((a, b) {
                              bool aLegal = (a.workType ?? '').toLowerCase().contains('legal');
                              bool bLegal = (b.workType ?? '').toLowerCase().contains('legal');
                              if (aLegal && !bLegal) return -1;
                              if (!aLegal && bLegal) return 1;
                              return 0;
                            });
                          } else if (_sortOption == 'Consultancy First') {
                            list.sort((a, b) {
                              bool aCons = (a.workType ?? '').toLowerCase().contains('consultancy');
                              bool bCons = (b.workType ?? '').toLowerCase().contains('consultancy');
                              if (aCons && !bCons) return -1;
                              if (!aCons && bCons) return 1;
                              return 0;
                            });
                          }'''

content = re.sub(
    r\"if \(_sortOption == 'Newest First'\) \{.*?list\.sort\(\(a, b\) => b\.name\.compareTo\(a\.name\)\);\s*\}\",
    sort_logic,
    content,
    flags=re.DOTALL
)

with open(r'f:\CUC Main Version\lib\screens\work_management_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
