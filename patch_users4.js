const fs = require('fs');

let c;
try {
  c = fs.readFileSync('lib/models/Users.dart', 'utf8');
} catch (e) {
  console.log(e);
}

c = c.replace('blood_group: blood_group, wedding_anniversary, personal_email: personal_email', 'blood_group: blood_group, wedding_anniversary: wedding_anniversary, personal_email: personal_email');
c = c.replace('blood_group: blood_group ?? this.blood_group, wedding_anniversary ?? this.wedding_anniversary, personal_email: personal_email ?? this.personal_email', 'blood_group: blood_group ?? this.blood_group, wedding_anniversary: wedding_anniversary ?? this.wedding_anniversary, personal_email: personal_email ?? this.personal_email');

fs.writeFileSync('lib/models/Users.dart', c, 'utf8');
