class CompanyProfile {
  final String companyName;
  final String legalEntityType;
  final String registrationNumber;
  final String gstin;
  final String pan;
  final String tan;
  final String msmeUdyam;
  final String registeredAddress;
  final String corporateAddress;
  final String contactPhone;
  final String contactEmail;
  final String website;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String upiId;

  const CompanyProfile({
    this.companyName = 'Cochin United Consultancy',
    this.legalEntityType = 'Partnership Firm',
    this.registrationNumber = '',
    this.gstin = '',
    this.pan = '',
    this.tan = '',
    this.msmeUdyam = '',
    this.registeredAddress = 'Door No. 44/2258, Cochin, Kerala - 682017',
    this.corporateAddress = 'Door No. 44/2258, Cochin, Kerala - 682017',
    this.contactPhone = '+91 70124 66754',
    this.contactEmail = 'cochinunitedconsultancydm@gmail.com',
    this.website = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.branch = '',
    this.upiId = '',
  });

  Map<String, dynamic> toMap() => {
        'companyName': companyName,
        'legalEntityType': legalEntityType,
        'registrationNumber': registrationNumber,
        'gstin': gstin,
        'pan': pan,
        'tan': tan,
        'msmeUdyam': msmeUdyam,
        'registeredAddress': registeredAddress,
        'corporateAddress': corporateAddress,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'website': website,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
        'branch': branch,
        'upiId': upiId,
      };

  factory CompanyProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CompanyProfile();
    return CompanyProfile(
      companyName: map['companyName']?.toString() ?? 'Cochin United Consultancy',
      legalEntityType: map['legalEntityType']?.toString() ?? 'Partnership Firm',
      registrationNumber: map['registrationNumber']?.toString() ?? '',
      gstin: map['gstin']?.toString() ?? '',
      pan: map['pan']?.toString() ?? '',
      tan: map['tan']?.toString() ?? '',
      msmeUdyam: map['msmeUdyam']?.toString() ?? '',
      registeredAddress: map['registeredAddress']?.toString() ?? 'Door No. 44/2258, Cochin, Kerala - 682017',
      corporateAddress: map['corporateAddress']?.toString() ?? 'Door No. 44/2258, Cochin, Kerala - 682017',
      contactPhone: map['contactPhone']?.toString() ?? '+91 70124 66754',
      contactEmail: map['contactEmail']?.toString() ?? 'cochinunitedconsultancydm@gmail.com',
      website: map['website']?.toString() ?? '',
      bankName: map['bankName']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      ifscCode: map['ifscCode']?.toString() ?? '',
      branch: map['branch']?.toString() ?? '',
      upiId: map['upiId']?.toString() ?? '',
    );
  }

  CompanyProfile copyWith({
    String? companyName,
    String? legalEntityType,
    String? registrationNumber,
    String? gstin,
    String? pan,
    String? tan,
    String? msmeUdyam,
    String? registeredAddress,
    String? corporateAddress,
    String? contactPhone,
    String? contactEmail,
    String? website,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    String? upiId,
  }) {
    return CompanyProfile(
      companyName: companyName ?? this.companyName,
      legalEntityType: legalEntityType ?? this.legalEntityType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      tan: tan ?? this.tan,
      msmeUdyam: msmeUdyam ?? this.msmeUdyam,
      registeredAddress: registeredAddress ?? this.registeredAddress,
      corporateAddress: corporateAddress ?? this.corporateAddress,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      upiId: upiId ?? this.upiId,
    );
  }
}

class CompanyDocument {
  final String id;
  final String title;
  final String category; // Deed, Registration & Tax, Banking & Mandate, Compliance & Licenses, Other
  final String documentNumber;
  final String issueDate;
  final String expiryDate;
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final String notes;
  final String createdAt;

