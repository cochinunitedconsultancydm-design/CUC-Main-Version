const fs = require('fs');

const path = 'lib/models/Users.dart';
let content = fs.readFileSync(path, 'utf8');

const lines = content.split('\n');
const newLines = [];
let skip = false;

for (let line of lines) {
    if (line.includes('modelSchemaDefinition.addField(') && (line.includes('Users.CREATED_AT') || line.includes('Users.LAST_SEEN'))) {
        skip = true;
        continue;
    }
    if (skip) {
        if (line.includes(');')) {
            skip = false;
        }
        continue;
    }
    
    if (line.includes('created_at') || line.includes('last_seen') || line.includes('CREATED_AT') || line.includes('LAST_SEEN')) {
        continue;
    }
    
    newLines.push(line);
}

fs.writeFileSync(path, newLines.join('\n'), 'utf8');
console.log('Fixed Users.dart');
