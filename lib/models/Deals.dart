/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Deals type in your schema. */
class Deals extends amplify_core.Model {
  static const classType = const _DealsModelType();
  final String id;
  final String? _name;
  final int? _client_id;
  final String? _client_name;
  final String? _contact_info;
  final String? _company;
  final String? _work_type;
  final String? _stage;
  final int? _responsible_id;
  final String? _responsible_name;
  final double? _amount;
  final String? _currency;
  final String? _pipeline;
  final String? _priority;
  final String? _description;
  final String? _created_at;
  final String? _updated_at;
  final String? _closed_at;
  final bool? _is_won;
  final String? _reg_fee_required;
  final String? _files_received;
  final String? _contact_status;
  final String? _files_asked;
  final double? _est_amount_work;
  final String? _create_invoice_share;
  final double? _expense_spent;
  final String? _upload_invoice_path;
  final String? _send_to_customer;
  final String? _register_no;
  final double? _invoice_amount;
  final String? _payment_type;
  final String? _drive_link;
  final int? _billing_id;
  final int? _quotation_id;
  final double? _payment_received;
  final double? _part_payment_amount;
  final bool? _noc_obtained;
  final String? _referred_by;
  final String? _expenses_list;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DealsModelIdentifier get modelIdentifier {
      return DealsModelIdentifier(
        id: id
      );
  }
  
  String? get name {
    return _name;
  }
  
  int? get client_id {
    return _client_id;
  }
  
  String? get client_name {
    return _client_name;
  }
  
  String? get contact_info {
    return _contact_info;
  }
  
  String? get company {
    return _company;
  }
  
  String? get work_type {
    return _work_type;
  }
  
  String? get stage {
    return _stage;
  }
  
  int? get responsible_id {
    return _responsible_id;
  }
  
  String? get responsible_name {
    return _responsible_name;
  }
  
  double? get amount {
    return _amount;
  }
  
  String? get currency {
    return _currency;
  }
  
  String? get pipeline {
    return _pipeline;
  }
  
  String? get priority {
    return _priority;
  }
  
  String? get description {
    return _description;
  }
  
  String? get created_at {
    return _created_at;
  }
  
  String? get updated_at {
    return _updated_at;
  }
  
  String? get closed_at {
    return _closed_at;
  }
  
  bool? get is_won {
    return _is_won;
  }
  
  String? get reg_fee_required {
    return _reg_fee_required;
  }
  
  String? get files_received {
    return _files_received;
  }
  
  String? get contact_status {
    return _contact_status;
  }
  
  String? get files_asked {
    return _files_asked;
  }
  
  double? get est_amount_work {
    return _est_amount_work;
  }
  
  String? get create_invoice_share {
    return _create_invoice_share;
  }
  
  double? get expense_spent {
    return _expense_spent;
  }
  
  String? get upload_invoice_path {
    return _upload_invoice_path;
  }
  
  String? get send_to_customer {
    return _send_to_customer;
  }
  
  String? get register_no {
    return _register_no;
  }
  
  double? get invoice_amount {
    return _invoice_amount;
  }
  
  String? get payment_type {
    return _payment_type;
  }
  
  String? get drive_link {
    return _drive_link;
  }
  
  int? get billing_id {
    return _billing_id;
  }
  
  int? get quotation_id {
    return _quotation_id;
  }
  
  double? get payment_received {
    return _payment_received;
  }
  
  double? get part_payment_amount {
    return _part_payment_amount;
  }
  
  bool? get noc_obtained {
    return _noc_obtained;
  }
  
  String? get referred_by {
    return _referred_by;
  }
  
