import os
import re

lib_dir = "lib"
test_dir = "test"

# Fix lib files
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
            
            if re.search(r'\bprint\(', content):
                content = re.sub(r'\bprint\(', 'debugPrint(', content)
                if 'import \'package:flutter/foundation.dart\';' not in content:
                    # Insert import at the top
                    content = 'import \'package:flutter/foundation.dart\';\n' + content
                
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Fixed {filepath}")

# Fix test files
for root, dirs, files in os.walk(test_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
            
            if 'avoid_print' not in content and re.search(r'\bprint\(', content):
                content = '// ignore_for_file: avoid_print\n' + content
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Ignored print in {filepath}")
