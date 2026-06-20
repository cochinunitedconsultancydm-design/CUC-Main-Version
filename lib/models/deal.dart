class Deal {
  final int? id;
  final String name;
  final int? clientId;
  final String? clientName;
  final String? contactInfo;
  final String? company;
  final String? workType;
  final String stage;
  final int? responsibleId;
  final String? responsibleName;
  final double amount;
  final String currency;
  final String pipeline;
  final String priority;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isWon;

  // New stage-specific fields
  final String? regFeeRequired;
  final String? referredBy;
  final String? filesReceived;
  final String? contactStatus;
  final String? filesAsked;
  final double? estAmountWork;
  final String? createInvoiceShare;
  final double? expenseSpent;
  final List<dynamic>? expensesList;
  final String? uploadInvoicePath;
  final String? sendToCustomer;
  final String? registerNo;
  final double? invoiceAmount;
  final String? paymentType;
  final String? driveLink;
  final int? billingId;
  final int? quotationId;
  final double? paymentReceived;
  final bool isAdjourned;
  final String? adjournedReason;
  final DateTime? postponedDate;
  final double? partPaymentAmount;
  final bool nocObtained;

  Deal({
    this.id,
    required this.name,
    this.clientId,
    this.clientName,
    this.contactInfo,
    this.company,
    this.workType,
    required this.stage,
    this.responsibleId,
    this.responsibleName,
    this.amount = 0.0,
    this.currency = 'INR',
    this.pipeline = 'General',
    this.priority = 'Normal',
    this.description,
    this.createdAt,
    this.updatedAt,
    this.isWon = false,
    this.regFeeRequired,
    this.referredBy,
    this.filesReceived,
    this.contactStatus,
    this.filesAsked,
    this.estAmountWork,
    this.createInvoiceShare,
    this.expenseSpent,
    this.expensesList,
    this.uploadInvoicePath,
    this.sendToCustomer,
    this.registerNo,
    this.invoiceAmount,
    this.paymentType,
    this.driveLink,
    this.billingId,
    this.quotationId,
    this.paymentReceived,
    this.isAdjourned = false,
    this.adjournedReason,
    this.postponedDate,
    this.partPaymentAmount,
    this.nocObtained = false,
  });

  static const List<String> stages = [
    'Registration',
    'Contact Customer',
    'Work Started',
    'In Progress',
    'Verification',
    'Invoice',
    'Billing Status',
    'Close Deal'
  ];

  static const List<String> priorities = ['Low', 'Normal', 'High', 'Urgent'];

  Map<String, dynamic> toMap() {
    final String adjBlock;
    if (isAdjourned) {
      final dateStr = postponedDate != null ? "\nPostponedDate: ${postponedDate!.toIso8601String()}" : "";
      adjBlock = "\n\n[ADJOURNED]\nIsAdjourned: true\nReason: ${adjournedReason ?? ''}$dateStr";
    } else {
      adjBlock = "";
    }

    String finalDesc = description ?? '';
    final index = finalDesc.indexOf('[ADJOURNED]');
    if (index != -1) {
      finalDesc = finalDesc.substring(0, index).trim();
    }
    finalDesc = "$finalDesc$adjBlock";

    return {
      'id': id,
      'name': name,
      'client_id': clientId,
      'client_name': clientName,
      'contact_info': contactInfo,
      'company': company,
      'work_type': workType,
      'stage': stage,
      'responsible_id': responsibleId,
      'responsible_name': responsibleName,
      'amount': amount,
      'currency': currency,
      'pipeline': pipeline,
      'priority': priority,
      'description': finalDesc,
      'is_won': isWon,
      'reg_fee_required': regFeeRequired,
      'referred_by': referredBy,
      'files_received': filesReceived,
      'contact_status': contactStatus,
      'files_asked': filesAsked,
      'est_amount_work': estAmountWork,
      'create_invoice_share': createInvoiceShare,
      'expense_spent': expenseSpent,
      'expenses_list': expensesList,
      'upload_invoice_path': uploadInvoicePath,
      'send_to_customer': sendToCustomer,
      'register_no': registerNo,
      'invoice_amount': invoiceAmount,
      'payment_type': paymentType,
      'drive_link': driveLink,
      'billing_id': billingId,
      'quotation_id': quotationId,
      'payment_received': paymentReceived,
      'part_payment_amount': partPaymentAmount,
      'noc_obtained': nocObtained,
    };
  }

  factory Deal.fromMap(Map<String, dynamic> map) {
    final rawDesc = map['description'] as String? ?? '';
    bool isAdj = false;
    String? adjReason;
    DateTime? postDate;
    String cleanDesc = rawDesc;

    final regExp = RegExp(
      r'\[ADJOURNED\]\s*\n\s*IsAdjourned:\s*(.*?)\s*\n\s*Reason:\s*(.*?)(?:\s*\n\s*PostponedDate:\s*([^\n\r]+))?$',
      multiLine: true,
      caseSensitive: false,
    );

    final match = regExp.firstMatch(rawDesc);
    if (match != null) {
      isAdj = match.group(1)?.trim().toLowerCase() == 'true';
      adjReason = match.group(2)?.trim();
      final dateStr = match.groupCount >= 3 ? match.group(3)?.trim() : null;
      postDate = (dateStr != null && dateStr.isNotEmpty) ? DateTime.tryParse(dateStr) : null;
      
      final index = rawDesc.indexOf('[ADJOURNED]');
      cleanDesc = rawDesc.substring(0, index).trim();
    }

    return Deal(
      id: map['id'],
      name: map['name'] ?? '',
      clientId: map['client_id'],
      clientName: map['client_name'],
      contactInfo: map['contact_info'],
      company: map['company'],
      workType: map['work_type'],
      stage: map['stage'] ?? 'Registration',
      responsibleId: map['responsible_id'],
      responsibleName: map['responsible_name'],
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      currency: map['currency'] ?? 'INR',
      pipeline: map['pipeline'] ?? 'General',
      priority: map['priority'] ?? 'Normal',
      description: cleanDesc,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      isWon: map['is_won'] ?? false,
      regFeeRequired: map['reg_fee_required'],
      referredBy: map['referred_by'],
      filesReceived: map['files_received'],
      contactStatus: map['contact_status'],
      filesAsked: map['files_asked'],
      estAmountWork: double.tryParse(map['est_amount_work']?.toString() ?? ''),
      createInvoiceShare: map['create_invoice_share'],
      expenseSpent: double.tryParse(map['expense_spent']?.toString() ?? ''),
      expensesList: map['expenses_list'] is List ? map['expenses_list'] as List<dynamic> : null,
      uploadInvoicePath: map['upload_invoice_path'],
      sendToCustomer: map['send_to_customer'],
      registerNo: map['register_no'],
      invoiceAmount: double.tryParse(map['invoice_amount']?.toString() ?? ''),
      paymentType: map['payment_type'],
      driveLink: map['drive_link'],
      billingId: map['billing_id'],
      quotationId: map['quotation_id'],
      paymentReceived: double.tryParse(map['payment_received']?.toString() ?? ''),
      isAdjourned: isAdj,
      adjournedReason: adjReason,
      postponedDate: postDate,
      partPaymentAmount: double.tryParse(map['part_payment_amount']?.toString() ?? ''),
      nocObtained: map['noc_obtained'] == true || map['noc_obtained'] == 'true',
    );
  }
}

class DealAssignee {
  final int? id;
  final int dealId;
  final int userId;
  final String? userName;
  final String role; // 'Lead', 'Collaborator'

  DealAssignee({this.id, required this.dealId, required this.userId, this.userName, required this.role});

  Map<String, dynamic> toMap() => {'deal_id': dealId, 'user_id': userId, 'role': role};
  factory DealAssignee.fromMap(Map<String, dynamic> map) => DealAssignee(
    id: map['id'],
    dealId: map['deal_id'],
    userId: map['user_id'],
    userName: map['user_name'],
    role: map['role'],
  );
}

class DealHandover {
  final int? id;
  final int dealId;
  final int fromUserId;
  final int toUserId;
  final String? note;
  final DateTime? createdAt;

  DealHandover({this.id, required this.dealId, required this.fromUserId, required this.toUserId, this.note, this.createdAt});

  Map<String, dynamic> toMap() => {'deal_id': dealId, 'from_user_id': fromUserId, 'to_user_id': toUserId, 'note': note};
}