  String? get expenses_list {
    return _expenses_list;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Deals._internal({required this.id, name, client_id, client_name, contact_info, company, work_type, stage, responsible_id, responsible_name, amount, currency, pipeline, priority, description, created_at, updated_at, closed_at, is_won, reg_fee_required, files_received, contact_status, files_asked, est_amount_work, create_invoice_share, expense_spent, upload_invoice_path, send_to_customer, register_no, invoice_amount, payment_type, drive_link, billing_id, quotation_id, payment_received, part_payment_amount, noc_obtained, referred_by, expenses_list, createdAt, updatedAt}): _name = name, _client_id = client_id, _client_name = client_name, _contact_info = contact_info, _company = company, _work_type = work_type, _stage = stage, _responsible_id = responsible_id, _responsible_name = responsible_name, _amount = amount, _currency = currency, _pipeline = pipeline, _priority = priority, _description = description, _created_at = created_at, _updated_at = updated_at, _closed_at = closed_at, _is_won = is_won, _reg_fee_required = reg_fee_required, _files_received = files_received, _contact_status = contact_status, _files_asked = files_asked, _est_amount_work = est_amount_work, _create_invoice_share = create_invoice_share, _expense_spent = expense_spent, _upload_invoice_path = upload_invoice_path, _send_to_customer = send_to_customer, _register_no = register_no, _invoice_amount = invoice_amount, _payment_type = payment_type, _drive_link = drive_link, _billing_id = billing_id, _quotation_id = quotation_id, _payment_received = payment_received, _part_payment_amount = part_payment_amount, _noc_obtained = noc_obtained, _referred_by = referred_by, _expenses_list = expenses_list, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Deals({String? id, String? name, int? client_id, String? client_name, String? contact_info, String? company, String? work_type, String? stage, int? responsible_id, String? responsible_name, double? amount, String? currency, String? pipeline, String? priority, String? description, String? created_at, String? updated_at, String? closed_at, bool? is_won, String? reg_fee_required, String? files_received, String? contact_status, String? files_asked, double? est_amount_work, String? create_invoice_share, double? expense_spent, String? upload_invoice_path, String? send_to_customer, String? register_no, double? invoice_amount, String? payment_type, String? drive_link, int? billing_id, int? quotation_id, double? payment_received, double? part_payment_amount, bool? noc_obtained, String? referred_by, String? expenses_list}) {
    return Deals._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      client_id: client_id,
      client_name: client_name,
      contact_info: contact_info,
      company: company,
      work_type: work_type,
      stage: stage,
      responsible_id: responsible_id,
      responsible_name: responsible_name,
      amount: amount,
      currency: currency,
      pipeline: pipeline,
      priority: priority,
      description: description,
      created_at: created_at,
      updated_at: updated_at,
      closed_at: closed_at,
      is_won: is_won,
      reg_fee_required: reg_fee_required,
      files_received: files_received,
      contact_status: contact_status,
      files_asked: files_asked,
      est_amount_work: est_amount_work,
      create_invoice_share: create_invoice_share,
      expense_spent: expense_spent,
      upload_invoice_path: upload_invoice_path,
      send_to_customer: send_to_customer,
      register_no: register_no,
      invoice_amount: invoice_amount,
      payment_type: payment_type,
      drive_link: drive_link,
      billing_id: billing_id,
      quotation_id: quotation_id,
      payment_received: payment_received,
      part_payment_amount: part_payment_amount,
      noc_obtained: noc_obtained,
      referred_by: referred_by,
      expenses_list: expenses_list);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Deals &&
      id == other.id &&
      _name == other._name &&
      _client_id == other._client_id &&
      _client_name == other._client_name &&
      _contact_info == other._contact_info &&
      _company == other._company &&
      _work_type == other._work_type &&
      _stage == other._stage &&
      _responsible_id == other._responsible_id &&
      _responsible_name == other._responsible_name &&
      _amount == other._amount &&
      _currency == other._currency &&
      _pipeline == other._pipeline &&
      _priority == other._priority &&
      _description == other._description &&
      _created_at == other._created_at &&
      _updated_at == other._updated_at &&
      _closed_at == other._closed_at &&
      _is_won == other._is_won &&
      _reg_fee_required == other._reg_fee_required &&
      _files_received == other._files_received &&
      _contact_status == other._contact_status &&
      _files_asked == other._files_asked &&
      _est_amount_work == other._est_amount_work &&
      _create_invoice_share == other._create_invoice_share &&
      _expense_spent == other._expense_spent &&
      _upload_invoice_path == other._upload_invoice_path &&
      _send_to_customer == other._send_to_customer &&
      _register_no == other._register_no &&
      _invoice_amount == other._invoice_amount &&
      _payment_type == other._payment_type &&
      _drive_link == other._drive_link &&
      _billing_id == other._billing_id &&
      _quotation_id == other._quotation_id &&
      _payment_received == other._payment_received &&
      _part_payment_amount == other._part_payment_amount &&
      _noc_obtained == other._noc_obtained &&
      _referred_by == other._referred_by &&
      _expenses_list == other._expenses_list;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Deals {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("client_id=" + (_client_id != null ? _client_id!.toString() : "null") + ", ");
    buffer.write("client_name=" + "$_client_name" + ", ");
    buffer.write("contact_info=" + "$_contact_info" + ", ");
    buffer.write("company=" + "$_company" + ", ");
    buffer.write("work_type=" + "$_work_type" + ", ");
    buffer.write("stage=" + "$_stage" + ", ");
    buffer.write("responsible_id=" + (_responsible_id != null ? _responsible_id!.toString() : "null") + ", ");
    buffer.write("responsible_name=" + "$_responsible_name" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("currency=" + "$_currency" + ", ");
    buffer.write("pipeline=" + "$_pipeline" + ", ");
    buffer.write("priority=" + "$_priority" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("closed_at=" + "$_closed_at" + ", ");
    buffer.write("is_won=" + (_is_won != null ? _is_won!.toString() : "null") + ", ");
    buffer.write("reg_fee_required=" + "$_reg_fee_required" + ", ");
    buffer.write("files_received=" + "$_files_received" + ", ");
    buffer.write("contact_status=" + "$_contact_status" + ", ");
    buffer.write("files_asked=" + "$_files_asked" + ", ");
    buffer.write("est_amount_work=" + (_est_amount_work != null ? _est_amount_work!.toString() : "null") + ", ");
    buffer.write("create_invoice_share=" + "$_create_invoice_share" + ", ");
    buffer.write("expense_spent=" + (_expense_spent != null ? _expense_spent!.toString() : "null") + ", ");
    buffer.write("upload_invoice_path=" + "$_upload_invoice_path" + ", ");
    buffer.write("send_to_customer=" + "$_send_to_customer" + ", ");
    buffer.write("register_no=" + "$_register_no" + ", ");
    buffer.write("invoice_amount=" + (_invoice_amount != null ? _invoice_amount!.toString() : "null") + ", ");
    buffer.write("payment_type=" + "$_payment_type" + ", ");
    buffer.write("drive_link=" + "$_drive_link" + ", ");
    buffer.write("billing_id=" + (_billing_id != null ? _billing_id!.toString() : "null") + ", ");
    buffer.write("quotation_id=" + (_quotation_id != null ? _quotation_id!.toString() : "null") + ", ");
    buffer.write("payment_received=" + (_payment_received != null ? _payment_received!.toString() : "null") + ", ");
    buffer.write("part_payment_amount=" + (_part_payment_amount != null ? _part_payment_amount!.toString() : "null") + ", ");
    buffer.write("noc_obtained=" + (_noc_obtained != null ? _noc_obtained!.toString() : "null") + ", ");
    buffer.write("referred_by=" + "$_referred_by" + ", ");
    buffer.write("expenses_list=" + "$_expenses_list" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Deals copyWith({String? name, int? client_id, String? client_name, String? contact_info, String? company, String? work_type, String? stage, int? responsible_id, String? responsible_name, double? amount, String? currency, String? pipeline, String? priority, String? description, String? created_at, String? updated_at, String? closed_at, bool? is_won, String? reg_fee_required, String? files_received, String? contact_status, String? files_asked, double? est_amount_work, String? create_invoice_share, double? expense_spent, String? upload_invoice_path, String? send_to_customer, String? register_no, double? invoice_amount, String? payment_type, String? drive_link, int? billing_id, int? quotation_id, double? payment_received, double? part_payment_amount, bool? noc_obtained, String? referred_by, String? expenses_list}) {
    return Deals._internal(
      id: id,
      name: name ?? this.name,
      client_id: client_id ?? this.client_id,
      client_name: client_name ?? this.client_name,
      contact_info: contact_info ?? this.contact_info,
      company: company ?? this.company,
      work_type: work_type ?? this.work_type,
      stage: stage ?? this.stage,
      responsible_id: responsible_id ?? this.responsible_id,
      responsible_name: responsible_name ?? this.responsible_name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      pipeline: pipeline ?? this.pipeline,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      closed_at: closed_at ?? this.closed_at,
      is_won: is_won ?? this.is_won,
      reg_fee_required: reg_fee_required ?? this.reg_fee_required,
      files_received: files_received ?? this.files_received,
      contact_status: contact_status ?? this.contact_status,
      files_asked: files_asked ?? this.files_asked,
      est_amount_work: est_amount_work ?? this.est_amount_work,
      create_invoice_share: create_invoice_share ?? this.create_invoice_share,
      expense_spent: expense_spent ?? this.expense_spent,
      upload_invoice_path: upload_invoice_path ?? this.upload_invoice_path,
      send_to_customer: send_to_customer ?? this.send_to_customer,
      register_no: register_no ?? this.register_no,
      invoice_amount: invoice_amount ?? this.invoice_amount,
      payment_type: payment_type ?? this.payment_type,
      drive_link: drive_link ?? this.drive_link,
      billing_id: billing_id ?? this.billing_id,
      quotation_id: quotation_id ?? this.quotation_id,
      payment_received: payment_received ?? this.payment_received,
      part_payment_amount: part_payment_amount ?? this.part_payment_amount,
      noc_obtained: noc_obtained ?? this.noc_obtained,
      referred_by: referred_by ?? this.referred_by,
      expenses_list: expenses_list ?? this.expenses_list);
  }
  
  Deals copyWithModelFieldValues({
    ModelFieldValue<String?>? name,
    ModelFieldValue<int?>? client_id,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? contact_info,
    ModelFieldValue<String?>? company,
    ModelFieldValue<String?>? work_type,
    ModelFieldValue<String?>? stage,
    ModelFieldValue<int?>? responsible_id,
    ModelFieldValue<String?>? responsible_name,
    ModelFieldValue<double?>? amount,
    ModelFieldValue<String?>? currency,
    ModelFieldValue<String?>? pipeline,
    ModelFieldValue<String?>? priority,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at,
    ModelFieldValue<String?>? closed_at,
    ModelFieldValue<bool?>? is_won,
    ModelFieldValue<String?>? reg_fee_required,
    ModelFieldValue<String?>? files_received,
    ModelFieldValue<String?>? contact_status,
    ModelFieldValue<String?>? files_asked,
    ModelFieldValue<double?>? est_amount_work,
    ModelFieldValue<String?>? create_invoice_share,
    ModelFieldValue<double?>? expense_spent,
    ModelFieldValue<String?>? upload_invoice_path,
    ModelFieldValue<String?>? send_to_customer,
    ModelFieldValue<String?>? register_no,
    ModelFieldValue<double?>? invoice_amount,
    ModelFieldValue<String?>? payment_type,
    ModelFieldValue<String?>? drive_link,
    ModelFieldValue<int?>? billing_id,
    ModelFieldValue<int?>? quotation_id,
    ModelFieldValue<double?>? payment_received,
    ModelFieldValue<double?>? part_payment_amount,
    ModelFieldValue<bool?>? noc_obtained,
    ModelFieldValue<String?>? referred_by,
    ModelFieldValue<String?>? expenses_list
  }) {
    return Deals._internal(
      id: id,
      name: name == null ? this.name : name.value,
      client_id: client_id == null ? this.client_id : client_id.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      contact_info: contact_info == null ? this.contact_info : contact_info.value,
      company: company == null ? this.company : company.value,
      work_type: work_type == null ? this.work_type : work_type.value,
      stage: stage == null ? this.stage : stage.value,
      responsible_id: responsible_id == null ? this.responsible_id : responsible_id.value,
      responsible_name: responsible_name == null ? this.responsible_name : responsible_name.value,
      amount: amount == null ? this.amount : amount.value,
      currency: currency == null ? this.currency : currency.value,
      pipeline: pipeline == null ? this.pipeline : pipeline.value,
      priority: priority == null ? this.priority : priority.value,
      description: description == null ? this.description : description.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value,
      closed_at: closed_at == null ? this.closed_at : closed_at.value,
      is_won: is_won == null ? this.is_won : is_won.value,
      reg_fee_required: reg_fee_required == null ? this.reg_fee_required : reg_fee_required.value,
      files_received: files_received == null ? this.files_received : files_received.value,
      contact_status: contact_status == null ? this.contact_status : contact_status.value,
      files_asked: files_asked == null ? this.files_asked : files_asked.value,
      est_amount_work: est_amount_work == null ? this.est_amount_work : est_amount_work.value,
      create_invoice_share: create_invoice_share == null ? this.create_invoice_share : create_invoice_share.value,
      expense_spent: expense_spent == null ? this.expense_spent : expense_spent.value,
      upload_invoice_path: upload_invoice_path == null ? this.upload_invoice_path : upload_invoice_path.value,
      send_to_customer: send_to_customer == null ? this.send_to_customer : send_to_customer.value,
      register_no: register_no == null ? this.register_no : register_no.value,
      invoice_amount: invoice_amount == null ? this.invoice_amount : invoice_amount.value,
      payment_type: payment_type == null ? this.payment_type : payment_type.value,
      drive_link: drive_link == null ? this.drive_link : drive_link.value,
      billing_id: billing_id == null ? this.billing_id : billing_id.value,
      quotation_id: quotation_id == null ? this.quotation_id : quotation_id.value,
      payment_received: payment_received == null ? this.payment_received : payment_received.value,
      part_payment_amount: part_payment_amount == null ? this.part_payment_amount : part_payment_amount.value,
      noc_obtained: noc_obtained == null ? this.noc_obtained : noc_obtained.value,
      referred_by: referred_by == null ? this.referred_by : referred_by.value,
      expenses_list: expenses_list == null ? this.expenses_list : expenses_list.value
    );
  }
  
  Deals.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _client_id = (json['client_id'] as num?)?.toInt(),
      _client_name = json['client_name'],
      _contact_info = json['contact_info'],
      _company = json['company'],
      _work_type = json['work_type'],
      _stage = json['stage'],
      _responsible_id = (json['responsible_id'] as num?)?.toInt(),
      _responsible_name = json['responsible_name'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _currency = json['currency'],
      _pipeline = json['pipeline'],
      _priority = json['priority'],
      _description = json['description'],
      _created_at = json['created_at'],
      _updated_at = json['updated_at'],
      _closed_at = json['closed_at'],
      _is_won = json['is_won'],
      _reg_fee_required = json['reg_fee_required'],
      _files_received = json['files_received'],
      _contact_status = json['contact_status'],
      _files_asked = json['files_asked'],
      _est_amount_work = (json['est_amount_work'] as num?)?.toDouble(),
      _create_invoice_share = json['create_invoice_share'],
      _expense_spent = (json['expense_spent'] as num?)?.toDouble(),
      _upload_invoice_path = json['upload_invoice_path'],
      _send_to_customer = json['send_to_customer'],
      _register_no = json['register_no'],
      _invoice_amount = (json['invoice_amount'] as num?)?.toDouble(),
      _payment_type = json['payment_type'],
      _drive_link = json['drive_link'],
      _billing_id = (json['billing_id'] as num?)?.toInt(),
      _quotation_id = (json['quotation_id'] as num?)?.toInt(),
      _payment_received = (json['payment_received'] as num?)?.toDouble(),
      _part_payment_amount = (json['part_payment_amount'] as num?)?.toDouble(),
      _noc_obtained = json['noc_obtained'],
      _referred_by = json['referred_by'],
      _expenses_list = json['expenses_list'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'client_id': _client_id, 'client_name': _client_name, 'contact_info': _contact_info, 'company': _company, 'work_type': _work_type, 'stage': _stage, 'responsible_id': _responsible_id, 'responsible_name': _responsible_name, 'amount': _amount, 'currency': _currency, 'pipeline': _pipeline, 'priority': _priority, 'description': _description, 'created_at': _created_at, 'updated_at': _updated_at, 'closed_at': _closed_at, 'is_won': _is_won, 'reg_fee_required': _reg_fee_required, 'files_received': _files_received, 'contact_status': _contact_status, 'files_asked': _files_asked, 'est_amount_work': _est_amount_work, 'create_invoice_share': _create_invoice_share, 'expense_spent': _expense_spent, 'upload_invoice_path': _upload_invoice_path, 'send_to_customer': _send_to_customer, 'register_no': _register_no, 'invoice_amount': _invoice_amount, 'payment_type': _payment_type, 'drive_link': _drive_link, 'billing_id': _billing_id, 'quotation_id': _quotation_id, 'payment_received': _payment_received, 'part_payment_amount': _part_payment_amount, 'noc_obtained': _noc_obtained, 'referred_by': _referred_by, 'expenses_list': _expenses_list, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'client_id': _client_id,
    'client_name': _client_name,
    'contact_info': _contact_info,
    'company': _company,
    'work_type': _work_type,
    'stage': _stage,
    'responsible_id': _responsible_id,
    'responsible_name': _responsible_name,
    'amount': _amount,
    'currency': _currency,
    'pipeline': _pipeline,
    'priority': _priority,
    'description': _description,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'closed_at': _closed_at,
    'is_won': _is_won,
    'reg_fee_required': _reg_fee_required,
    'files_received': _files_received,
    'contact_status': _contact_status,
    'files_asked': _files_asked,
    'est_amount_work': _est_amount_work,
    'create_invoice_share': _create_invoice_share,
    'expense_spent': _expense_spent,
    'upload_invoice_path': _upload_invoice_path,
    'send_to_customer': _send_to_customer,
    'register_no': _register_no,
    'invoice_amount': _invoice_amount,
    'payment_type': _payment_type,
    'drive_link': _drive_link,
    'billing_id': _billing_id,
    'quotation_id': _quotation_id,
    'payment_received': _payment_received,
    'part_payment_amount': _part_payment_amount,
    'noc_obtained': _noc_obtained,
    'referred_by': _referred_by,
    'expenses_list': _expenses_list,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DealsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DealsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final CLIENT_ID = amplify_core.QueryField(fieldName: "client_id");
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final CONTACT_INFO = amplify_core.QueryField(fieldName: "contact_info");
  static final COMPANY = amplify_core.QueryField(fieldName: "company");
  static final WORK_TYPE = amplify_core.QueryField(fieldName: "work_type");
  static final STAGE = amplify_core.QueryField(fieldName: "stage");
  static final RESPONSIBLE_ID = amplify_core.QueryField(fieldName: "responsible_id");
  static final RESPONSIBLE_NAME = amplify_core.QueryField(fieldName: "responsible_name");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final CURRENCY = amplify_core.QueryField(fieldName: "currency");
  static final PIPELINE = amplify_core.QueryField(fieldName: "pipeline");
  static final PRIORITY = amplify_core.QueryField(fieldName: "priority");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static final CLOSED_AT = amplify_core.QueryField(fieldName: "closed_at");
  static final IS_WON = amplify_core.QueryField(fieldName: "is_won");
  static final REG_FEE_REQUIRED = amplify_core.QueryField(fieldName: "reg_fee_required");
  static final FILES_RECEIVED = amplify_core.QueryField(fieldName: "files_received");
  static final CONTACT_STATUS = amplify_core.QueryField(fieldName: "contact_status");
  static final FILES_ASKED = amplify_core.QueryField(fieldName: "files_asked");
  static final EST_AMOUNT_WORK = amplify_core.QueryField(fieldName: "est_amount_work");
  static final CREATE_INVOICE_SHARE = amplify_core.QueryField(fieldName: "create_invoice_share");
  static final EXPENSE_SPENT = amplify_core.QueryField(fieldName: "expense_spent");
  static final UPLOAD_INVOICE_PATH = amplify_core.QueryField(fieldName: "upload_invoice_path");
  static final SEND_TO_CUSTOMER = amplify_core.QueryField(fieldName: "send_to_customer");
  static final REGISTER_NO = amplify_core.QueryField(fieldName: "register_no");
  static final INVOICE_AMOUNT = amplify_core.QueryField(fieldName: "invoice_amount");
  static final PAYMENT_TYPE = amplify_core.QueryField(fieldName: "payment_type");
  static final DRIVE_LINK = amplify_core.QueryField(fieldName: "drive_link");
  static final BILLING_ID = amplify_core.QueryField(fieldName: "billing_id");
  static final QUOTATION_ID = amplify_core.QueryField(fieldName: "quotation_id");
  static final PAYMENT_RECEIVED = amplify_core.QueryField(fieldName: "payment_received");
  static final PART_PAYMENT_AMOUNT = amplify_core.QueryField(fieldName: "part_payment_amount");
  static final NOC_OBTAINED = amplify_core.QueryField(fieldName: "noc_obtained");
  static final REFERRED_BY = amplify_core.QueryField(fieldName: "referred_by");
  static final EXPENSES_LIST = amplify_core.QueryField(fieldName: "expenses_list");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Deals";
    modelSchemaDefinition.pluralName = "Deals";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CLIENT_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CLIENT_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CONTACT_INFO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.COMPANY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.WORK_TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.STAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.RESPONSIBLE_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.RESPONSIBLE_NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CURRENCY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.PIPELINE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.PRIORITY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.UPDATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CLOSED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.IS_WON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.REG_FEE_REQUIRED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.FILES_RECEIVED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CONTACT_STATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.FILES_ASKED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.EST_AMOUNT_WORK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.CREATE_INVOICE_SHARE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.EXPENSE_SPENT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.UPLOAD_INVOICE_PATH,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.SEND_TO_CUSTOMER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.REGISTER_NO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.INVOICE_AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.PAYMENT_TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.DRIVE_LINK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.BILLING_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.QUOTATION_ID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.PAYMENT_RECEIVED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.PART_PAYMENT_AMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.NOC_OBTAINED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.REFERRED_BY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Deals.EXPENSES_LIST,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _DealsModelType extends amplify_core.ModelType<Deals> {
  const _DealsModelType();
  
  @override
  Deals fromJson(Map<String, dynamic> jsonData) {
    return Deals.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Deals';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Deals] in your schema.
 */
class DealsModelIdentifier implements amplify_core.ModelIdentifier<Deals> {
  final String id;

  /** Create an instance of DealsModelIdentifier using [id] the primary key. */
  const DealsModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'DealsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DealsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}