import 'dart:io';

void main() async {
  final file = File('lib/screens/staff_management_screen.dart');
  final code = await file.readAsString();

  final startStr = '  void _showForm([Map<String, dynamic>? user]) {';
  final endStr = '  void _resetPassword(Map<String, dynamic> user) {';
  
  final startIndex = code.indexOf(startStr);
  final endIndex = code.indexOf(endStr);
  
  if (startIndex == -1 || endIndex == -1) {
    print('Failed to find start or end index.');
    return;
  }

  final newMethod = '''  void _showForm([Map<String, dynamic>? user]) {
    final name = TextEditingController(text: user?['name']);
    final username = TextEditingController(text: user?['username']);
    final email = TextEditingController(text: user?['email']);
    final password = TextEditingController();
    
    final designation = TextEditingController(text: user?['designation']);
    final personalPhone = TextEditingController(text: user?['personal_phone']);
    final aadharCard = TextEditingController(text: user?['aadhar_card']);
    final drivingLicense = TextEditingController(text: user?['driving_license']);
    final insurance = TextEditingController(text: user?['insurance']);
    final emergencyContact = TextEditingController(text: user?['emergency_contact']);
    final offerLetter = TextEditingController(text: user?['offer_letter']);
    final dob = TextEditingController(text: user?['dob']);
    final salary = TextEditingController(text: user?['salary']);
    final workTime = TextEditingController(text: user?['work_time']);
    final bloodGroup = TextEditingController(text: user?['blood_group']);
    final personalEmail = TextEditingController(text: user?['personal_email']);
    final companyEmail = TextEditingController(text: user?['company_email']);
    final companyPhone = TextEditingController(text: user?['company_phone']);
    
    String role = user?['role'] ?? 'staff';

    InputDecoration inputDec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    }

    Widget roleChip(String label, String value, bool isSelected, Color color, Function(String) onSelect) {
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : Colors.white,
              border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    Widget sectionHeader(String title, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
          ],
        ),
      );
    }

    Widget buildRow(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: children.map((e) {
            bool isLast = children.last == e;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 16),
                child: e,
              ),
            );
          }).toList(),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 850),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Region
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user == null ? 'Add Staff Member' : 'Edit Staff Profile', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user == null ? 'Enter details to register a new member.' : 'Update the details for this staff member.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 24,
                        style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                      ),
                    ],
                  ),
                ),
                
                // Form Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        sectionHeader('Personal Information', Icons.person),
                        buildRow([
                          TextField(controller: name, decoration: inputDec('Full Name', Icons.person_outline_rounded), maxLength: 100),
                          TextField(controller: dob, decoration: inputDec('Date of Birth', Icons.cake), maxLength: 50),
                        ]),
                        buildRow([
                          TextField(controller: bloodGroup, decoration: inputDec('Blood Group', Icons.bloodtype), maxLength: 20),
                          TextField(controller: personalPhone, decoration: inputDec('Personal Phone', Icons.phone_android), maxLength: 50),
                        ]),
                        buildRow([
                          TextField(controller: personalEmail, decoration: inputDec('Personal Email', Icons.mail_outline), maxLength: 100),
                          TextField(controller: emergencyContact, decoration: inputDec('Emergency Contact', Icons.contact_emergency), maxLength: 100),
                        ]),

                        sectionHeader('Employment Details', Icons.work),
                        buildRow([
                          TextField(controller: designation, decoration: inputDec('Designation', Icons.work_outline), maxLength: 100),
                          TextField(controller: email, decoration: inputDec('Login / Company Email', Icons.business), keyboardType: TextInputType.emailAddress, maxLength: 100),
                        ]),
                        buildRow([
                          TextField(controller: companyEmail, decoration: inputDec('Secondary Company Email', Icons.alternate_email), maxLength: 100),
                          TextField(controller: companyPhone, decoration: inputDec('Company Phone', Icons.phone), maxLength: 50),
                        ]),
                        buildRow([
                          TextField(controller: salary, decoration: inputDec('Salary', Icons.monetization_on), maxLength: 100),
                          TextField(controller: workTime, decoration: inputDec('Work Time', Icons.access_time), maxLength: 100),
                        ]),
                        
                        sectionHeader('Documents & IDs', Icons.folder_shared),
                        buildRow([
                          TextField(controller: aadharCard, decoration: inputDec('Aadhar Card', Icons.credit_card), maxLength: 100),
                          TextField(controller: drivingLicense, decoration: inputDec('Driving License', Icons.card_membership), maxLength: 100),
                        ]),
                        buildRow([
                          TextField(controller: insurance, decoration: inputDec('Insurance Upload (Link/Text)', Icons.security), maxLength: 255),
                          TextField(controller: offerLetter, decoration: inputDec('Offer Letter (Link/Text)', Icons.document_scanner), maxLength: 255),
                        ]),

                        sectionHeader('Authentication & Access', Icons.security),
                        buildRow([
                          TextField(controller: username, decoration: inputDec('Username', Icons.alternate_email_rounded), maxLength: 50),
                          if (user == null)
                            TextField(controller: password, decoration: inputDec('Initial Password', Icons.lock_outline_rounded), obscureText: true, maxLength: 128)
                          else
                            const Spacer(),
                        ]),
                        
                        const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Text('Access Level (Role)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                        Row(
                          children: [
                            roleChip('Admin', 'admin', role == 'admin', Colors.purple, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Manager', 'manager', role == 'manager', Colors.indigo, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Accountant', 'accountant', role == 'accountant', Colors.teal, (v) => setModalState(() => role = v)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            roleChip('Staff', 'staff', role == 'staff', AppTheme.primaryColor, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            roleChip('Delivery', 'delivery', role == 'delivery', Colors.orange, (v) => setModalState(() => role = v)),
                            const SizedBox(width: 12),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          foregroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (name.text.isEmpty || username.text.isEmpty || email.text.isEmpty || (user == null && password.text.isEmpty)) {
                            _msg('Please fill required fields (Name, Username, Email, Password)', false);
                            return;
                          }
                          try {
                            if (user == null) {
                              // SECURITY: Hash password before storing
                              final hashedPassword = SecurityService().hashPassword(password.text);
                              final newUser = amplify_models.Users(
                                name: SecurityService().sanitize(name.text, maxLength: 100),
                                username: SecurityService().sanitize(username.text, maxLength: 50),
                                email: SecurityService().sanitize(email.text, maxLength: 100),
                                password: hashedPassword,
                                role: role,
                                designation: designation.text.isNotEmpty ? designation.text : null,
                                personal_phone: personalPhone.text.isNotEmpty ? personalPhone.text : null,
                                aadhar_card: aadharCard.text.isNotEmpty ? aadharCard.text : null,
                                driving_license: drivingLicense.text.isNotEmpty ? drivingLicense.text : null,
                                insurance: insurance.text.isNotEmpty ? insurance.text : null,
                                emergency_contact: emergencyContact.text.isNotEmpty ? emergencyContact.text : null,
                                offer_letter: offerLetter.text.isNotEmpty ? offerLetter.text : null,
                                dob: dob.text.isNotEmpty ? dob.text : null,
                                salary: salary.text.isNotEmpty ? salary.text : null,
                                work_time: workTime.text.isNotEmpty ? workTime.text : null,
                                blood_group: bloodGroup.text.isNotEmpty ? bloodGroup.text : null,
                                personal_email: personalEmail.text.isNotEmpty ? personalEmail.text : null,
                                company_email: companyEmail.text.isNotEmpty ? companyEmail.text : null,
                                company_phone: companyPhone.text.isNotEmpty ? companyPhone.text : null,
                              );
                              await BackupAwareApi().create(newUser);
                              await LoggingService().logAction(action: 'CREATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Added new staff member: \${name.text}');
                            } else {
                              final req = ModelQueries.list(amplify_models.Users.classType, where: amplify_models.Users.ID.eq(user['id'].toString()));
                              final res = await Amplify.API.query(request: req).response;
                              if (res.data?.items.isNotEmpty == true) {
                                final existing = res.data!.items.first!;
                                final updated = existing.copyWith(
                                  name: name.text,
                                  username: username.text,
                                  email: email.text,
                                  role: role,
                                  designation: designation.text,
                                  personal_phone: personalPhone.text,
                                  aadhar_card: aadharCard.text,
                                  driving_license: drivingLicense.text,
                                  insurance: insurance.text,
                                  emergency_contact: emergencyContact.text,
                                  offer_letter: offerLetter.text,
                                  dob: dob.text,
                                  salary: salary.text,
                                  work_time: workTime.text,
                                  blood_group: bloodGroup.text,
                                  personal_email: personalEmail.text,
                                  company_email: companyEmail.text,
                                  company_phone: companyPhone.text,
                                );
                                await BackupAwareApi().update(updated);
                                await LoggingService().logAction(action: 'UPDATE_STAFF', targetType: 'Staff', targetId: username.text, details: 'Updated staff member: \${name.text}');
                              }
                            }
                            if (mounted) Navigator.pop(context);
                            _fetchStaff();
                            _msg('Saved successfully', true);
                          } catch (e) {
                            _msg('Error: \$e', false);
                          }
                        },
                        icon: Icon(user == null ? Icons.add_circle_outline : Icons.save_rounded, size: 20),
                        label: Text(user == null ? 'Create Member' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

''';

  final newCode = code.substring(0, startIndex) + newMethod + code.substring(endIndex);
  await file.writeAsString(newCode);
}
