import re

with open(r"d:\Cochin United\Cochin United\CUC Main Version\lib\models\Users.dart", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.split('\n')
new_lines = []
skip = False
for line in lines:
    if "modelSchemaDefinition.addField(" in line and ("Users.CREATED_AT" in line or "Users.LAST_SEEN" in line):
        skip = True
        continue
    if skip:
        if ");" in line:
            skip = False
        continue
    
    if "created_at" in line or "last_seen" in line or "CREATED_AT" in line or "LAST_SEEN" in line:
        continue
        
    new_lines.append(line)

with open(r"d:\Cochin United\Cochin United\CUC Main Version\lib\models\Users.dart", "w", encoding="utf-8") as f:
    f.write('\n'.join(new_lines))

print("Fixed Users.dart")
