import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    index = 0
    search_str = "ModelQueries.list("
    
    while True:
        idx = content.find(search_str, index)
        if idx == -1:
            break
            
        start_idx = idx + len(search_str)
        paren_count = 1
        end_idx = start_idx
        
        while end_idx < len(content) and paren_count > 0:
            if content[end_idx] == '(':
                paren_count += 1
            elif content[end_idx] == ')':
                paren_count -= 1
            end_idx += 1
            
        if paren_count == 0:
            # We found the matching parenthesis at end_idx - 1
            inner_content = content[start_idx:end_idx - 1]
            
            # Check if 'limit:' is already inside the call
            if not re.search(r'\blimit\s*:', inner_content):
                inner_stripped = inner_content.rstrip()
                if inner_stripped.endswith(','):
                    new_inner = inner_content + ' limit: 10000'
                else:
                    new_inner = inner_content + ', limit: 10000'
                
                content = content[:start_idx] + new_inner + content[end_idx - 1:]
                modified = True
                
        index = start_idx
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

def main():
    lib_dir = os.path.join("d:\\", "CUC Main Version", "lib")
    count = 0
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    process_file(filepath)
                    count += 1
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")
    print(f"Processed {count} files.")

if __name__ == '__main__':
    main()
