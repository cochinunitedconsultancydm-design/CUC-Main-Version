import 'dart:io';

void main() async {
  final file = File('lib/screens/staff_management_screen.dart');
  var code = await file.readAsString();

  // Handle \r\n vs \n
  code = code.replaceAll('\r\n', '\n');

  // 1. fetchStaff map
  code = code.replaceAll(
    """        combined.add({
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'email': u.email,
          'role': u.role,
          'last_login': session?.login_time,
          'is_active': session?.is_active ?? false,
        });""",
    """        combined.add({
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'email': u.email,
          'role': u.role,
          'last_login': session?.login_time,
          'is_active': session?.is_active ?? false,
          'designation': u.designation,
          'personal_phone': u.personal_phone,
          'aadhar_card': u.aadhar_card,
          'driving_license': u.driving_license,
          'insurance': u.insurance,
          'emergency_contact': u.emergency_contact,
          'offer_letter': u.offer_letter,
          'dob': u.dob,
          'salary': u.salary,
          'work_time': u.work_time,
          'blood_group': u.blood_group,
          'personal_email': u.personal_email,
          'company_email': u.company_email,
          'company_phone': u.company_phone,
        });"""
  );

  // 2. Controllers
  code = code.replaceAll(
    """    final email = TextEditingController(text: user?['email']);
    final password = TextEditingController();
    String role = user?['role'] ?? 'staff';""",
    """    final email = TextEditingController(text: user?['email']);
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
    
    String role = user?['role'] ?? 'staff';"""
  );

  // 3. UI
  code = code.replaceAll(
    """                  const SizedBox(height: 24),
                  TextField(controller: name, decoration: inputDec('Full Name', Icons.person_outline_rounded), maxLength: 100),
                  const SizedBox(height: 16),
                  TextField(controller: username, decoration: inputDec('Username', Icons.alternate_email_rounded), maxLength: 50),
                  const SizedBox(height: 16),
                  TextField(controller: email, decoration: inputDec('Email Address', Icons.email_outlined), keyboardType: TextInputType.emailAddress, maxLength: 100),
                  if (user == null) ...[
                    const SizedBox(height: 16),
                    TextField(controller: password, decoration: inputDec('Initial Password', Icons.lock_outline_rounded), obscureText: true, maxLength: 128),
                  ],
                  const SizedBox(height: 32),
                  const Text('Access Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),""",
    """                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(controller: name, decoration: inputDec('Full Name', Icons.person_outline_rounded), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: username, decoration: inputDec('Username', Icons.alternate_email_rounded), maxLength: 50),
                          const SizedBox(height: 16),
                          TextField(controller: email, decoration: inputDec('Email Address', Icons.email_outlined), keyboardType: TextInputType.emailAddress, maxLength: 100),
                          if (user == null) ...[
                            const SizedBox(height: 16),
                            TextField(controller: password, decoration: inputDec('Initial Password', Icons.lock_outline_rounded), obscureText: true, maxLength: 128),
                          ],
                          const SizedBox(height: 16),
                          TextField(controller: designation, decoration: inputDec('Designation', Icons.work_outline), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: personalPhone, decoration: inputDec('Personal Phone', Icons.phone_android), maxLength: 50),
                          const SizedBox(height: 16),
                          TextField(controller: aadharCard, decoration: inputDec('Aadhar Card', Icons.credit_card), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: drivingLicense, decoration: inputDec('Driving License', Icons.card_membership), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: insurance, decoration: inputDec('Insurance Upload (Link/Text)', Icons.security), maxLength: 255),
                          const SizedBox(height: 16),
                          TextField(controller: emergencyContact, decoration: inputDec('Emergency Contact', Icons.contact_emergency), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: offerLetter, decoration: inputDec('Offer Letter (Link/Text)', Icons.document_scanner), maxLength: 255),
                          const SizedBox(height: 16),
                          TextField(controller: dob, decoration: inputDec('Date of Birth', Icons.cake), maxLength: 50),
                          const SizedBox(height: 16),
                          TextField(controller: salary, decoration: inputDec('Salary', Icons.monetization_on), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: workTime, decoration: inputDec('Work Time', Icons.access_time), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: bloodGroup, decoration: inputDec('Blood Group', Icons.bloodtype), maxLength: 20),
                          const SizedBox(height: 16),
                          TextField(controller: personalEmail, decoration: inputDec('Personal Email', Icons.mail_outline), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: companyEmail, decoration: inputDec('Company Email', Icons.business), maxLength: 100),
                          const SizedBox(height: 16),
                          TextField(controller: companyPhone, decoration: inputDec('Company Phone', Icons.phone), maxLength: 50),
                          const SizedBox(height: 32),
                          const Text('Access Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 16),"""
  );

  // 4. Close single child scroll view
  code = code.replaceAll(
    """                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(""",
    """                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton("""
  );

  // 5. New User
  code = code.replaceAll(
    """                              final newUser = amplify_models.Users(
                                name: SecurityService().sanitize(name.text, maxLength: 100),
                                username: SecurityService().sanitize(username.text, maxLength: 50),
                                email: SecurityService().sanitize(email.text, maxLength: 100),
                                password: hashedPassword,
                                role: role,
                              );""",
    """                              final newUser = amplify_models.Users(
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
                              );"""
  );

  // 6. Update user
  code = code.replaceAll(
    """                                final updated = existing.copyWith(
                                  name: name.text,
                                  username: username.text,
                                  email: email.text,
                                  role: role,
                                );""",
    """                                final updated = existing.copyWith(
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
                                );"""
  );

  await file.writeAsString(code);
}