  const CompanyDocument({
    required this.id,
    required this.title,
    this.category = 'Deed',
    this.documentNumber = '',
    this.issueDate = '',
    this.expiryDate = '',
    this.fileUrl = '',
    this.fileName = '',
    this.fileSize = '',
    this.notes = '',
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'documentNumber': documentNumber,
        'issueDate': issueDate,
        'expiryDate': expiryDate,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory CompanyDocument.fromMap(Map<String, dynamic> map) {
    return CompanyDocument(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Document',
      category: map['category']?.toString() ?? 'Deed',
      documentNumber: map['documentNumber']?.toString() ?? '',
      issueDate: map['issueDate']?.toString() ?? '',
      expiryDate: map['expiryDate']?.toString() ?? '',
      fileUrl: map['fileUrl']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      fileSize: map['fileSize']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  CompanyDocument copyWith({
    String? id,
    String? title,
    String? category,
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? notes,
    String? createdAt,
  }) {
    return CompanyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PartnerDocument {
  final String id;
  final String name;
  final String designation; // Managing Partner, Designated Partner, Partner, Director
  final String sharePercentage;
  final String phone;
  final String email;
  final String address;
  final String aadhaarNumber;
  final String aadhaarDocUrl;
  final String aadhaarDocName;
  final String panNumber;
  final String panDocUrl;
  final String panDocName;
  final String photoUrl;
  final String otherDocUrl;
  final String otherDocName;
  final String notes;
  final String createdAt;

  const PartnerDocument({
    required this.id,
    required this.name,
    this.designation = 'Partner',
    this.sharePercentage = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.aadhaarNumber = '',
    this.aadhaarDocUrl = '',
    this.aadhaarDocName = '',
    this.panNumber = '',
    this.panDocUrl = '',
    this.panDocName = '',
    this.photoUrl = '',
    this.otherDocUrl = '',
    this.otherDocName = '',
    this.notes = '',
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'designation': designation,
        'sharePercentage': sharePercentage,
        'phone': phone,
        'email': email,
        'address': address,
        'aadhaarNumber': aadhaarNumber,
        'aadhaarDocUrl': aadhaarDocUrl,
        'aadhaarDocName': aadhaarDocName,
        'panNumber': panNumber,
        'panDocUrl': panDocUrl,
        'panDocName': panDocName,
        'photoUrl': photoUrl,
        'otherDocUrl': otherDocUrl,
        'otherDocName': otherDocName,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory PartnerDocument.fromMap(Map<String, dynamic> map) {
    return PartnerDocument(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Partner',
      designation: map['designation']?.toString() ?? 'Partner',
      sharePercentage: map['sharePercentage']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      aadhaarNumber: map['aadhaarNumber']?.toString() ?? '',
      aadhaarDocUrl: map['aadhaarDocUrl']?.toString() ?? '',
      aadhaarDocName: map['aadhaarDocName']?.toString() ?? '',
      panNumber: map['panNumber']?.toString() ?? '',
      panDocUrl: map['panDocUrl']?.toString() ?? '',
      panDocName: map['panDocName']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      otherDocUrl: map['otherDocUrl']?.toString() ?? '',
      otherDocName: map['otherDocName']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  PartnerDocument copyWith({
    String? id,
    String? name,
    String? designation,
    String? sharePercentage,
    String? phone,
    String? email,
    String? address,
    String? aadhaarNumber,
    String? aadhaarDocUrl,
    String? aadhaarDocName,
    String? panNumber,
    String? panDocUrl,
    String? panDocName,
    String? photoUrl,
    String? otherDocUrl,
    String? otherDocName,
    String? notes,
    String? createdAt,
  }) {
    return PartnerDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      sharePercentage: sharePercentage ?? this.sharePercentage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarDocUrl: aadhaarDocUrl ?? this.aadhaarDocUrl,
      aadhaarDocName: aadhaarDocName ?? this.aadhaarDocName,
      panNumber: panNumber ?? this.panNumber,
      panDocUrl: panDocUrl ?? this.panDocUrl,
      panDocName: panDocName ?? this.panDocName,
      photoUrl: photoUrl ?? this.photoUrl,
      otherDocUrl: otherDocUrl ?? this.otherDocUrl,
      otherDocName: otherDocName ?? this.otherDocName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
