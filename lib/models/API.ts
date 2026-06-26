/* tslint:disable */
/* eslint-disable */
//  This file was automatically generated and should not be edited.

export type ActivityLogs = {
  __typename: "ActivityLogs",
  action?: string | null,
  createdAt: string,
  created_at?: string | null,
  details?: string | null,
  id: string,
  target_id?: string | null,
  target_type?: string | null,
  updatedAt: string,
  user_id?: number | null,
};

export type Billings = {
  __typename: "Billings",
  amount?: string | null,
  authorities?: string | null,
  category?: string | null,
  client_name?: string | null,
  createdAt: string,
  created_at?: string | null,
  data?: string | null,
  date?: string | null,
  id: string,
  invoice_no?: string | null,
  status?: string | null,
  type?: string | null,
  updatedAt: string,
};

export type Checklists = {
  __typename: "Checklists",
  createdAt: string,
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  manager_id?: number | null,
  reason?: string | null,
  remarks?: string | null,
  responsible_id?: number | null,
  status?: string | null,
  title?: string | null,
  updatedAt: string,
  updated_at?: string | null,
};

export type ClientDocuments = {
  __typename: "ClientDocuments",
  client_id?: string | null,
  client_name?: string | null,
  createdAt: string,
  created_at?: string | null,
  document_name?: string | null,
  id: string,
  og_copy?: string | null,
  remarks?: string | null,
  storage_path?: string | null,
  updatedAt: string,
};

export type ClientLicenses = {
  __typename: "ClientLicenses",
  client_id?: number | null,
  createdAt: string,
  created_at?: string | null,
  expiry_date?: string | null,
  file_no?: string | null,
  id: string,
  license_type_id?: number | null,
  manual_client_name?: string | null,
  notes?: string | null,
  service_date?: string | null,
  status?: string | null,
  updatedAt: string,
  updated_at?: string | null,
};

export type Clients = {
  __typename: "Clients",
  address?: string | null,
  balance_due?: string | null,
  case_number?: string | null,
  createdAt: string,
  created_at?: string | null,
  dob?: string | null,
  email?: string | null,
  file_date?: string | null,
  file_no?: string | null,
  id: string,
  is_contacted?: boolean | null,
  managed_by?: string | null,
  name?: string | null,
  phone?: string | null,
  review_rating?: number | null,
  type_of_work?: string | null,
  updatedAt: string,
};

export type CompanyBills = {
  __typename: "CompanyBills",
  amount?: number | null,
  bill_date?: string | null,
  category?: string | null,
  createdAt: string,
  created_at?: string | null,
  description?: string | null,
  id: string,
  spent_by?: number | null,
  spent_by_name?: string | null,
  status?: string | null,
  title?: string | null,
  updatedAt: string,
};

export type DealActivities = {
  __typename: "DealActivities",
  createdAt: string,
  created_at?: string | null,
  created_by?: number | null,
  deal_id?: number | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  is_completed?: boolean | null,
  title?: string | null,
  type?: string | null,
  updatedAt: string,
};

export type DealAssignees = {
  __typename: "DealAssignees",
  assigned_at?: string | null,
  createdAt: string,
  deal_id?: number | null,
  id: string,
  role?: string | null,
  updatedAt: string,
  user_id?: number | null,
};

export type DealHandoverHistory = {
  __typename: "DealHandoverHistory",
  createdAt: string,
  deal_id?: number | null,
  from_user_id?: number | null,
  handed_over_at?: string | null,
  id: string,
  note?: string | null,
  to_user_id?: number | null,
  updatedAt: string,
};

export type DealStageHistory = {
  __typename: "DealStageHistory",
  changed_at?: string | null,
  changed_by?: number | null,
  createdAt: string,
  deal_id?: number | null,
  from_stage?: string | null,
  id: string,
  to_stage?: string | null,
  updatedAt: string,
};

export type Deals = {
  __typename: "Deals",
  amount?: number | null,
  billing_id?: number | null,
  client_id?: number | null,
  client_name?: string | null,
  closed_at?: string | null,
  company?: string | null,
  contact_info?: string | null,
  contact_status?: string | null,
  create_invoice_share?: string | null,
  createdAt: string,
  created_at?: string | null,
  currency?: string | null,
  description?: string | null,
  drive_link?: string | null,
  est_amount_work?: number | null,
  expense_spent?: number | null,
  expenses_list?: string | null,
  files_asked?: string | null,
  files_received?: string | null,
  id: string,
  invoice_amount?: number | null,
  is_won?: boolean | null,
  name?: string | null,
  noc_obtained?: boolean | null,
  part_payment_amount?: number | null,
  payment_received?: number | null,
  payment_type?: string | null,
  pipeline?: string | null,
  priority?: string | null,
  quotation_id?: number | null,
  referred_by?: string | null,
  reg_fee_required?: string | null,
  register_no?: string | null,
  responsible_id?: number | null,
  responsible_name?: string | null,
  send_to_customer?: string | null,
  stage?: string | null,
  updatedAt: string,
  updated_at?: string | null,
  upload_invoice_path?: string | null,
  work_type?: string | null,
};

export type DscRecords = {
  __typename: "DscRecords",
  client_name?: string | null,
  createdAt: string,
  created_at?: string | null,
  dsc_expiry_date?: string | null,
  dsc_taken_date?: string | null,
  email_id?: string | null,
  id: string,
  password?: string | null,
  phone_no?: string | null,
  updatedAt: string,
  updated_at?: string | null,
  username?: string | null,
};

export type InwardPosts = {
  __typename: "InwardPosts",
  createdAt: string,
  created_at?: string | null,
  description?: string | null,
  id: string,
  received_by?: string | null,
  received_date?: string | null,
  recipient_name?: string | null,
  sender_name?: string | null,
  status?: string | null,
  updatedAt: string,
};

export type LicenseBilling = {
  __typename: "LicenseBilling",
  amount?: number | null,
  client_license_id?: number | null,
  createdAt: string,
  created_at?: string | null,
  id: string,
  invoice_no?: string | null,
  payment_date?: string | null,
  payment_status?: string | null,
  updatedAt: string,
};

export type LicenseNotifications = {
  __typename: "LicenseNotifications",
  client_license_id?: number | null,
  createdAt: string,
  created_at?: string | null,
  id: string,
  is_sent?: boolean | null,
  message?: string | null,
  notification_type?: string | null,
  scheduled_date?: string | null,
  updatedAt: string,
};

export type LicenseServices = {
  __typename: "LicenseServices",
  client_license_id?: number | null,
  createdAt: string,
  created_at?: string | null,
  id: string,
  service_cost?: number | null,
  service_date?: string | null,
  service_description?: string | null,
  updatedAt: string,
};

export type LicenseTypes = {
  __typename: "LicenseTypes",
  createdAt: string,
  created_at?: string | null,
  description?: string | null,
  id: string,
  name?: string | null,
  updatedAt: string,
  updated_at?: string | null,
};

export type LocationHistory = {
  __typename: "LocationHistory",
  createdAt: string,
  id: string,
  latitude?: number | null,
  longitude?: number | null,
  recorded_at?: string | null,
  updatedAt: string,
  user_id?: number | null,
};

export type Messages = {
  __typename: "Messages",
  attachment_id?: number | null,
  attachment_type?: string | null,
  content?: string | null,
  createdAt: string,
  created_at?: string | null,
  id: string,
  is_read?: boolean | null,
  receiver_id?: number | null,
  sender_id?: number | null,
  updatedAt: string,
};

export type Notifications = {
  __typename: "Notifications",
  createdAt: string,
  created_at?: string | null,
  deal_id?: number | null,
  id: string,
  is_read?: boolean | null,
  message?: string | null,
  task_id?: number | null,
  title?: string | null,
  type?: string | null,
  updatedAt: string,
  user_id?: number | null,
};

export type ServiceContent = {
  __typename: "ServiceContent",
  createdAt: string,
  description?: string | null,
  details?: string | null,
  id: string,
  image_path?: string | null,
  service_id?: number | null,
  title?: string | null,
  updatedAt: string,
};

export type ServiceNames = {
  __typename: "ServiceNames",
  createdAt: string,
  created_at?: string | null,
  id: string,
  name?: string | null,
  updatedAt: string,
};

export type StaffAttendance = {
  __typename: "StaffAttendance",
  attendance_date?: string | null,
  check_in_time?: string | null,
  check_out_time?: string | null,
  createdAt: string,
  id: string,
  updatedAt: string,
  user_id?: number | null,
};

export type StaffLocations = {
  __typename: "StaffLocations",
  createdAt: string,
  id: string,
  latitude?: number | null,
  longitude?: number | null,
  updatedAt: string,
  updated_at?: string | null,
  user_id?: number | null,
};

export type SysCronLogs = {
  __typename: "SysCronLogs",
  createdAt: string,
  id: string,
  job_name?: string | null,
  last_run_date?: string | null,
  updatedAt: string,
};

export type Tasks = {
  __typename: "Tasks",
  assigned_by?: number | null,
  assigned_to?: number | null,
  client_name?: string | null,
  createdAt: string,
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  location?: string | null,
  phone_number?: string | null,
  status?: string | null,
  title?: string | null,
  updatedAt: string,
  updated_at?: string | null,
};

export type TravelLogs = {
  __typename: "TravelLogs",
  createdAt: string,
  created_at?: string | null,
  destination?: string | null,
  id: string,
  updatedAt: string,
  user_id?: number | null,
};

export type UserSessions = {
  __typename: "UserSessions",
  active_seconds?: number | null,
  createdAt: string,
  id: string,
  idle_seconds?: number | null,
  ip_address?: string | null,
  is_active?: boolean | null,
  login_time?: string | null,
  logout_time?: string | null,
  status?: string | null,
  updatedAt: string,
  user_id?: number | null,
};

export type Users = {
  __typename: "Users",
  createdAt: string,
  created_at?: string | null,
  email?: string | null,
  id: string,
  last_seen?: string | null,
  name?: string | null,
  password?: string | null,
  role?: string | null,
  updatedAt: string,
  username?: string | null,
};

export type ModelActivityLogsFilterInput = {
  action?: ModelStringInput | null,
  and?: Array< ModelActivityLogsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  details?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelActivityLogsFilterInput | null,
  or?: Array< ModelActivityLogsFilterInput | null > | null,
  target_id?: ModelStringInput | null,
  target_type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelStringInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  size?: ModelSizeInput | null,
};

export enum ModelAttributeTypes {
  _null = "_null",
  binary = "binary",
  binarySet = "binarySet",
  bool = "bool",
  list = "list",
  map = "map",
  number = "number",
  numberSet = "numberSet",
  string = "string",
  stringSet = "stringSet",
}


export type ModelSizeInput = {
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
};

export type ModelIDInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  size?: ModelSizeInput | null,
};

export type ModelIntInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
};

export enum ModelSortDirection {
  ASC = "ASC",
  DESC = "DESC",
}


export type ModelActivityLogsConnection = {
  __typename: "ModelActivityLogsConnection",
  items:  Array<ActivityLogs | null >,
  nextToken?: string | null,
};

export type ModelBillingsFilterInput = {
  amount?: ModelStringInput | null,
  and?: Array< ModelBillingsFilterInput | null > | null,
  authorities?: ModelStringInput | null,
  category?: ModelStringInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  data?: ModelStringInput | null,
  date?: ModelStringInput | null,
  id?: ModelIDInput | null,
  invoice_no?: ModelStringInput | null,
  not?: ModelBillingsFilterInput | null,
  or?: Array< ModelBillingsFilterInput | null > | null,
  status?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelBillingsConnection = {
  __typename: "ModelBillingsConnection",
  items:  Array<Billings | null >,
  nextToken?: string | null,
};

export type ModelChecklistsFilterInput = {
  and?: Array< ModelChecklistsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  id?: ModelIDInput | null,
  manager_id?: ModelIntInput | null,
  not?: ModelChecklistsFilterInput | null,
  or?: Array< ModelChecklistsFilterInput | null > | null,
  reason?: ModelStringInput | null,
  remarks?: ModelStringInput | null,
  responsible_id?: ModelIntInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type ModelChecklistsConnection = {
  __typename: "ModelChecklistsConnection",
  items:  Array<Checklists | null >,
  nextToken?: string | null,
};

export type ModelClientDocumentsFilterInput = {
  and?: Array< ModelClientDocumentsFilterInput | null > | null,
  client_id?: ModelStringInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  document_name?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelClientDocumentsFilterInput | null,
  og_copy?: ModelStringInput | null,
  or?: Array< ModelClientDocumentsFilterInput | null > | null,
  remarks?: ModelStringInput | null,
  storage_path?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelClientDocumentsConnection = {
  __typename: "ModelClientDocumentsConnection",
  items:  Array<ClientDocuments | null >,
  nextToken?: string | null,
};

export type ModelClientLicensesFilterInput = {
  and?: Array< ModelClientLicensesFilterInput | null > | null,
  client_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  expiry_date?: ModelStringInput | null,
  file_no?: ModelStringInput | null,
  id?: ModelIDInput | null,
  license_type_id?: ModelIntInput | null,
  manual_client_name?: ModelStringInput | null,
  not?: ModelClientLicensesFilterInput | null,
  notes?: ModelStringInput | null,
  or?: Array< ModelClientLicensesFilterInput | null > | null,
  service_date?: ModelStringInput | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type ModelClientLicensesConnection = {
  __typename: "ModelClientLicensesConnection",
  items:  Array<ClientLicenses | null >,
  nextToken?: string | null,
};

export type ModelClientsFilterInput = {
  address?: ModelStringInput | null,
  and?: Array< ModelClientsFilterInput | null > | null,
  balance_due?: ModelStringInput | null,
  case_number?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  dob?: ModelStringInput | null,
  email?: ModelStringInput | null,
  file_date?: ModelStringInput | null,
  file_no?: ModelStringInput | null,
  id?: ModelIDInput | null,
  is_contacted?: ModelBooleanInput | null,
  managed_by?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelClientsFilterInput | null,
  or?: Array< ModelClientsFilterInput | null > | null,
  phone?: ModelStringInput | null,
  review_rating?: ModelIntInput | null,
  type_of_work?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelBooleanInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  eq?: boolean | null,
  ne?: boolean | null,
};

export type ModelClientsConnection = {
  __typename: "ModelClientsConnection",
  items:  Array<Clients | null >,
  nextToken?: string | null,
};

export type ModelCompanyBillsFilterInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelCompanyBillsFilterInput | null > | null,
  bill_date?: ModelStringInput | null,
  category?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelCompanyBillsFilterInput | null,
  or?: Array< ModelCompanyBillsFilterInput | null > | null,
  spent_by?: ModelIntInput | null,
  spent_by_name?: ModelStringInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelFloatInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
};

export type ModelCompanyBillsConnection = {
  __typename: "ModelCompanyBillsConnection",
  items:  Array<CompanyBills | null >,
  nextToken?: string | null,
};

export type ModelDealActivitiesFilterInput = {
  and?: Array< ModelDealActivitiesFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  created_by?: ModelIntInput | null,
  deal_id?: ModelIntInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  id?: ModelIDInput | null,
  is_completed?: ModelBooleanInput | null,
  not?: ModelDealActivitiesFilterInput | null,
  or?: Array< ModelDealActivitiesFilterInput | null > | null,
  title?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelDealActivitiesConnection = {
  __typename: "ModelDealActivitiesConnection",
  items:  Array<DealActivities | null >,
  nextToken?: string | null,
};

export type ModelDealAssigneesFilterInput = {
  and?: Array< ModelDealAssigneesFilterInput | null > | null,
  assigned_at?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  id?: ModelIDInput | null,
  not?: ModelDealAssigneesFilterInput | null,
  or?: Array< ModelDealAssigneesFilterInput | null > | null,
  role?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelDealAssigneesConnection = {
  __typename: "ModelDealAssigneesConnection",
  items:  Array<DealAssignees | null >,
  nextToken?: string | null,
};

export type ModelDealHandoverHistoryFilterInput = {
  and?: Array< ModelDealHandoverHistoryFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  from_user_id?: ModelIntInput | null,
  handed_over_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelDealHandoverHistoryFilterInput | null,
  note?: ModelStringInput | null,
  or?: Array< ModelDealHandoverHistoryFilterInput | null > | null,
  to_user_id?: ModelIntInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelDealHandoverHistoryConnection = {
  __typename: "ModelDealHandoverHistoryConnection",
  items:  Array<DealHandoverHistory | null >,
  nextToken?: string | null,
};

export type ModelDealStageHistoryFilterInput = {
  and?: Array< ModelDealStageHistoryFilterInput | null > | null,
  changed_at?: ModelStringInput | null,
  changed_by?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  from_stage?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelDealStageHistoryFilterInput | null,
  or?: Array< ModelDealStageHistoryFilterInput | null > | null,
  to_stage?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelDealStageHistoryConnection = {
  __typename: "ModelDealStageHistoryConnection",
  items:  Array<DealStageHistory | null >,
  nextToken?: string | null,
};

export type ModelDealsFilterInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelDealsFilterInput | null > | null,
  billing_id?: ModelIntInput | null,
  client_id?: ModelIntInput | null,
  client_name?: ModelStringInput | null,
  closed_at?: ModelStringInput | null,
  company?: ModelStringInput | null,
  contact_info?: ModelStringInput | null,
  contact_status?: ModelStringInput | null,
  create_invoice_share?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  currency?: ModelStringInput | null,
  description?: ModelStringInput | null,
  drive_link?: ModelStringInput | null,
  est_amount_work?: ModelFloatInput | null,
  expense_spent?: ModelFloatInput | null,
  expenses_list?: ModelStringInput | null,
  files_asked?: ModelStringInput | null,
  files_received?: ModelStringInput | null,
  id?: ModelIDInput | null,
  invoice_amount?: ModelFloatInput | null,
  is_won?: ModelBooleanInput | null,
  name?: ModelStringInput | null,
  noc_obtained?: ModelBooleanInput | null,
  not?: ModelDealsFilterInput | null,
  or?: Array< ModelDealsFilterInput | null > | null,
  part_payment_amount?: ModelFloatInput | null,
  payment_received?: ModelFloatInput | null,
  payment_type?: ModelStringInput | null,
  pipeline?: ModelStringInput | null,
  priority?: ModelStringInput | null,
  quotation_id?: ModelIntInput | null,
  referred_by?: ModelStringInput | null,
  reg_fee_required?: ModelStringInput | null,
  register_no?: ModelStringInput | null,
  responsible_id?: ModelIntInput | null,
  responsible_name?: ModelStringInput | null,
  send_to_customer?: ModelStringInput | null,
  stage?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  upload_invoice_path?: ModelStringInput | null,
  work_type?: ModelStringInput | null,
};

export type ModelDealsConnection = {
  __typename: "ModelDealsConnection",
  items:  Array<Deals | null >,
  nextToken?: string | null,
};

export type ModelDscRecordsFilterInput = {
  and?: Array< ModelDscRecordsFilterInput | null > | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  dsc_expiry_date?: ModelStringInput | null,
  dsc_taken_date?: ModelStringInput | null,
  email_id?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelDscRecordsFilterInput | null,
  or?: Array< ModelDscRecordsFilterInput | null > | null,
  password?: ModelStringInput | null,
  phone_no?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type ModelDscRecordsConnection = {
  __typename: "ModelDscRecordsConnection",
  items:  Array<DscRecords | null >,
  nextToken?: string | null,
};

export type ModelInwardPostsFilterInput = {
  and?: Array< ModelInwardPostsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelInwardPostsFilterInput | null,
  or?: Array< ModelInwardPostsFilterInput | null > | null,
  received_by?: ModelStringInput | null,
  received_date?: ModelStringInput | null,
  recipient_name?: ModelStringInput | null,
  sender_name?: ModelStringInput | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelInwardPostsConnection = {
  __typename: "ModelInwardPostsConnection",
  items:  Array<InwardPosts | null >,
  nextToken?: string | null,
};

export type ModelLicenseBillingFilterInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelLicenseBillingFilterInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  invoice_no?: ModelStringInput | null,
  not?: ModelLicenseBillingFilterInput | null,
  or?: Array< ModelLicenseBillingFilterInput | null > | null,
  payment_date?: ModelStringInput | null,
  payment_status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelLicenseBillingConnection = {
  __typename: "ModelLicenseBillingConnection",
  items:  Array<LicenseBilling | null >,
  nextToken?: string | null,
};

export type ModelLicenseNotificationsFilterInput = {
  and?: Array< ModelLicenseNotificationsFilterInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  is_sent?: ModelBooleanInput | null,
  message?: ModelStringInput | null,
  not?: ModelLicenseNotificationsFilterInput | null,
  notification_type?: ModelStringInput | null,
  or?: Array< ModelLicenseNotificationsFilterInput | null > | null,
  scheduled_date?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelLicenseNotificationsConnection = {
  __typename: "ModelLicenseNotificationsConnection",
  items:  Array<LicenseNotifications | null >,
  nextToken?: string | null,
};

export type ModelLicenseServicesFilterInput = {
  and?: Array< ModelLicenseServicesFilterInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelLicenseServicesFilterInput | null,
  or?: Array< ModelLicenseServicesFilterInput | null > | null,
  service_cost?: ModelFloatInput | null,
  service_date?: ModelStringInput | null,
  service_description?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelLicenseServicesConnection = {
  __typename: "ModelLicenseServicesConnection",
  items:  Array<LicenseServices | null >,
  nextToken?: string | null,
};

export type ModelLicenseTypesFilterInput = {
  and?: Array< ModelLicenseTypesFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  id?: ModelIDInput | null,
  name?: ModelStringInput | null,
  not?: ModelLicenseTypesFilterInput | null,
  or?: Array< ModelLicenseTypesFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type ModelLicenseTypesConnection = {
  __typename: "ModelLicenseTypesConnection",
  items:  Array<LicenseTypes | null >,
  nextToken?: string | null,
};

export type ModelLocationHistoryFilterInput = {
  and?: Array< ModelLocationHistoryFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  id?: ModelIDInput | null,
  latitude?: ModelFloatInput | null,
  longitude?: ModelFloatInput | null,
  not?: ModelLocationHistoryFilterInput | null,
  or?: Array< ModelLocationHistoryFilterInput | null > | null,
  recorded_at?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelLocationHistoryConnection = {
  __typename: "ModelLocationHistoryConnection",
  items:  Array<LocationHistory | null >,
  nextToken?: string | null,
};

export type ModelMessagesFilterInput = {
  and?: Array< ModelMessagesFilterInput | null > | null,
  attachment_id?: ModelIntInput | null,
  attachment_type?: ModelStringInput | null,
  content?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  is_read?: ModelBooleanInput | null,
  not?: ModelMessagesFilterInput | null,
  or?: Array< ModelMessagesFilterInput | null > | null,
  receiver_id?: ModelIntInput | null,
  sender_id?: ModelIntInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelMessagesConnection = {
  __typename: "ModelMessagesConnection",
  items:  Array<Messages | null >,
  nextToken?: string | null,
};

export type ModelNotificationsFilterInput = {
  and?: Array< ModelNotificationsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  id?: ModelIDInput | null,
  is_read?: ModelBooleanInput | null,
  message?: ModelStringInput | null,
  not?: ModelNotificationsFilterInput | null,
  or?: Array< ModelNotificationsFilterInput | null > | null,
  task_id?: ModelIntInput | null,
  title?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelNotificationsConnection = {
  __typename: "ModelNotificationsConnection",
  items:  Array<Notifications | null >,
  nextToken?: string | null,
};

export type ModelServiceContentFilterInput = {
  and?: Array< ModelServiceContentFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  description?: ModelStringInput | null,
  details?: ModelStringInput | null,
  id?: ModelIDInput | null,
  image_path?: ModelStringInput | null,
  not?: ModelServiceContentFilterInput | null,
  or?: Array< ModelServiceContentFilterInput | null > | null,
  service_id?: ModelIntInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelServiceContentConnection = {
  __typename: "ModelServiceContentConnection",
  items:  Array<ServiceContent | null >,
  nextToken?: string | null,
};

export type ModelServiceNamesFilterInput = {
  and?: Array< ModelServiceNamesFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  id?: ModelIDInput | null,
  name?: ModelStringInput | null,
  not?: ModelServiceNamesFilterInput | null,
  or?: Array< ModelServiceNamesFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelServiceNamesConnection = {
  __typename: "ModelServiceNamesConnection",
  items:  Array<ServiceNames | null >,
  nextToken?: string | null,
};

export type ModelStaffAttendanceFilterInput = {
  and?: Array< ModelStaffAttendanceFilterInput | null > | null,
  attendance_date?: ModelStringInput | null,
  check_in_time?: ModelStringInput | null,
  check_out_time?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelStaffAttendanceFilterInput | null,
  or?: Array< ModelStaffAttendanceFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelStaffAttendanceConnection = {
  __typename: "ModelStaffAttendanceConnection",
  items:  Array<StaffAttendance | null >,
  nextToken?: string | null,
};

export type ModelStaffLocationsFilterInput = {
  and?: Array< ModelStaffLocationsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  id?: ModelIDInput | null,
  latitude?: ModelFloatInput | null,
  longitude?: ModelFloatInput | null,
  not?: ModelStaffLocationsFilterInput | null,
  or?: Array< ModelStaffLocationsFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelStaffLocationsConnection = {
  __typename: "ModelStaffLocationsConnection",
  items:  Array<StaffLocations | null >,
  nextToken?: string | null,
};

export type ModelSysCronLogsFilterInput = {
  and?: Array< ModelSysCronLogsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  id?: ModelIDInput | null,
  job_name?: ModelStringInput | null,
  last_run_date?: ModelStringInput | null,
  not?: ModelSysCronLogsFilterInput | null,
  or?: Array< ModelSysCronLogsFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
};

export type ModelSysCronLogsConnection = {
  __typename: "ModelSysCronLogsConnection",
  items:  Array<SysCronLogs | null >,
  nextToken?: string | null,
};

export type ModelTasksFilterInput = {
  and?: Array< ModelTasksFilterInput | null > | null,
  assigned_by?: ModelIntInput | null,
  assigned_to?: ModelIntInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  id?: ModelIDInput | null,
  location?: ModelStringInput | null,
  not?: ModelTasksFilterInput | null,
  or?: Array< ModelTasksFilterInput | null > | null,
  phone_number?: ModelStringInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type ModelTasksConnection = {
  __typename: "ModelTasksConnection",
  items:  Array<Tasks | null >,
  nextToken?: string | null,
};

export type ModelTravelLogsFilterInput = {
  and?: Array< ModelTravelLogsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  destination?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelTravelLogsFilterInput | null,
  or?: Array< ModelTravelLogsFilterInput | null > | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelTravelLogsConnection = {
  __typename: "ModelTravelLogsConnection",
  items:  Array<TravelLogs | null >,
  nextToken?: string | null,
};

export type ModelUserSessionsFilterInput = {
  active_seconds?: ModelIntInput | null,
  and?: Array< ModelUserSessionsFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  id?: ModelIDInput | null,
  idle_seconds?: ModelIntInput | null,
  ip_address?: ModelStringInput | null,
  is_active?: ModelBooleanInput | null,
  login_time?: ModelStringInput | null,
  logout_time?: ModelStringInput | null,
  not?: ModelUserSessionsFilterInput | null,
  or?: Array< ModelUserSessionsFilterInput | null > | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type ModelUserSessionsConnection = {
  __typename: "ModelUserSessionsConnection",
  items:  Array<UserSessions | null >,
  nextToken?: string | null,
};

export type ModelUsersFilterInput = {
  and?: Array< ModelUsersFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  email?: ModelStringInput | null,
  id?: ModelIDInput | null,
  last_seen?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelUsersFilterInput | null,
  or?: Array< ModelUsersFilterInput | null > | null,
  password?: ModelStringInput | null,
  role?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type ModelUsersConnection = {
  __typename: "ModelUsersConnection",
  items:  Array<Users | null >,
  nextToken?: string | null,
};

export type ModelActivityLogsConditionInput = {
  action?: ModelStringInput | null,
  and?: Array< ModelActivityLogsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  details?: ModelStringInput | null,
  not?: ModelActivityLogsConditionInput | null,
  or?: Array< ModelActivityLogsConditionInput | null > | null,
  target_id?: ModelStringInput | null,
  target_type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateActivityLogsInput = {
  action?: string | null,
  created_at?: string | null,
  details?: string | null,
  id?: string | null,
  target_id?: string | null,
  target_type?: string | null,
  user_id?: number | null,
};

export type ModelBillingsConditionInput = {
  amount?: ModelStringInput | null,
  and?: Array< ModelBillingsConditionInput | null > | null,
  authorities?: ModelStringInput | null,
  category?: ModelStringInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  data?: ModelStringInput | null,
  date?: ModelStringInput | null,
  invoice_no?: ModelStringInput | null,
  not?: ModelBillingsConditionInput | null,
  or?: Array< ModelBillingsConditionInput | null > | null,
  status?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateBillingsInput = {
  amount?: string | null,
  authorities?: string | null,
  category?: string | null,
  client_name?: string | null,
  created_at?: string | null,
  data?: string | null,
  date?: string | null,
  id?: string | null,
  invoice_no?: string | null,
  status?: string | null,
  type?: string | null,
};

export type ModelChecklistsConditionInput = {
  and?: Array< ModelChecklistsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  manager_id?: ModelIntInput | null,
  not?: ModelChecklistsConditionInput | null,
  or?: Array< ModelChecklistsConditionInput | null > | null,
  reason?: ModelStringInput | null,
  remarks?: ModelStringInput | null,
  responsible_id?: ModelIntInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type CreateChecklistsInput = {
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id?: string | null,
  manager_id?: number | null,
  reason?: string | null,
  remarks?: string | null,
  responsible_id?: number | null,
  status?: string | null,
  title?: string | null,
  updated_at?: string | null,
};

export type ModelClientDocumentsConditionInput = {
  and?: Array< ModelClientDocumentsConditionInput | null > | null,
  client_id?: ModelStringInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  document_name?: ModelStringInput | null,
  not?: ModelClientDocumentsConditionInput | null,
  og_copy?: ModelStringInput | null,
  or?: Array< ModelClientDocumentsConditionInput | null > | null,
  remarks?: ModelStringInput | null,
  storage_path?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateClientDocumentsInput = {
  client_id?: string | null,
  client_name?: string | null,
  created_at?: string | null,
  document_name?: string | null,
  id?: string | null,
  og_copy?: string | null,
  remarks?: string | null,
  storage_path?: string | null,
};

export type ModelClientLicensesConditionInput = {
  and?: Array< ModelClientLicensesConditionInput | null > | null,
  client_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  expiry_date?: ModelStringInput | null,
  file_no?: ModelStringInput | null,
  license_type_id?: ModelIntInput | null,
  manual_client_name?: ModelStringInput | null,
  not?: ModelClientLicensesConditionInput | null,
  notes?: ModelStringInput | null,
  or?: Array< ModelClientLicensesConditionInput | null > | null,
  service_date?: ModelStringInput | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type CreateClientLicensesInput = {
  client_id?: number | null,
  created_at?: string | null,
  expiry_date?: string | null,
  file_no?: string | null,
  id?: string | null,
  license_type_id?: number | null,
  manual_client_name?: string | null,
  notes?: string | null,
  service_date?: string | null,
  status?: string | null,
  updated_at?: string | null,
};

export type ModelClientsConditionInput = {
  address?: ModelStringInput | null,
  and?: Array< ModelClientsConditionInput | null > | null,
  balance_due?: ModelStringInput | null,
  case_number?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  dob?: ModelStringInput | null,
  email?: ModelStringInput | null,
  file_date?: ModelStringInput | null,
  file_no?: ModelStringInput | null,
  is_contacted?: ModelBooleanInput | null,
  managed_by?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelClientsConditionInput | null,
  or?: Array< ModelClientsConditionInput | null > | null,
  phone?: ModelStringInput | null,
  review_rating?: ModelIntInput | null,
  type_of_work?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateClientsInput = {
  address?: string | null,
  balance_due?: string | null,
  case_number?: string | null,
  created_at?: string | null,
  dob?: string | null,
  email?: string | null,
  file_date?: string | null,
  file_no?: string | null,
  id?: string | null,
  is_contacted?: boolean | null,
  managed_by?: string | null,
  name?: string | null,
  phone?: string | null,
  review_rating?: number | null,
  type_of_work?: string | null,
};

export type ModelCompanyBillsConditionInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelCompanyBillsConditionInput | null > | null,
  bill_date?: ModelStringInput | null,
  category?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  not?: ModelCompanyBillsConditionInput | null,
  or?: Array< ModelCompanyBillsConditionInput | null > | null,
  spent_by?: ModelIntInput | null,
  spent_by_name?: ModelStringInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateCompanyBillsInput = {
  amount?: number | null,
  bill_date?: string | null,
  category?: string | null,
  created_at?: string | null,
  description?: string | null,
  id?: string | null,
  spent_by?: number | null,
  spent_by_name?: string | null,
  status?: string | null,
  title?: string | null,
};

export type ModelDealActivitiesConditionInput = {
  and?: Array< ModelDealActivitiesConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  created_by?: ModelIntInput | null,
  deal_id?: ModelIntInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  is_completed?: ModelBooleanInput | null,
  not?: ModelDealActivitiesConditionInput | null,
  or?: Array< ModelDealActivitiesConditionInput | null > | null,
  title?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateDealActivitiesInput = {
  created_at?: string | null,
  created_by?: number | null,
  deal_id?: number | null,
  description?: string | null,
  due_date?: string | null,
  id?: string | null,
  is_completed?: boolean | null,
  title?: string | null,
  type?: string | null,
};

export type ModelDealAssigneesConditionInput = {
  and?: Array< ModelDealAssigneesConditionInput | null > | null,
  assigned_at?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  not?: ModelDealAssigneesConditionInput | null,
  or?: Array< ModelDealAssigneesConditionInput | null > | null,
  role?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateDealAssigneesInput = {
  assigned_at?: string | null,
  deal_id?: number | null,
  id?: string | null,
  role?: string | null,
  user_id?: number | null,
};

export type ModelDealHandoverHistoryConditionInput = {
  and?: Array< ModelDealHandoverHistoryConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  from_user_id?: ModelIntInput | null,
  handed_over_at?: ModelStringInput | null,
  not?: ModelDealHandoverHistoryConditionInput | null,
  note?: ModelStringInput | null,
  or?: Array< ModelDealHandoverHistoryConditionInput | null > | null,
  to_user_id?: ModelIntInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateDealHandoverHistoryInput = {
  deal_id?: number | null,
  from_user_id?: number | null,
  handed_over_at?: string | null,
  id?: string | null,
  note?: string | null,
  to_user_id?: number | null,
};

export type ModelDealStageHistoryConditionInput = {
  and?: Array< ModelDealStageHistoryConditionInput | null > | null,
  changed_at?: ModelStringInput | null,
  changed_by?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  from_stage?: ModelStringInput | null,
  not?: ModelDealStageHistoryConditionInput | null,
  or?: Array< ModelDealStageHistoryConditionInput | null > | null,
  to_stage?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateDealStageHistoryInput = {
  changed_at?: string | null,
  changed_by?: number | null,
  deal_id?: number | null,
  from_stage?: string | null,
  id?: string | null,
  to_stage?: string | null,
};

export type ModelDealsConditionInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelDealsConditionInput | null > | null,
  billing_id?: ModelIntInput | null,
  client_id?: ModelIntInput | null,
  client_name?: ModelStringInput | null,
  closed_at?: ModelStringInput | null,
  company?: ModelStringInput | null,
  contact_info?: ModelStringInput | null,
  contact_status?: ModelStringInput | null,
  create_invoice_share?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  currency?: ModelStringInput | null,
  description?: ModelStringInput | null,
  drive_link?: ModelStringInput | null,
  est_amount_work?: ModelFloatInput | null,
  expense_spent?: ModelFloatInput | null,
  expenses_list?: ModelStringInput | null,
  files_asked?: ModelStringInput | null,
  files_received?: ModelStringInput | null,
  invoice_amount?: ModelFloatInput | null,
  is_won?: ModelBooleanInput | null,
  name?: ModelStringInput | null,
  noc_obtained?: ModelBooleanInput | null,
  not?: ModelDealsConditionInput | null,
  or?: Array< ModelDealsConditionInput | null > | null,
  part_payment_amount?: ModelFloatInput | null,
  payment_received?: ModelFloatInput | null,
  payment_type?: ModelStringInput | null,
  pipeline?: ModelStringInput | null,
  priority?: ModelStringInput | null,
  quotation_id?: ModelIntInput | null,
  referred_by?: ModelStringInput | null,
  reg_fee_required?: ModelStringInput | null,
  register_no?: ModelStringInput | null,
  responsible_id?: ModelIntInput | null,
  responsible_name?: ModelStringInput | null,
  send_to_customer?: ModelStringInput | null,
  stage?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  upload_invoice_path?: ModelStringInput | null,
  work_type?: ModelStringInput | null,
};

export type CreateDealsInput = {
  amount?: number | null,
  billing_id?: number | null,
  client_id?: number | null,
  client_name?: string | null,
  closed_at?: string | null,
  company?: string | null,
  contact_info?: string | null,
  contact_status?: string | null,
  create_invoice_share?: string | null,
  created_at?: string | null,
  currency?: string | null,
  description?: string | null,
  drive_link?: string | null,
  est_amount_work?: number | null,
  expense_spent?: number | null,
  expenses_list?: string | null,
  files_asked?: string | null,
  files_received?: string | null,
  id?: string | null,
  invoice_amount?: number | null,
  is_won?: boolean | null,
  name?: string | null,
  noc_obtained?: boolean | null,
  part_payment_amount?: number | null,
  payment_received?: number | null,
  payment_type?: string | null,
  pipeline?: string | null,
  priority?: string | null,
  quotation_id?: number | null,
  referred_by?: string | null,
  reg_fee_required?: string | null,
  register_no?: string | null,
  responsible_id?: number | null,
  responsible_name?: string | null,
  send_to_customer?: string | null,
  stage?: string | null,
  updated_at?: string | null,
  upload_invoice_path?: string | null,
  work_type?: string | null,
};

export type ModelDscRecordsConditionInput = {
  and?: Array< ModelDscRecordsConditionInput | null > | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  dsc_expiry_date?: ModelStringInput | null,
  dsc_taken_date?: ModelStringInput | null,
  email_id?: ModelStringInput | null,
  not?: ModelDscRecordsConditionInput | null,
  or?: Array< ModelDscRecordsConditionInput | null > | null,
  password?: ModelStringInput | null,
  phone_no?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type CreateDscRecordsInput = {
  client_name?: string | null,
  created_at?: string | null,
  dsc_expiry_date?: string | null,
  dsc_taken_date?: string | null,
  email_id?: string | null,
  id?: string | null,
  password?: string | null,
  phone_no?: string | null,
  updated_at?: string | null,
  username?: string | null,
};

export type ModelInwardPostsConditionInput = {
  and?: Array< ModelInwardPostsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  not?: ModelInwardPostsConditionInput | null,
  or?: Array< ModelInwardPostsConditionInput | null > | null,
  received_by?: ModelStringInput | null,
  received_date?: ModelStringInput | null,
  recipient_name?: ModelStringInput | null,
  sender_name?: ModelStringInput | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateInwardPostsInput = {
  created_at?: string | null,
  description?: string | null,
  id?: string | null,
  received_by?: string | null,
  received_date?: string | null,
  recipient_name?: string | null,
  sender_name?: string | null,
  status?: string | null,
};

export type ModelLicenseBillingConditionInput = {
  amount?: ModelFloatInput | null,
  and?: Array< ModelLicenseBillingConditionInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  invoice_no?: ModelStringInput | null,
  not?: ModelLicenseBillingConditionInput | null,
  or?: Array< ModelLicenseBillingConditionInput | null > | null,
  payment_date?: ModelStringInput | null,
  payment_status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateLicenseBillingInput = {
  amount?: number | null,
  client_license_id?: number | null,
  created_at?: string | null,
  id?: string | null,
  invoice_no?: string | null,
  payment_date?: string | null,
  payment_status?: string | null,
};

export type ModelLicenseNotificationsConditionInput = {
  and?: Array< ModelLicenseNotificationsConditionInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  is_sent?: ModelBooleanInput | null,
  message?: ModelStringInput | null,
  not?: ModelLicenseNotificationsConditionInput | null,
  notification_type?: ModelStringInput | null,
  or?: Array< ModelLicenseNotificationsConditionInput | null > | null,
  scheduled_date?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateLicenseNotificationsInput = {
  client_license_id?: number | null,
  created_at?: string | null,
  id?: string | null,
  is_sent?: boolean | null,
  message?: string | null,
  notification_type?: string | null,
  scheduled_date?: string | null,
};

export type ModelLicenseServicesConditionInput = {
  and?: Array< ModelLicenseServicesConditionInput | null > | null,
  client_license_id?: ModelIntInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  not?: ModelLicenseServicesConditionInput | null,
  or?: Array< ModelLicenseServicesConditionInput | null > | null,
  service_cost?: ModelFloatInput | null,
  service_date?: ModelStringInput | null,
  service_description?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateLicenseServicesInput = {
  client_license_id?: number | null,
  created_at?: string | null,
  id?: string | null,
  service_cost?: number | null,
  service_date?: string | null,
  service_description?: string | null,
};

export type ModelLicenseTypesConditionInput = {
  and?: Array< ModelLicenseTypesConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelLicenseTypesConditionInput | null,
  or?: Array< ModelLicenseTypesConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type CreateLicenseTypesInput = {
  created_at?: string | null,
  description?: string | null,
  id?: string | null,
  name?: string | null,
  updated_at?: string | null,
};

export type ModelLocationHistoryConditionInput = {
  and?: Array< ModelLocationHistoryConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  latitude?: ModelFloatInput | null,
  longitude?: ModelFloatInput | null,
  not?: ModelLocationHistoryConditionInput | null,
  or?: Array< ModelLocationHistoryConditionInput | null > | null,
  recorded_at?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateLocationHistoryInput = {
  id?: string | null,
  latitude?: number | null,
  longitude?: number | null,
  recorded_at?: string | null,
  user_id?: number | null,
};

export type ModelMessagesConditionInput = {
  and?: Array< ModelMessagesConditionInput | null > | null,
  attachment_id?: ModelIntInput | null,
  attachment_type?: ModelStringInput | null,
  content?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  is_read?: ModelBooleanInput | null,
  not?: ModelMessagesConditionInput | null,
  or?: Array< ModelMessagesConditionInput | null > | null,
  receiver_id?: ModelIntInput | null,
  sender_id?: ModelIntInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateMessagesInput = {
  attachment_id?: number | null,
  attachment_type?: string | null,
  content?: string | null,
  created_at?: string | null,
  id?: string | null,
  is_read?: boolean | null,
  receiver_id?: number | null,
  sender_id?: number | null,
};

export type ModelNotificationsConditionInput = {
  and?: Array< ModelNotificationsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  deal_id?: ModelIntInput | null,
  is_read?: ModelBooleanInput | null,
  message?: ModelStringInput | null,
  not?: ModelNotificationsConditionInput | null,
  or?: Array< ModelNotificationsConditionInput | null > | null,
  task_id?: ModelIntInput | null,
  title?: ModelStringInput | null,
  type?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateNotificationsInput = {
  created_at?: string | null,
  deal_id?: number | null,
  id?: string | null,
  is_read?: boolean | null,
  message?: string | null,
  task_id?: number | null,
  title?: string | null,
  type?: string | null,
  user_id?: number | null,
};

export type ModelServiceContentConditionInput = {
  and?: Array< ModelServiceContentConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  description?: ModelStringInput | null,
  details?: ModelStringInput | null,
  image_path?: ModelStringInput | null,
  not?: ModelServiceContentConditionInput | null,
  or?: Array< ModelServiceContentConditionInput | null > | null,
  service_id?: ModelIntInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateServiceContentInput = {
  description?: string | null,
  details?: string | null,
  id?: string | null,
  image_path?: string | null,
  service_id?: number | null,
  title?: string | null,
};

export type ModelServiceNamesConditionInput = {
  and?: Array< ModelServiceNamesConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelServiceNamesConditionInput | null,
  or?: Array< ModelServiceNamesConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateServiceNamesInput = {
  created_at?: string | null,
  id?: string | null,
  name?: string | null,
};

export type ModelStaffAttendanceConditionInput = {
  and?: Array< ModelStaffAttendanceConditionInput | null > | null,
  attendance_date?: ModelStringInput | null,
  check_in_time?: ModelStringInput | null,
  check_out_time?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  not?: ModelStaffAttendanceConditionInput | null,
  or?: Array< ModelStaffAttendanceConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateStaffAttendanceInput = {
  attendance_date?: string | null,
  check_in_time?: string | null,
  check_out_time?: string | null,
  id?: string | null,
  user_id?: number | null,
};

export type ModelStaffLocationsConditionInput = {
  and?: Array< ModelStaffLocationsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  latitude?: ModelFloatInput | null,
  longitude?: ModelFloatInput | null,
  not?: ModelStaffLocationsConditionInput | null,
  or?: Array< ModelStaffLocationsConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateStaffLocationsInput = {
  id?: string | null,
  latitude?: number | null,
  longitude?: number | null,
  updated_at?: string | null,
  user_id?: number | null,
};

export type ModelSysCronLogsConditionInput = {
  and?: Array< ModelSysCronLogsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  job_name?: ModelStringInput | null,
  last_run_date?: ModelStringInput | null,
  not?: ModelSysCronLogsConditionInput | null,
  or?: Array< ModelSysCronLogsConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
};

export type CreateSysCronLogsInput = {
  id?: string | null,
  job_name?: string | null,
  last_run_date?: string | null,
};

export type ModelTasksConditionInput = {
  and?: Array< ModelTasksConditionInput | null > | null,
  assigned_by?: ModelIntInput | null,
  assigned_to?: ModelIntInput | null,
  client_name?: ModelStringInput | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  description?: ModelStringInput | null,
  due_date?: ModelStringInput | null,
  location?: ModelStringInput | null,
  not?: ModelTasksConditionInput | null,
  or?: Array< ModelTasksConditionInput | null > | null,
  phone_number?: ModelStringInput | null,
  status?: ModelStringInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  updated_at?: ModelStringInput | null,
};

export type CreateTasksInput = {
  assigned_by?: number | null,
  assigned_to?: number | null,
  client_name?: string | null,
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id?: string | null,
  location?: string | null,
  phone_number?: string | null,
  status?: string | null,
  title?: string | null,
  updated_at?: string | null,
};

export type ModelTravelLogsConditionInput = {
  and?: Array< ModelTravelLogsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  destination?: ModelStringInput | null,
  not?: ModelTravelLogsConditionInput | null,
  or?: Array< ModelTravelLogsConditionInput | null > | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateTravelLogsInput = {
  created_at?: string | null,
  destination?: string | null,
  id?: string | null,
  user_id?: number | null,
};

export type ModelUserSessionsConditionInput = {
  active_seconds?: ModelIntInput | null,
  and?: Array< ModelUserSessionsConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  idle_seconds?: ModelIntInput | null,
  ip_address?: ModelStringInput | null,
  is_active?: ModelBooleanInput | null,
  login_time?: ModelStringInput | null,
  logout_time?: ModelStringInput | null,
  not?: ModelUserSessionsConditionInput | null,
  or?: Array< ModelUserSessionsConditionInput | null > | null,
  status?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  user_id?: ModelIntInput | null,
};

export type CreateUserSessionsInput = {
  active_seconds?: number | null,
  id?: string | null,
  idle_seconds?: number | null,
  ip_address?: string | null,
  is_active?: boolean | null,
  login_time?: string | null,
  logout_time?: string | null,
  status?: string | null,
  user_id?: number | null,
};

export type ModelUsersConditionInput = {
  and?: Array< ModelUsersConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  created_at?: ModelStringInput | null,
  email?: ModelStringInput | null,
  last_seen?: ModelStringInput | null,
  name?: ModelStringInput | null,
  not?: ModelUsersConditionInput | null,
  or?: Array< ModelUsersConditionInput | null > | null,
  password?: ModelStringInput | null,
  role?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type CreateUsersInput = {
  created_at?: string | null,
  email?: string | null,
  id?: string | null,
  last_seen?: string | null,
  name?: string | null,
  password?: string | null,
  role?: string | null,
  username?: string | null,
};

export type DeleteActivityLogsInput = {
  id: string,
};

export type DeleteBillingsInput = {
  id: string,
};

export type DeleteChecklistsInput = {
  id: string,
};

export type DeleteClientDocumentsInput = {
  id: string,
};

export type DeleteClientLicensesInput = {
  id: string,
};

export type DeleteClientsInput = {
  id: string,
};

export type DeleteCompanyBillsInput = {
  id: string,
};

export type DeleteDealActivitiesInput = {
  id: string,
};

export type DeleteDealAssigneesInput = {
  id: string,
};

export type DeleteDealHandoverHistoryInput = {
  id: string,
};

export type DeleteDealStageHistoryInput = {
  id: string,
};

export type DeleteDealsInput = {
  id: string,
};

export type DeleteDscRecordsInput = {
  id: string,
};

export type DeleteInwardPostsInput = {
  id: string,
};

export type DeleteLicenseBillingInput = {
  id: string,
};

export type DeleteLicenseNotificationsInput = {
  id: string,
};

export type DeleteLicenseServicesInput = {
  id: string,
};

export type DeleteLicenseTypesInput = {
  id: string,
};

export type DeleteLocationHistoryInput = {
  id: string,
};

export type DeleteMessagesInput = {
  id: string,
};

export type DeleteNotificationsInput = {
  id: string,
};

export type DeleteServiceContentInput = {
  id: string,
};

export type DeleteServiceNamesInput = {
  id: string,
};

export type DeleteStaffAttendanceInput = {
  id: string,
};

export type DeleteStaffLocationsInput = {
  id: string,
};

export type DeleteSysCronLogsInput = {
  id: string,
};

export type DeleteTasksInput = {
  id: string,
};

export type DeleteTravelLogsInput = {
  id: string,
};

export type DeleteUserSessionsInput = {
  id: string,
};

export type DeleteUsersInput = {
  id: string,
};

export type UpdateActivityLogsInput = {
  action?: string | null,
  created_at?: string | null,
  details?: string | null,
  id: string,
  target_id?: string | null,
  target_type?: string | null,
  user_id?: number | null,
};

export type UpdateBillingsInput = {
  amount?: string | null,
  authorities?: string | null,
  category?: string | null,
  client_name?: string | null,
  created_at?: string | null,
  data?: string | null,
  date?: string | null,
  id: string,
  invoice_no?: string | null,
  status?: string | null,
  type?: string | null,
};

export type UpdateChecklistsInput = {
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  manager_id?: number | null,
  reason?: string | null,
  remarks?: string | null,
  responsible_id?: number | null,
  status?: string | null,
  title?: string | null,
  updated_at?: string | null,
};

export type UpdateClientDocumentsInput = {
  client_id?: string | null,
  client_name?: string | null,
  created_at?: string | null,
  document_name?: string | null,
  id: string,
  og_copy?: string | null,
  remarks?: string | null,
  storage_path?: string | null,
};

export type UpdateClientLicensesInput = {
  client_id?: number | null,
  created_at?: string | null,
  expiry_date?: string | null,
  file_no?: string | null,
  id: string,
  license_type_id?: number | null,
  manual_client_name?: string | null,
  notes?: string | null,
  service_date?: string | null,
  status?: string | null,
  updated_at?: string | null,
};

export type UpdateClientsInput = {
  address?: string | null,
  balance_due?: string | null,
  case_number?: string | null,
  created_at?: string | null,
  dob?: string | null,
  email?: string | null,
  file_date?: string | null,
  file_no?: string | null,
  id: string,
  is_contacted?: boolean | null,
  managed_by?: string | null,
  name?: string | null,
  phone?: string | null,
  review_rating?: number | null,
  type_of_work?: string | null,
};

export type UpdateCompanyBillsInput = {
  amount?: number | null,
  bill_date?: string | null,
  category?: string | null,
  created_at?: string | null,
  description?: string | null,
  id: string,
  spent_by?: number | null,
  spent_by_name?: string | null,
  status?: string | null,
  title?: string | null,
};

export type UpdateDealActivitiesInput = {
  created_at?: string | null,
  created_by?: number | null,
  deal_id?: number | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  is_completed?: boolean | null,
  title?: string | null,
  type?: string | null,
};

export type UpdateDealAssigneesInput = {
  assigned_at?: string | null,
  deal_id?: number | null,
  id: string,
  role?: string | null,
  user_id?: number | null,
};

export type UpdateDealHandoverHistoryInput = {
  deal_id?: number | null,
  from_user_id?: number | null,
  handed_over_at?: string | null,
  id: string,
  note?: string | null,
  to_user_id?: number | null,
};

export type UpdateDealStageHistoryInput = {
  changed_at?: string | null,
  changed_by?: number | null,
  deal_id?: number | null,
  from_stage?: string | null,
  id: string,
  to_stage?: string | null,
};

export type UpdateDealsInput = {
  amount?: number | null,
  billing_id?: number | null,
  client_id?: number | null,
  client_name?: string | null,
  closed_at?: string | null,
  company?: string | null,
  contact_info?: string | null,
  contact_status?: string | null,
  create_invoice_share?: string | null,
  created_at?: string | null,
  currency?: string | null,
  description?: string | null,
  drive_link?: string | null,
  est_amount_work?: number | null,
  expense_spent?: number | null,
  expenses_list?: string | null,
  files_asked?: string | null,
  files_received?: string | null,
  id: string,
  invoice_amount?: number | null,
  is_won?: boolean | null,
  name?: string | null,
  noc_obtained?: boolean | null,
  part_payment_amount?: number | null,
  payment_received?: number | null,
  payment_type?: string | null,
  pipeline?: string | null,
  priority?: string | null,
  quotation_id?: number | null,
  referred_by?: string | null,
  reg_fee_required?: string | null,
  register_no?: string | null,
  responsible_id?: number | null,
  responsible_name?: string | null,
  send_to_customer?: string | null,
  stage?: string | null,
  updated_at?: string | null,
  upload_invoice_path?: string | null,
  work_type?: string | null,
};

export type UpdateDscRecordsInput = {
  client_name?: string | null,
  created_at?: string | null,
  dsc_expiry_date?: string | null,
  dsc_taken_date?: string | null,
  email_id?: string | null,
  id: string,
  password?: string | null,
  phone_no?: string | null,
  updated_at?: string | null,
  username?: string | null,
};

export type UpdateInwardPostsInput = {
  created_at?: string | null,
  description?: string | null,
  id: string,
  received_by?: string | null,
  received_date?: string | null,
  recipient_name?: string | null,
  sender_name?: string | null,
  status?: string | null,
};

export type UpdateLicenseBillingInput = {
  amount?: number | null,
  client_license_id?: number | null,
  created_at?: string | null,
  id: string,
  invoice_no?: string | null,
  payment_date?: string | null,
  payment_status?: string | null,
};

export type UpdateLicenseNotificationsInput = {
  client_license_id?: number | null,
  created_at?: string | null,
  id: string,
  is_sent?: boolean | null,
  message?: string | null,
  notification_type?: string | null,
  scheduled_date?: string | null,
};

export type UpdateLicenseServicesInput = {
  client_license_id?: number | null,
  created_at?: string | null,
  id: string,
  service_cost?: number | null,
  service_date?: string | null,
  service_description?: string | null,
};

export type UpdateLicenseTypesInput = {
  created_at?: string | null,
  description?: string | null,
  id: string,
  name?: string | null,
  updated_at?: string | null,
};

export type UpdateLocationHistoryInput = {
  id: string,
  latitude?: number | null,
  longitude?: number | null,
  recorded_at?: string | null,
  user_id?: number | null,
};

export type UpdateMessagesInput = {
  attachment_id?: number | null,
  attachment_type?: string | null,
  content?: string | null,
  created_at?: string | null,
  id: string,
  is_read?: boolean | null,
  receiver_id?: number | null,
  sender_id?: number | null,
};

export type UpdateNotificationsInput = {
  created_at?: string | null,
  deal_id?: number | null,
  id: string,
  is_read?: boolean | null,
  message?: string | null,
  task_id?: number | null,
  title?: string | null,
  type?: string | null,
  user_id?: number | null,
};

export type UpdateServiceContentInput = {
  description?: string | null,
  details?: string | null,
  id: string,
  image_path?: string | null,
  service_id?: number | null,
  title?: string | null,
};

export type UpdateServiceNamesInput = {
  created_at?: string | null,
  id: string,
  name?: string | null,
};

export type UpdateStaffAttendanceInput = {
  attendance_date?: string | null,
  check_in_time?: string | null,
  check_out_time?: string | null,
  id: string,
  user_id?: number | null,
};

export type UpdateStaffLocationsInput = {
  id: string,
  latitude?: number | null,
  longitude?: number | null,
  updated_at?: string | null,
  user_id?: number | null,
};

export type UpdateSysCronLogsInput = {
  id: string,
  job_name?: string | null,
  last_run_date?: string | null,
};

export type UpdateTasksInput = {
  assigned_by?: number | null,
  assigned_to?: number | null,
  client_name?: string | null,
  created_at?: string | null,
  description?: string | null,
  due_date?: string | null,
  id: string,
  location?: string | null,
  phone_number?: string | null,
  status?: string | null,
  title?: string | null,
  updated_at?: string | null,
};

export type UpdateTravelLogsInput = {
  created_at?: string | null,
  destination?: string | null,
  id: string,
  user_id?: number | null,
};

export type UpdateUserSessionsInput = {
  active_seconds?: number | null,
  id: string,
  idle_seconds?: number | null,
  ip_address?: string | null,
  is_active?: boolean | null,
  login_time?: string | null,
  logout_time?: string | null,
  status?: string | null,
  user_id?: number | null,
};

export type UpdateUsersInput = {
  created_at?: string | null,
  email?: string | null,
  id: string,
  last_seen?: string | null,
  name?: string | null,
  password?: string | null,
  role?: string | null,
  username?: string | null,
};

export type ModelSubscriptionActivityLogsFilterInput = {
  action?: ModelSubscriptionStringInput | null,
  and?: Array< ModelSubscriptionActivityLogsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  details?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionActivityLogsFilterInput | null > | null,
  target_id?: ModelSubscriptionStringInput | null,
  target_type?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionStringInput = {
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  in?: Array< string | null > | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  notIn?: Array< string | null > | null,
};

export type ModelSubscriptionIDInput = {
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  in?: Array< string | null > | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  notIn?: Array< string | null > | null,
};

export type ModelSubscriptionIntInput = {
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  in?: Array< number | null > | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
  notIn?: Array< number | null > | null,
};

export type ModelSubscriptionBillingsFilterInput = {
  amount?: ModelSubscriptionStringInput | null,
  and?: Array< ModelSubscriptionBillingsFilterInput | null > | null,
  authorities?: ModelSubscriptionStringInput | null,
  category?: ModelSubscriptionStringInput | null,
  client_name?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  data?: ModelSubscriptionStringInput | null,
  date?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  invoice_no?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionBillingsFilterInput | null > | null,
  status?: ModelSubscriptionStringInput | null,
  type?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionChecklistsFilterInput = {
  and?: Array< ModelSubscriptionChecklistsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  due_date?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  manager_id?: ModelSubscriptionIntInput | null,
  or?: Array< ModelSubscriptionChecklistsFilterInput | null > | null,
  reason?: ModelSubscriptionStringInput | null,
  remarks?: ModelSubscriptionStringInput | null,
  responsible_id?: ModelSubscriptionIntInput | null,
  status?: ModelSubscriptionStringInput | null,
  title?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionClientDocumentsFilterInput = {
  and?: Array< ModelSubscriptionClientDocumentsFilterInput | null > | null,
  client_id?: ModelSubscriptionStringInput | null,
  client_name?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  document_name?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  og_copy?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionClientDocumentsFilterInput | null > | null,
  remarks?: ModelSubscriptionStringInput | null,
  storage_path?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionClientLicensesFilterInput = {
  and?: Array< ModelSubscriptionClientLicensesFilterInput | null > | null,
  client_id?: ModelSubscriptionIntInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  expiry_date?: ModelSubscriptionStringInput | null,
  file_no?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  license_type_id?: ModelSubscriptionIntInput | null,
  manual_client_name?: ModelSubscriptionStringInput | null,
  notes?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionClientLicensesFilterInput | null > | null,
  service_date?: ModelSubscriptionStringInput | null,
  status?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionClientsFilterInput = {
  address?: ModelSubscriptionStringInput | null,
  and?: Array< ModelSubscriptionClientsFilterInput | null > | null,
  balance_due?: ModelSubscriptionStringInput | null,
  case_number?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  dob?: ModelSubscriptionStringInput | null,
  email?: ModelSubscriptionStringInput | null,
  file_date?: ModelSubscriptionStringInput | null,
  file_no?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  is_contacted?: ModelSubscriptionBooleanInput | null,
  managed_by?: ModelSubscriptionStringInput | null,
  name?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionClientsFilterInput | null > | null,
  phone?: ModelSubscriptionStringInput | null,
  review_rating?: ModelSubscriptionIntInput | null,
  type_of_work?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionBooleanInput = {
  eq?: boolean | null,
  ne?: boolean | null,
};

export type ModelSubscriptionCompanyBillsFilterInput = {
  amount?: ModelSubscriptionFloatInput | null,
  and?: Array< ModelSubscriptionCompanyBillsFilterInput | null > | null,
  bill_date?: ModelSubscriptionStringInput | null,
  category?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionCompanyBillsFilterInput | null > | null,
  spent_by?: ModelSubscriptionIntInput | null,
  spent_by_name?: ModelSubscriptionStringInput | null,
  status?: ModelSubscriptionStringInput | null,
  title?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionFloatInput = {
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  in?: Array< number | null > | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
  notIn?: Array< number | null > | null,
};

export type ModelSubscriptionDealActivitiesFilterInput = {
  and?: Array< ModelSubscriptionDealActivitiesFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  created_by?: ModelSubscriptionIntInput | null,
  deal_id?: ModelSubscriptionIntInput | null,
  description?: ModelSubscriptionStringInput | null,
  due_date?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  is_completed?: ModelSubscriptionBooleanInput | null,
  or?: Array< ModelSubscriptionDealActivitiesFilterInput | null > | null,
  title?: ModelSubscriptionStringInput | null,
  type?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionDealAssigneesFilterInput = {
  and?: Array< ModelSubscriptionDealAssigneesFilterInput | null > | null,
  assigned_at?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  deal_id?: ModelSubscriptionIntInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionDealAssigneesFilterInput | null > | null,
  role?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionDealHandoverHistoryFilterInput = {
  and?: Array< ModelSubscriptionDealHandoverHistoryFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  deal_id?: ModelSubscriptionIntInput | null,
  from_user_id?: ModelSubscriptionIntInput | null,
  handed_over_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  note?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionDealHandoverHistoryFilterInput | null > | null,
  to_user_id?: ModelSubscriptionIntInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionDealStageHistoryFilterInput = {
  and?: Array< ModelSubscriptionDealStageHistoryFilterInput | null > | null,
  changed_at?: ModelSubscriptionStringInput | null,
  changed_by?: ModelSubscriptionIntInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  deal_id?: ModelSubscriptionIntInput | null,
  from_stage?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionDealStageHistoryFilterInput | null > | null,
  to_stage?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionDealsFilterInput = {
  amount?: ModelSubscriptionFloatInput | null,
  and?: Array< ModelSubscriptionDealsFilterInput | null > | null,
  billing_id?: ModelSubscriptionIntInput | null,
  client_id?: ModelSubscriptionIntInput | null,
  client_name?: ModelSubscriptionStringInput | null,
  closed_at?: ModelSubscriptionStringInput | null,
  company?: ModelSubscriptionStringInput | null,
  contact_info?: ModelSubscriptionStringInput | null,
  contact_status?: ModelSubscriptionStringInput | null,
  create_invoice_share?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  currency?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  drive_link?: ModelSubscriptionStringInput | null,
  est_amount_work?: ModelSubscriptionFloatInput | null,
  expense_spent?: ModelSubscriptionFloatInput | null,
  expenses_list?: ModelSubscriptionStringInput | null,
  files_asked?: ModelSubscriptionStringInput | null,
  files_received?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  invoice_amount?: ModelSubscriptionFloatInput | null,
  is_won?: ModelSubscriptionBooleanInput | null,
  name?: ModelSubscriptionStringInput | null,
  noc_obtained?: ModelSubscriptionBooleanInput | null,
  or?: Array< ModelSubscriptionDealsFilterInput | null > | null,
  part_payment_amount?: ModelSubscriptionFloatInput | null,
  payment_received?: ModelSubscriptionFloatInput | null,
  payment_type?: ModelSubscriptionStringInput | null,
  pipeline?: ModelSubscriptionStringInput | null,
  priority?: ModelSubscriptionStringInput | null,
  quotation_id?: ModelSubscriptionIntInput | null,
  referred_by?: ModelSubscriptionStringInput | null,
  reg_fee_required?: ModelSubscriptionStringInput | null,
  register_no?: ModelSubscriptionStringInput | null,
  responsible_id?: ModelSubscriptionIntInput | null,
  responsible_name?: ModelSubscriptionStringInput | null,
  send_to_customer?: ModelSubscriptionStringInput | null,
  stage?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
  upload_invoice_path?: ModelSubscriptionStringInput | null,
  work_type?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionDscRecordsFilterInput = {
  and?: Array< ModelSubscriptionDscRecordsFilterInput | null > | null,
  client_name?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  dsc_expiry_date?: ModelSubscriptionStringInput | null,
  dsc_taken_date?: ModelSubscriptionStringInput | null,
  email_id?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionDscRecordsFilterInput | null > | null,
  password?: ModelSubscriptionStringInput | null,
  phone_no?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
  username?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionInwardPostsFilterInput = {
  and?: Array< ModelSubscriptionInwardPostsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionInwardPostsFilterInput | null > | null,
  received_by?: ModelSubscriptionStringInput | null,
  received_date?: ModelSubscriptionStringInput | null,
  recipient_name?: ModelSubscriptionStringInput | null,
  sender_name?: ModelSubscriptionStringInput | null,
  status?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionLicenseBillingFilterInput = {
  amount?: ModelSubscriptionFloatInput | null,
  and?: Array< ModelSubscriptionLicenseBillingFilterInput | null > | null,
  client_license_id?: ModelSubscriptionIntInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  invoice_no?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionLicenseBillingFilterInput | null > | null,
  payment_date?: ModelSubscriptionStringInput | null,
  payment_status?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionLicenseNotificationsFilterInput = {
  and?: Array< ModelSubscriptionLicenseNotificationsFilterInput | null > | null,
  client_license_id?: ModelSubscriptionIntInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  is_sent?: ModelSubscriptionBooleanInput | null,
  message?: ModelSubscriptionStringInput | null,
  notification_type?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionLicenseNotificationsFilterInput | null > | null,
  scheduled_date?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionLicenseServicesFilterInput = {
  and?: Array< ModelSubscriptionLicenseServicesFilterInput | null > | null,
  client_license_id?: ModelSubscriptionIntInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionLicenseServicesFilterInput | null > | null,
  service_cost?: ModelSubscriptionFloatInput | null,
  service_date?: ModelSubscriptionStringInput | null,
  service_description?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionLicenseTypesFilterInput = {
  and?: Array< ModelSubscriptionLicenseTypesFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  name?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionLicenseTypesFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionLocationHistoryFilterInput = {
  and?: Array< ModelSubscriptionLocationHistoryFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  latitude?: ModelSubscriptionFloatInput | null,
  longitude?: ModelSubscriptionFloatInput | null,
  or?: Array< ModelSubscriptionLocationHistoryFilterInput | null > | null,
  recorded_at?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionMessagesFilterInput = {
  and?: Array< ModelSubscriptionMessagesFilterInput | null > | null,
  attachment_id?: ModelSubscriptionIntInput | null,
  attachment_type?: ModelSubscriptionStringInput | null,
  content?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  is_read?: ModelSubscriptionBooleanInput | null,
  or?: Array< ModelSubscriptionMessagesFilterInput | null > | null,
  receiver_id?: ModelSubscriptionIntInput | null,
  sender_id?: ModelSubscriptionIntInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionNotificationsFilterInput = {
  and?: Array< ModelSubscriptionNotificationsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  deal_id?: ModelSubscriptionIntInput | null,
  id?: ModelSubscriptionIDInput | null,
  is_read?: ModelSubscriptionBooleanInput | null,
  message?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionNotificationsFilterInput | null > | null,
  task_id?: ModelSubscriptionIntInput | null,
  title?: ModelSubscriptionStringInput | null,
  type?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionServiceContentFilterInput = {
  and?: Array< ModelSubscriptionServiceContentFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  details?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  image_path?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionServiceContentFilterInput | null > | null,
  service_id?: ModelSubscriptionIntInput | null,
  title?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionServiceNamesFilterInput = {
  and?: Array< ModelSubscriptionServiceNamesFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  name?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionServiceNamesFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionStaffAttendanceFilterInput = {
  and?: Array< ModelSubscriptionStaffAttendanceFilterInput | null > | null,
  attendance_date?: ModelSubscriptionStringInput | null,
  check_in_time?: ModelSubscriptionStringInput | null,
  check_out_time?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionStaffAttendanceFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionStaffLocationsFilterInput = {
  and?: Array< ModelSubscriptionStaffLocationsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  latitude?: ModelSubscriptionFloatInput | null,
  longitude?: ModelSubscriptionFloatInput | null,
  or?: Array< ModelSubscriptionStaffLocationsFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionSysCronLogsFilterInput = {
  and?: Array< ModelSubscriptionSysCronLogsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  job_name?: ModelSubscriptionStringInput | null,
  last_run_date?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionSysCronLogsFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionTasksFilterInput = {
  and?: Array< ModelSubscriptionTasksFilterInput | null > | null,
  assigned_by?: ModelSubscriptionIntInput | null,
  assigned_to?: ModelSubscriptionIntInput | null,
  client_name?: ModelSubscriptionStringInput | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  due_date?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  location?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionTasksFilterInput | null > | null,
  phone_number?: ModelSubscriptionStringInput | null,
  status?: ModelSubscriptionStringInput | null,
  title?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  updated_at?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionTravelLogsFilterInput = {
  and?: Array< ModelSubscriptionTravelLogsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  destination?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  or?: Array< ModelSubscriptionTravelLogsFilterInput | null > | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionUserSessionsFilterInput = {
  active_seconds?: ModelSubscriptionIntInput | null,
  and?: Array< ModelSubscriptionUserSessionsFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  idle_seconds?: ModelSubscriptionIntInput | null,
  ip_address?: ModelSubscriptionStringInput | null,
  is_active?: ModelSubscriptionBooleanInput | null,
  login_time?: ModelSubscriptionStringInput | null,
  logout_time?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionUserSessionsFilterInput | null > | null,
  status?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  user_id?: ModelSubscriptionIntInput | null,
};

export type ModelSubscriptionUsersFilterInput = {
  and?: Array< ModelSubscriptionUsersFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  created_at?: ModelSubscriptionStringInput | null,
  email?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  last_seen?: ModelSubscriptionStringInput | null,
  name?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionUsersFilterInput | null > | null,
  password?: ModelSubscriptionStringInput | null,
  role?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  username?: ModelSubscriptionStringInput | null,
};

export type GetActivityLogsQueryVariables = {
  id: string,
};

export type GetActivityLogsQuery = {
  getActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetBillingsQueryVariables = {
  id: string,
};

export type GetBillingsQuery = {
  getBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type GetChecklistsQueryVariables = {
  id: string,
};

export type GetChecklistsQuery = {
  getChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type GetClientDocumentsQueryVariables = {
  id: string,
};

export type GetClientDocumentsQuery = {
  getClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type GetClientLicensesQueryVariables = {
  id: string,
};

export type GetClientLicensesQuery = {
  getClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type GetClientsQueryVariables = {
  id: string,
};

export type GetClientsQuery = {
  getClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type GetCompanyBillsQueryVariables = {
  id: string,
};

export type GetCompanyBillsQuery = {
  getCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type GetDealActivitiesQueryVariables = {
  id: string,
};

export type GetDealActivitiesQuery = {
  getDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type GetDealAssigneesQueryVariables = {
  id: string,
};

export type GetDealAssigneesQuery = {
  getDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetDealHandoverHistoryQueryVariables = {
  id: string,
};

export type GetDealHandoverHistoryQuery = {
  getDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type GetDealStageHistoryQueryVariables = {
  id: string,
};

export type GetDealStageHistoryQuery = {
  getDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type GetDealsQueryVariables = {
  id: string,
};

export type GetDealsQuery = {
  getDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type GetDscRecordsQueryVariables = {
  id: string,
};

export type GetDscRecordsQuery = {
  getDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type GetInwardPostsQueryVariables = {
  id: string,
};

export type GetInwardPostsQuery = {
  getInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type GetLicenseBillingQueryVariables = {
  id: string,
};

export type GetLicenseBillingQuery = {
  getLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type GetLicenseNotificationsQueryVariables = {
  id: string,
};

export type GetLicenseNotificationsQuery = {
  getLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type GetLicenseServicesQueryVariables = {
  id: string,
};

export type GetLicenseServicesQuery = {
  getLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type GetLicenseTypesQueryVariables = {
  id: string,
};

export type GetLicenseTypesQuery = {
  getLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type GetLocationHistoryQueryVariables = {
  id: string,
};

export type GetLocationHistoryQuery = {
  getLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetMessagesQueryVariables = {
  id: string,
};

export type GetMessagesQuery = {
  getMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type GetNotificationsQueryVariables = {
  id: string,
};

export type GetNotificationsQuery = {
  getNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetServiceContentQueryVariables = {
  id: string,
};

export type GetServiceContentQuery = {
  getServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type GetServiceNamesQueryVariables = {
  id: string,
};

export type GetServiceNamesQuery = {
  getServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type GetStaffAttendanceQueryVariables = {
  id: string,
};

export type GetStaffAttendanceQuery = {
  getStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetStaffLocationsQueryVariables = {
  id: string,
};

export type GetStaffLocationsQuery = {
  getStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type GetSysCronLogsQueryVariables = {
  id: string,
};

export type GetSysCronLogsQuery = {
  getSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type GetTasksQueryVariables = {
  id: string,
};

export type GetTasksQuery = {
  getTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type GetTravelLogsQueryVariables = {
  id: string,
};

export type GetTravelLogsQuery = {
  getTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetUserSessionsQueryVariables = {
  id: string,
};

export type GetUserSessionsQuery = {
  getUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type GetUsersQueryVariables = {
  id: string,
};

export type GetUsersQuery = {
  getUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type ListActivityLogsQueryVariables = {
  filter?: ModelActivityLogsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListActivityLogsQuery = {
  listActivityLogs?:  {
    __typename: "ModelActivityLogsConnection",
    items:  Array< {
      __typename: "ActivityLogs",
      action?: string | null,
      createdAt: string,
      created_at?: string | null,
      details?: string | null,
      id: string,
      target_id?: string | null,
      target_type?: string | null,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListBillingsQueryVariables = {
  filter?: ModelBillingsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListBillingsQuery = {
  listBillings?:  {
    __typename: "ModelBillingsConnection",
    items:  Array< {
      __typename: "Billings",
      amount?: string | null,
      authorities?: string | null,
      category?: string | null,
      client_name?: string | null,
      createdAt: string,
      created_at?: string | null,
      data?: string | null,
      date?: string | null,
      id: string,
      invoice_no?: string | null,
      status?: string | null,
      type?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListChecklistsQueryVariables = {
  filter?: ModelChecklistsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListChecklistsQuery = {
  listChecklists?:  {
    __typename: "ModelChecklistsConnection",
    items:  Array< {
      __typename: "Checklists",
      createdAt: string,
      created_at?: string | null,
      description?: string | null,
      due_date?: string | null,
      id: string,
      manager_id?: number | null,
      reason?: string | null,
      remarks?: string | null,
      responsible_id?: number | null,
      status?: string | null,
      title?: string | null,
      updatedAt: string,
      updated_at?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListClientDocumentsQueryVariables = {
  filter?: ModelClientDocumentsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListClientDocumentsQuery = {
  listClientDocuments?:  {
    __typename: "ModelClientDocumentsConnection",
    items:  Array< {
      __typename: "ClientDocuments",
      client_id?: string | null,
      client_name?: string | null,
      createdAt: string,
      created_at?: string | null,
      document_name?: string | null,
      id: string,
      og_copy?: string | null,
      remarks?: string | null,
      storage_path?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListClientLicensesQueryVariables = {
  filter?: ModelClientLicensesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListClientLicensesQuery = {
  listClientLicenses?:  {
    __typename: "ModelClientLicensesConnection",
    items:  Array< {
      __typename: "ClientLicenses",
      client_id?: number | null,
      createdAt: string,
      created_at?: string | null,
      expiry_date?: string | null,
      file_no?: string | null,
      id: string,
      license_type_id?: number | null,
      manual_client_name?: string | null,
      notes?: string | null,
      service_date?: string | null,
      status?: string | null,
      updatedAt: string,
      updated_at?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListClientsQueryVariables = {
  filter?: ModelClientsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListClientsQuery = {
  listClients?:  {
    __typename: "ModelClientsConnection",
    items:  Array< {
      __typename: "Clients",
      address?: string | null,
      balance_due?: string | null,
      case_number?: string | null,
      createdAt: string,
      created_at?: string | null,
      dob?: string | null,
      email?: string | null,
      file_date?: string | null,
      file_no?: string | null,
      id: string,
      is_contacted?: boolean | null,
      managed_by?: string | null,
      name?: string | null,
      phone?: string | null,
      review_rating?: number | null,
      type_of_work?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListCompanyBillsQueryVariables = {
  filter?: ModelCompanyBillsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListCompanyBillsQuery = {
  listCompanyBills?:  {
    __typename: "ModelCompanyBillsConnection",
    items:  Array< {
      __typename: "CompanyBills",
      amount?: number | null,
      bill_date?: string | null,
      category?: string | null,
      createdAt: string,
      created_at?: string | null,
      description?: string | null,
      id: string,
      spent_by?: number | null,
      spent_by_name?: string | null,
      status?: string | null,
      title?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDealActivitiesQueryVariables = {
  filter?: ModelDealActivitiesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDealActivitiesQuery = {
  listDealActivities?:  {
    __typename: "ModelDealActivitiesConnection",
    items:  Array< {
      __typename: "DealActivities",
      createdAt: string,
      created_at?: string | null,
      created_by?: number | null,
      deal_id?: number | null,
      description?: string | null,
      due_date?: string | null,
      id: string,
      is_completed?: boolean | null,
      title?: string | null,
      type?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDealAssigneesQueryVariables = {
  filter?: ModelDealAssigneesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDealAssigneesQuery = {
  listDealAssignees?:  {
    __typename: "ModelDealAssigneesConnection",
    items:  Array< {
      __typename: "DealAssignees",
      assigned_at?: string | null,
      createdAt: string,
      deal_id?: number | null,
      id: string,
      role?: string | null,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDealHandoverHistoriesQueryVariables = {
  filter?: ModelDealHandoverHistoryFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDealHandoverHistoriesQuery = {
  listDealHandoverHistories?:  {
    __typename: "ModelDealHandoverHistoryConnection",
    items:  Array< {
      __typename: "DealHandoverHistory",
      createdAt: string,
      deal_id?: number | null,
      from_user_id?: number | null,
      handed_over_at?: string | null,
      id: string,
      note?: string | null,
      to_user_id?: number | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDealStageHistoriesQueryVariables = {
  filter?: ModelDealStageHistoryFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDealStageHistoriesQuery = {
  listDealStageHistories?:  {
    __typename: "ModelDealStageHistoryConnection",
    items:  Array< {
      __typename: "DealStageHistory",
      changed_at?: string | null,
      changed_by?: number | null,
      createdAt: string,
      deal_id?: number | null,
      from_stage?: string | null,
      id: string,
      to_stage?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDealsQueryVariables = {
  filter?: ModelDealsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDealsQuery = {
  listDeals?:  {
    __typename: "ModelDealsConnection",
    items:  Array< {
      __typename: "Deals",
      amount?: number | null,
      billing_id?: number | null,
      client_id?: number | null,
      client_name?: string | null,
      closed_at?: string | null,
      company?: string | null,
      contact_info?: string | null,
      contact_status?: string | null,
      create_invoice_share?: string | null,
      createdAt: string,
      created_at?: string | null,
      currency?: string | null,
      description?: string | null,
      drive_link?: string | null,
      est_amount_work?: number | null,
      expense_spent?: number | null,
      expenses_list?: string | null,
      files_asked?: string | null,
      files_received?: string | null,
      id: string,
      invoice_amount?: number | null,
      is_won?: boolean | null,
      name?: string | null,
      noc_obtained?: boolean | null,
      part_payment_amount?: number | null,
      payment_received?: number | null,
      payment_type?: string | null,
      pipeline?: string | null,
      priority?: string | null,
      quotation_id?: number | null,
      referred_by?: string | null,
      reg_fee_required?: string | null,
      register_no?: string | null,
      responsible_id?: number | null,
      responsible_name?: string | null,
      send_to_customer?: string | null,
      stage?: string | null,
      updatedAt: string,
      updated_at?: string | null,
      upload_invoice_path?: string | null,
      work_type?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListDscRecordsQueryVariables = {
  filter?: ModelDscRecordsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListDscRecordsQuery = {
  listDscRecords?:  {
    __typename: "ModelDscRecordsConnection",
    items:  Array< {
      __typename: "DscRecords",
      client_name?: string | null,
      createdAt: string,
      created_at?: string | null,
      dsc_expiry_date?: string | null,
      dsc_taken_date?: string | null,
      email_id?: string | null,
      id: string,
      password?: string | null,
      phone_no?: string | null,
      updatedAt: string,
      updated_at?: string | null,
      username?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListInwardPostsQueryVariables = {
  filter?: ModelInwardPostsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListInwardPostsQuery = {
  listInwardPosts?:  {
    __typename: "ModelInwardPostsConnection",
    items:  Array< {
      __typename: "InwardPosts",
      createdAt: string,
      created_at?: string | null,
      description?: string | null,
      id: string,
      received_by?: string | null,
      received_date?: string | null,
      recipient_name?: string | null,
      sender_name?: string | null,
      status?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListLicenseBillingsQueryVariables = {
  filter?: ModelLicenseBillingFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListLicenseBillingsQuery = {
  listLicenseBillings?:  {
    __typename: "ModelLicenseBillingConnection",
    items:  Array< {
      __typename: "LicenseBilling",
      amount?: number | null,
      client_license_id?: number | null,
      createdAt: string,
      created_at?: string | null,
      id: string,
      invoice_no?: string | null,
      payment_date?: string | null,
      payment_status?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListLicenseNotificationsQueryVariables = {
  filter?: ModelLicenseNotificationsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListLicenseNotificationsQuery = {
  listLicenseNotifications?:  {
    __typename: "ModelLicenseNotificationsConnection",
    items:  Array< {
      __typename: "LicenseNotifications",
      client_license_id?: number | null,
      createdAt: string,
      created_at?: string | null,
      id: string,
      is_sent?: boolean | null,
      message?: string | null,
      notification_type?: string | null,
      scheduled_date?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListLicenseServicesQueryVariables = {
  filter?: ModelLicenseServicesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListLicenseServicesQuery = {
  listLicenseServices?:  {
    __typename: "ModelLicenseServicesConnection",
    items:  Array< {
      __typename: "LicenseServices",
      client_license_id?: number | null,
      createdAt: string,
      created_at?: string | null,
      id: string,
      service_cost?: number | null,
      service_date?: string | null,
      service_description?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListLicenseTypesQueryVariables = {
  filter?: ModelLicenseTypesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListLicenseTypesQuery = {
  listLicenseTypes?:  {
    __typename: "ModelLicenseTypesConnection",
    items:  Array< {
      __typename: "LicenseTypes",
      createdAt: string,
      created_at?: string | null,
      description?: string | null,
      id: string,
      name?: string | null,
      updatedAt: string,
      updated_at?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListLocationHistoriesQueryVariables = {
  filter?: ModelLocationHistoryFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListLocationHistoriesQuery = {
  listLocationHistories?:  {
    __typename: "ModelLocationHistoryConnection",
    items:  Array< {
      __typename: "LocationHistory",
      createdAt: string,
      id: string,
      latitude?: number | null,
      longitude?: number | null,
      recorded_at?: string | null,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListMessagesQueryVariables = {
  filter?: ModelMessagesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListMessagesQuery = {
  listMessages?:  {
    __typename: "ModelMessagesConnection",
    items:  Array< {
      __typename: "Messages",
      attachment_id?: number | null,
      attachment_type?: string | null,
      content?: string | null,
      createdAt: string,
      created_at?: string | null,
      id: string,
      is_read?: boolean | null,
      receiver_id?: number | null,
      sender_id?: number | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListNotificationsQueryVariables = {
  filter?: ModelNotificationsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListNotificationsQuery = {
  listNotifications?:  {
    __typename: "ModelNotificationsConnection",
    items:  Array< {
      __typename: "Notifications",
      createdAt: string,
      created_at?: string | null,
      deal_id?: number | null,
      id: string,
      is_read?: boolean | null,
      message?: string | null,
      task_id?: number | null,
      title?: string | null,
      type?: string | null,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListServiceContentsQueryVariables = {
  filter?: ModelServiceContentFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListServiceContentsQuery = {
  listServiceContents?:  {
    __typename: "ModelServiceContentConnection",
    items:  Array< {
      __typename: "ServiceContent",
      createdAt: string,
      description?: string | null,
      details?: string | null,
      id: string,
      image_path?: string | null,
      service_id?: number | null,
      title?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListServiceNamesQueryVariables = {
  filter?: ModelServiceNamesFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListServiceNamesQuery = {
  listServiceNames?:  {
    __typename: "ModelServiceNamesConnection",
    items:  Array< {
      __typename: "ServiceNames",
      createdAt: string,
      created_at?: string | null,
      id: string,
      name?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListStaffAttendancesQueryVariables = {
  filter?: ModelStaffAttendanceFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListStaffAttendancesQuery = {
  listStaffAttendances?:  {
    __typename: "ModelStaffAttendanceConnection",
    items:  Array< {
      __typename: "StaffAttendance",
      attendance_date?: string | null,
      check_in_time?: string | null,
      check_out_time?: string | null,
      createdAt: string,
      id: string,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListStaffLocationsQueryVariables = {
  filter?: ModelStaffLocationsFilterInput | null,
  limit?: number | null,
  nextToken?: string | null,
};

export type ListStaffLocationsQuery = {
  listStaffLocations?:  {
    __typename: "ModelStaffLocationsConnection",
    items:  Array< {
      __typename: "StaffLocations",
      createdAt: string,
      id: string,
      latitude?: number | null,
      longitude?: number | null,
      updatedAt: string,
      updated_at?: string | null,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListSysCronLogsQueryVariables = {
  filter?: ModelSysCronLogsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListSysCronLogsQuery = {
  listSysCronLogs?:  {
    __typename: "ModelSysCronLogsConnection",
    items:  Array< {
      __typename: "SysCronLogs",
      createdAt: string,
      id: string,
      job_name?: string | null,
      last_run_date?: string | null,
      updatedAt: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListTasksQueryVariables = {
  filter?: ModelTasksFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListTasksQuery = {
  listTasks?:  {
    __typename: "ModelTasksConnection",
    items:  Array< {
      __typename: "Tasks",
      assigned_by?: number | null,
      assigned_to?: number | null,
      client_name?: string | null,
      createdAt: string,
      created_at?: string | null,
      description?: string | null,
      due_date?: string | null,
      id: string,
      location?: string | null,
      phone_number?: string | null,
      status?: string | null,
      title?: string | null,
      updatedAt: string,
      updated_at?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListTravelLogsQueryVariables = {
  filter?: ModelTravelLogsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListTravelLogsQuery = {
  listTravelLogs?:  {
    __typename: "ModelTravelLogsConnection",
    items:  Array< {
      __typename: "TravelLogs",
      createdAt: string,
      created_at?: string | null,
      destination?: string | null,
      id: string,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListUserSessionsQueryVariables = {
  filter?: ModelUserSessionsFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListUserSessionsQuery = {
  listUserSessions?:  {
    __typename: "ModelUserSessionsConnection",
    items:  Array< {
      __typename: "UserSessions",
      active_seconds?: number | null,
      createdAt: string,
      id: string,
      idle_seconds?: number | null,
      ip_address?: string | null,
      is_active?: boolean | null,
      login_time?: string | null,
      logout_time?: string | null,
      status?: string | null,
      updatedAt: string,
      user_id?: number | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListUsersQueryVariables = {
  filter?: ModelUsersFilterInput | null,
  id?: string | null,
  limit?: number | null,
  nextToken?: string | null,
  sortDirection?: ModelSortDirection | null,
};

export type ListUsersQuery = {
  listUsers?:  {
    __typename: "ModelUsersConnection",
    items:  Array< {
      __typename: "Users",
      createdAt: string,
      created_at?: string | null,
      email?: string | null,
      id: string,
      last_seen?: string | null,
      name?: string | null,
      password?: string | null,
      role?: string | null,
      updatedAt: string,
      username?: string | null,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type CreateActivityLogsMutationVariables = {
  condition?: ModelActivityLogsConditionInput | null,
  input: CreateActivityLogsInput,
};

export type CreateActivityLogsMutation = {
  createActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateBillingsMutationVariables = {
  condition?: ModelBillingsConditionInput | null,
  input: CreateBillingsInput,
};

export type CreateBillingsMutation = {
  createBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateChecklistsMutationVariables = {
  condition?: ModelChecklistsConditionInput | null,
  input: CreateChecklistsInput,
};

export type CreateChecklistsMutation = {
  createChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type CreateClientDocumentsMutationVariables = {
  condition?: ModelClientDocumentsConditionInput | null,
  input: CreateClientDocumentsInput,
};

export type CreateClientDocumentsMutation = {
  createClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateClientLicensesMutationVariables = {
  condition?: ModelClientLicensesConditionInput | null,
  input: CreateClientLicensesInput,
};

export type CreateClientLicensesMutation = {
  createClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type CreateClientsMutationVariables = {
  condition?: ModelClientsConditionInput | null,
  input: CreateClientsInput,
};

export type CreateClientsMutation = {
  createClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateCompanyBillsMutationVariables = {
  condition?: ModelCompanyBillsConditionInput | null,
  input: CreateCompanyBillsInput,
};

export type CreateCompanyBillsMutation = {
  createCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateDealActivitiesMutationVariables = {
  condition?: ModelDealActivitiesConditionInput | null,
  input: CreateDealActivitiesInput,
};

export type CreateDealActivitiesMutation = {
  createDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateDealAssigneesMutationVariables = {
  condition?: ModelDealAssigneesConditionInput | null,
  input: CreateDealAssigneesInput,
};

export type CreateDealAssigneesMutation = {
  createDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateDealHandoverHistoryMutationVariables = {
  condition?: ModelDealHandoverHistoryConditionInput | null,
  input: CreateDealHandoverHistoryInput,
};

export type CreateDealHandoverHistoryMutation = {
  createDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type CreateDealStageHistoryMutationVariables = {
  condition?: ModelDealStageHistoryConditionInput | null,
  input: CreateDealStageHistoryInput,
};

export type CreateDealStageHistoryMutation = {
  createDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateDealsMutationVariables = {
  condition?: ModelDealsConditionInput | null,
  input: CreateDealsInput,
};

export type CreateDealsMutation = {
  createDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type CreateDscRecordsMutationVariables = {
  condition?: ModelDscRecordsConditionInput | null,
  input: CreateDscRecordsInput,
};

export type CreateDscRecordsMutation = {
  createDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type CreateInwardPostsMutationVariables = {
  condition?: ModelInwardPostsConditionInput | null,
  input: CreateInwardPostsInput,
};

export type CreateInwardPostsMutation = {
  createInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateLicenseBillingMutationVariables = {
  condition?: ModelLicenseBillingConditionInput | null,
  input: CreateLicenseBillingInput,
};

export type CreateLicenseBillingMutation = {
  createLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateLicenseNotificationsMutationVariables = {
  condition?: ModelLicenseNotificationsConditionInput | null,
  input: CreateLicenseNotificationsInput,
};

export type CreateLicenseNotificationsMutation = {
  createLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateLicenseServicesMutationVariables = {
  condition?: ModelLicenseServicesConditionInput | null,
  input: CreateLicenseServicesInput,
};

export type CreateLicenseServicesMutation = {
  createLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateLicenseTypesMutationVariables = {
  condition?: ModelLicenseTypesConditionInput | null,
  input: CreateLicenseTypesInput,
};

export type CreateLicenseTypesMutation = {
  createLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type CreateLocationHistoryMutationVariables = {
  condition?: ModelLocationHistoryConditionInput | null,
  input: CreateLocationHistoryInput,
};

export type CreateLocationHistoryMutation = {
  createLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateMessagesMutationVariables = {
  condition?: ModelMessagesConditionInput | null,
  input: CreateMessagesInput,
};

export type CreateMessagesMutation = {
  createMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type CreateNotificationsMutationVariables = {
  condition?: ModelNotificationsConditionInput | null,
  input: CreateNotificationsInput,
};

export type CreateNotificationsMutation = {
  createNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateServiceContentMutationVariables = {
  condition?: ModelServiceContentConditionInput | null,
  input: CreateServiceContentInput,
};

export type CreateServiceContentMutation = {
  createServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateServiceNamesMutationVariables = {
  condition?: ModelServiceNamesConditionInput | null,
  input: CreateServiceNamesInput,
};

export type CreateServiceNamesMutation = {
  createServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateStaffAttendanceMutationVariables = {
  condition?: ModelStaffAttendanceConditionInput | null,
  input: CreateStaffAttendanceInput,
};

export type CreateStaffAttendanceMutation = {
  createStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateStaffLocationsMutationVariables = {
  condition?: ModelStaffLocationsConditionInput | null,
  input: CreateStaffLocationsInput,
};

export type CreateStaffLocationsMutation = {
  createStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type CreateSysCronLogsMutationVariables = {
  condition?: ModelSysCronLogsConditionInput | null,
  input: CreateSysCronLogsInput,
};

export type CreateSysCronLogsMutation = {
  createSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type CreateTasksMutationVariables = {
  condition?: ModelTasksConditionInput | null,
  input: CreateTasksInput,
};

export type CreateTasksMutation = {
  createTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type CreateTravelLogsMutationVariables = {
  condition?: ModelTravelLogsConditionInput | null,
  input: CreateTravelLogsInput,
};

export type CreateTravelLogsMutation = {
  createTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateUserSessionsMutationVariables = {
  condition?: ModelUserSessionsConditionInput | null,
  input: CreateUserSessionsInput,
};

export type CreateUserSessionsMutation = {
  createUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type CreateUsersMutationVariables = {
  condition?: ModelUsersConditionInput | null,
  input: CreateUsersInput,
};

export type CreateUsersMutation = {
  createUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type DeleteActivityLogsMutationVariables = {
  condition?: ModelActivityLogsConditionInput | null,
  input: DeleteActivityLogsInput,
};

export type DeleteActivityLogsMutation = {
  deleteActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteBillingsMutationVariables = {
  condition?: ModelBillingsConditionInput | null,
  input: DeleteBillingsInput,
};

export type DeleteBillingsMutation = {
  deleteBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteChecklistsMutationVariables = {
  condition?: ModelChecklistsConditionInput | null,
  input: DeleteChecklistsInput,
};

export type DeleteChecklistsMutation = {
  deleteChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type DeleteClientDocumentsMutationVariables = {
  condition?: ModelClientDocumentsConditionInput | null,
  input: DeleteClientDocumentsInput,
};

export type DeleteClientDocumentsMutation = {
  deleteClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteClientLicensesMutationVariables = {
  condition?: ModelClientLicensesConditionInput | null,
  input: DeleteClientLicensesInput,
};

export type DeleteClientLicensesMutation = {
  deleteClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type DeleteClientsMutationVariables = {
  condition?: ModelClientsConditionInput | null,
  input: DeleteClientsInput,
};

export type DeleteClientsMutation = {
  deleteClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteCompanyBillsMutationVariables = {
  condition?: ModelCompanyBillsConditionInput | null,
  input: DeleteCompanyBillsInput,
};

export type DeleteCompanyBillsMutation = {
  deleteCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteDealActivitiesMutationVariables = {
  condition?: ModelDealActivitiesConditionInput | null,
  input: DeleteDealActivitiesInput,
};

export type DeleteDealActivitiesMutation = {
  deleteDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteDealAssigneesMutationVariables = {
  condition?: ModelDealAssigneesConditionInput | null,
  input: DeleteDealAssigneesInput,
};

export type DeleteDealAssigneesMutation = {
  deleteDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteDealHandoverHistoryMutationVariables = {
  condition?: ModelDealHandoverHistoryConditionInput | null,
  input: DeleteDealHandoverHistoryInput,
};

export type DeleteDealHandoverHistoryMutation = {
  deleteDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type DeleteDealStageHistoryMutationVariables = {
  condition?: ModelDealStageHistoryConditionInput | null,
  input: DeleteDealStageHistoryInput,
};

export type DeleteDealStageHistoryMutation = {
  deleteDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteDealsMutationVariables = {
  condition?: ModelDealsConditionInput | null,
  input: DeleteDealsInput,
};

export type DeleteDealsMutation = {
  deleteDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type DeleteDscRecordsMutationVariables = {
  condition?: ModelDscRecordsConditionInput | null,
  input: DeleteDscRecordsInput,
};

export type DeleteDscRecordsMutation = {
  deleteDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type DeleteInwardPostsMutationVariables = {
  condition?: ModelInwardPostsConditionInput | null,
  input: DeleteInwardPostsInput,
};

export type DeleteInwardPostsMutation = {
  deleteInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteLicenseBillingMutationVariables = {
  condition?: ModelLicenseBillingConditionInput | null,
  input: DeleteLicenseBillingInput,
};

export type DeleteLicenseBillingMutation = {
  deleteLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteLicenseNotificationsMutationVariables = {
  condition?: ModelLicenseNotificationsConditionInput | null,
  input: DeleteLicenseNotificationsInput,
};

export type DeleteLicenseNotificationsMutation = {
  deleteLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteLicenseServicesMutationVariables = {
  condition?: ModelLicenseServicesConditionInput | null,
  input: DeleteLicenseServicesInput,
};

export type DeleteLicenseServicesMutation = {
  deleteLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteLicenseTypesMutationVariables = {
  condition?: ModelLicenseTypesConditionInput | null,
  input: DeleteLicenseTypesInput,
};

export type DeleteLicenseTypesMutation = {
  deleteLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type DeleteLocationHistoryMutationVariables = {
  condition?: ModelLocationHistoryConditionInput | null,
  input: DeleteLocationHistoryInput,
};

export type DeleteLocationHistoryMutation = {
  deleteLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteMessagesMutationVariables = {
  condition?: ModelMessagesConditionInput | null,
  input: DeleteMessagesInput,
};

export type DeleteMessagesMutation = {
  deleteMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type DeleteNotificationsMutationVariables = {
  condition?: ModelNotificationsConditionInput | null,
  input: DeleteNotificationsInput,
};

export type DeleteNotificationsMutation = {
  deleteNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteServiceContentMutationVariables = {
  condition?: ModelServiceContentConditionInput | null,
  input: DeleteServiceContentInput,
};

export type DeleteServiceContentMutation = {
  deleteServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteServiceNamesMutationVariables = {
  condition?: ModelServiceNamesConditionInput | null,
  input: DeleteServiceNamesInput,
};

export type DeleteServiceNamesMutation = {
  deleteServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteStaffAttendanceMutationVariables = {
  condition?: ModelStaffAttendanceConditionInput | null,
  input: DeleteStaffAttendanceInput,
};

export type DeleteStaffAttendanceMutation = {
  deleteStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteStaffLocationsMutationVariables = {
  condition?: ModelStaffLocationsConditionInput | null,
  input: DeleteStaffLocationsInput,
};

export type DeleteStaffLocationsMutation = {
  deleteStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type DeleteSysCronLogsMutationVariables = {
  condition?: ModelSysCronLogsConditionInput | null,
  input: DeleteSysCronLogsInput,
};

export type DeleteSysCronLogsMutation = {
  deleteSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type DeleteTasksMutationVariables = {
  condition?: ModelTasksConditionInput | null,
  input: DeleteTasksInput,
};

export type DeleteTasksMutation = {
  deleteTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type DeleteTravelLogsMutationVariables = {
  condition?: ModelTravelLogsConditionInput | null,
  input: DeleteTravelLogsInput,
};

export type DeleteTravelLogsMutation = {
  deleteTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteUserSessionsMutationVariables = {
  condition?: ModelUserSessionsConditionInput | null,
  input: DeleteUserSessionsInput,
};

export type DeleteUserSessionsMutation = {
  deleteUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type DeleteUsersMutationVariables = {
  condition?: ModelUsersConditionInput | null,
  input: DeleteUsersInput,
};

export type DeleteUsersMutation = {
  deleteUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type UpdateActivityLogsMutationVariables = {
  condition?: ModelActivityLogsConditionInput | null,
  input: UpdateActivityLogsInput,
};

export type UpdateActivityLogsMutation = {
  updateActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateBillingsMutationVariables = {
  condition?: ModelBillingsConditionInput | null,
  input: UpdateBillingsInput,
};

export type UpdateBillingsMutation = {
  updateBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateChecklistsMutationVariables = {
  condition?: ModelChecklistsConditionInput | null,
  input: UpdateChecklistsInput,
};

export type UpdateChecklistsMutation = {
  updateChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type UpdateClientDocumentsMutationVariables = {
  condition?: ModelClientDocumentsConditionInput | null,
  input: UpdateClientDocumentsInput,
};

export type UpdateClientDocumentsMutation = {
  updateClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateClientLicensesMutationVariables = {
  condition?: ModelClientLicensesConditionInput | null,
  input: UpdateClientLicensesInput,
};

export type UpdateClientLicensesMutation = {
  updateClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type UpdateClientsMutationVariables = {
  condition?: ModelClientsConditionInput | null,
  input: UpdateClientsInput,
};

export type UpdateClientsMutation = {
  updateClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateCompanyBillsMutationVariables = {
  condition?: ModelCompanyBillsConditionInput | null,
  input: UpdateCompanyBillsInput,
};

export type UpdateCompanyBillsMutation = {
  updateCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateDealActivitiesMutationVariables = {
  condition?: ModelDealActivitiesConditionInput | null,
  input: UpdateDealActivitiesInput,
};

export type UpdateDealActivitiesMutation = {
  updateDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateDealAssigneesMutationVariables = {
  condition?: ModelDealAssigneesConditionInput | null,
  input: UpdateDealAssigneesInput,
};

export type UpdateDealAssigneesMutation = {
  updateDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateDealHandoverHistoryMutationVariables = {
  condition?: ModelDealHandoverHistoryConditionInput | null,
  input: UpdateDealHandoverHistoryInput,
};

export type UpdateDealHandoverHistoryMutation = {
  updateDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type UpdateDealStageHistoryMutationVariables = {
  condition?: ModelDealStageHistoryConditionInput | null,
  input: UpdateDealStageHistoryInput,
};

export type UpdateDealStageHistoryMutation = {
  updateDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateDealsMutationVariables = {
  condition?: ModelDealsConditionInput | null,
  input: UpdateDealsInput,
};

export type UpdateDealsMutation = {
  updateDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type UpdateDscRecordsMutationVariables = {
  condition?: ModelDscRecordsConditionInput | null,
  input: UpdateDscRecordsInput,
};

export type UpdateDscRecordsMutation = {
  updateDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type UpdateInwardPostsMutationVariables = {
  condition?: ModelInwardPostsConditionInput | null,
  input: UpdateInwardPostsInput,
};

export type UpdateInwardPostsMutation = {
  updateInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateLicenseBillingMutationVariables = {
  condition?: ModelLicenseBillingConditionInput | null,
  input: UpdateLicenseBillingInput,
};

export type UpdateLicenseBillingMutation = {
  updateLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateLicenseNotificationsMutationVariables = {
  condition?: ModelLicenseNotificationsConditionInput | null,
  input: UpdateLicenseNotificationsInput,
};

export type UpdateLicenseNotificationsMutation = {
  updateLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateLicenseServicesMutationVariables = {
  condition?: ModelLicenseServicesConditionInput | null,
  input: UpdateLicenseServicesInput,
};

export type UpdateLicenseServicesMutation = {
  updateLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateLicenseTypesMutationVariables = {
  condition?: ModelLicenseTypesConditionInput | null,
  input: UpdateLicenseTypesInput,
};

export type UpdateLicenseTypesMutation = {
  updateLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type UpdateLocationHistoryMutationVariables = {
  condition?: ModelLocationHistoryConditionInput | null,
  input: UpdateLocationHistoryInput,
};

export type UpdateLocationHistoryMutation = {
  updateLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateMessagesMutationVariables = {
  condition?: ModelMessagesConditionInput | null,
  input: UpdateMessagesInput,
};

export type UpdateMessagesMutation = {
  updateMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type UpdateNotificationsMutationVariables = {
  condition?: ModelNotificationsConditionInput | null,
  input: UpdateNotificationsInput,
};

export type UpdateNotificationsMutation = {
  updateNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateServiceContentMutationVariables = {
  condition?: ModelServiceContentConditionInput | null,
  input: UpdateServiceContentInput,
};

export type UpdateServiceContentMutation = {
  updateServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateServiceNamesMutationVariables = {
  condition?: ModelServiceNamesConditionInput | null,
  input: UpdateServiceNamesInput,
};

export type UpdateServiceNamesMutation = {
  updateServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateStaffAttendanceMutationVariables = {
  condition?: ModelStaffAttendanceConditionInput | null,
  input: UpdateStaffAttendanceInput,
};

export type UpdateStaffAttendanceMutation = {
  updateStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateStaffLocationsMutationVariables = {
  condition?: ModelStaffLocationsConditionInput | null,
  input: UpdateStaffLocationsInput,
};

export type UpdateStaffLocationsMutation = {
  updateStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type UpdateSysCronLogsMutationVariables = {
  condition?: ModelSysCronLogsConditionInput | null,
  input: UpdateSysCronLogsInput,
};

export type UpdateSysCronLogsMutation = {
  updateSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type UpdateTasksMutationVariables = {
  condition?: ModelTasksConditionInput | null,
  input: UpdateTasksInput,
};

export type UpdateTasksMutation = {
  updateTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type UpdateTravelLogsMutationVariables = {
  condition?: ModelTravelLogsConditionInput | null,
  input: UpdateTravelLogsInput,
};

export type UpdateTravelLogsMutation = {
  updateTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateUserSessionsMutationVariables = {
  condition?: ModelUserSessionsConditionInput | null,
  input: UpdateUserSessionsInput,
};

export type UpdateUserSessionsMutation = {
  updateUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type UpdateUsersMutationVariables = {
  condition?: ModelUsersConditionInput | null,
  input: UpdateUsersInput,
};

export type UpdateUsersMutation = {
  updateUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type OnCreateActivityLogsSubscriptionVariables = {
  filter?: ModelSubscriptionActivityLogsFilterInput | null,
};

export type OnCreateActivityLogsSubscription = {
  onCreateActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateBillingsSubscriptionVariables = {
  filter?: ModelSubscriptionBillingsFilterInput | null,
};

export type OnCreateBillingsSubscription = {
  onCreateBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateChecklistsSubscriptionVariables = {
  filter?: ModelSubscriptionChecklistsFilterInput | null,
};

export type OnCreateChecklistsSubscription = {
  onCreateChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnCreateClientDocumentsSubscriptionVariables = {
  filter?: ModelSubscriptionClientDocumentsFilterInput | null,
};

export type OnCreateClientDocumentsSubscription = {
  onCreateClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateClientLicensesSubscriptionVariables = {
  filter?: ModelSubscriptionClientLicensesFilterInput | null,
};

export type OnCreateClientLicensesSubscription = {
  onCreateClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnCreateClientsSubscriptionVariables = {
  filter?: ModelSubscriptionClientsFilterInput | null,
};

export type OnCreateClientsSubscription = {
  onCreateClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateCompanyBillsSubscriptionVariables = {
  filter?: ModelSubscriptionCompanyBillsFilterInput | null,
};

export type OnCreateCompanyBillsSubscription = {
  onCreateCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateDealActivitiesSubscriptionVariables = {
  filter?: ModelSubscriptionDealActivitiesFilterInput | null,
};

export type OnCreateDealActivitiesSubscription = {
  onCreateDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateDealAssigneesSubscriptionVariables = {
  filter?: ModelSubscriptionDealAssigneesFilterInput | null,
};

export type OnCreateDealAssigneesSubscription = {
  onCreateDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateDealHandoverHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealHandoverHistoryFilterInput | null,
};

export type OnCreateDealHandoverHistorySubscription = {
  onCreateDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnCreateDealStageHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealStageHistoryFilterInput | null,
};

export type OnCreateDealStageHistorySubscription = {
  onCreateDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateDealsSubscriptionVariables = {
  filter?: ModelSubscriptionDealsFilterInput | null,
};

export type OnCreateDealsSubscription = {
  onCreateDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type OnCreateDscRecordsSubscriptionVariables = {
  filter?: ModelSubscriptionDscRecordsFilterInput | null,
};

export type OnCreateDscRecordsSubscription = {
  onCreateDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type OnCreateInwardPostsSubscriptionVariables = {
  filter?: ModelSubscriptionInwardPostsFilterInput | null,
};

export type OnCreateInwardPostsSubscription = {
  onCreateInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateLicenseBillingSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseBillingFilterInput | null,
};

export type OnCreateLicenseBillingSubscription = {
  onCreateLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateLicenseNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseNotificationsFilterInput | null,
};

export type OnCreateLicenseNotificationsSubscription = {
  onCreateLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateLicenseServicesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseServicesFilterInput | null,
};

export type OnCreateLicenseServicesSubscription = {
  onCreateLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateLicenseTypesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseTypesFilterInput | null,
};

export type OnCreateLicenseTypesSubscription = {
  onCreateLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnCreateLocationHistorySubscriptionVariables = {
  filter?: ModelSubscriptionLocationHistoryFilterInput | null,
};

export type OnCreateLocationHistorySubscription = {
  onCreateLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateMessagesSubscriptionVariables = {
  filter?: ModelSubscriptionMessagesFilterInput | null,
};

export type OnCreateMessagesSubscription = {
  onCreateMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnCreateNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionNotificationsFilterInput | null,
};

export type OnCreateNotificationsSubscription = {
  onCreateNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateServiceContentSubscriptionVariables = {
  filter?: ModelSubscriptionServiceContentFilterInput | null,
};

export type OnCreateServiceContentSubscription = {
  onCreateServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateServiceNamesSubscriptionVariables = {
  filter?: ModelSubscriptionServiceNamesFilterInput | null,
};

export type OnCreateServiceNamesSubscription = {
  onCreateServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateStaffAttendanceSubscriptionVariables = {
  filter?: ModelSubscriptionStaffAttendanceFilterInput | null,
};

export type OnCreateStaffAttendanceSubscription = {
  onCreateStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateStaffLocationsSubscriptionVariables = {
  filter?: ModelSubscriptionStaffLocationsFilterInput | null,
};

export type OnCreateStaffLocationsSubscription = {
  onCreateStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type OnCreateSysCronLogsSubscriptionVariables = {
  filter?: ModelSubscriptionSysCronLogsFilterInput | null,
};

export type OnCreateSysCronLogsSubscription = {
  onCreateSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnCreateTasksSubscriptionVariables = {
  filter?: ModelSubscriptionTasksFilterInput | null,
};

export type OnCreateTasksSubscription = {
  onCreateTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnCreateTravelLogsSubscriptionVariables = {
  filter?: ModelSubscriptionTravelLogsFilterInput | null,
};

export type OnCreateTravelLogsSubscription = {
  onCreateTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateUserSessionsSubscriptionVariables = {
  filter?: ModelSubscriptionUserSessionsFilterInput | null,
};

export type OnCreateUserSessionsSubscription = {
  onCreateUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnCreateUsersSubscriptionVariables = {
  filter?: ModelSubscriptionUsersFilterInput | null,
};

export type OnCreateUsersSubscription = {
  onCreateUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type OnDeleteActivityLogsSubscriptionVariables = {
  filter?: ModelSubscriptionActivityLogsFilterInput | null,
};

export type OnDeleteActivityLogsSubscription = {
  onDeleteActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteBillingsSubscriptionVariables = {
  filter?: ModelSubscriptionBillingsFilterInput | null,
};

export type OnDeleteBillingsSubscription = {
  onDeleteBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteChecklistsSubscriptionVariables = {
  filter?: ModelSubscriptionChecklistsFilterInput | null,
};

export type OnDeleteChecklistsSubscription = {
  onDeleteChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnDeleteClientDocumentsSubscriptionVariables = {
  filter?: ModelSubscriptionClientDocumentsFilterInput | null,
};

export type OnDeleteClientDocumentsSubscription = {
  onDeleteClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteClientLicensesSubscriptionVariables = {
  filter?: ModelSubscriptionClientLicensesFilterInput | null,
};

export type OnDeleteClientLicensesSubscription = {
  onDeleteClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnDeleteClientsSubscriptionVariables = {
  filter?: ModelSubscriptionClientsFilterInput | null,
};

export type OnDeleteClientsSubscription = {
  onDeleteClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteCompanyBillsSubscriptionVariables = {
  filter?: ModelSubscriptionCompanyBillsFilterInput | null,
};

export type OnDeleteCompanyBillsSubscription = {
  onDeleteCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteDealActivitiesSubscriptionVariables = {
  filter?: ModelSubscriptionDealActivitiesFilterInput | null,
};

export type OnDeleteDealActivitiesSubscription = {
  onDeleteDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteDealAssigneesSubscriptionVariables = {
  filter?: ModelSubscriptionDealAssigneesFilterInput | null,
};

export type OnDeleteDealAssigneesSubscription = {
  onDeleteDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteDealHandoverHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealHandoverHistoryFilterInput | null,
};

export type OnDeleteDealHandoverHistorySubscription = {
  onDeleteDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteDealStageHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealStageHistoryFilterInput | null,
};

export type OnDeleteDealStageHistorySubscription = {
  onDeleteDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteDealsSubscriptionVariables = {
  filter?: ModelSubscriptionDealsFilterInput | null,
};

export type OnDeleteDealsSubscription = {
  onDeleteDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type OnDeleteDscRecordsSubscriptionVariables = {
  filter?: ModelSubscriptionDscRecordsFilterInput | null,
};

export type OnDeleteDscRecordsSubscription = {
  onDeleteDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type OnDeleteInwardPostsSubscriptionVariables = {
  filter?: ModelSubscriptionInwardPostsFilterInput | null,
};

export type OnDeleteInwardPostsSubscription = {
  onDeleteInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteLicenseBillingSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseBillingFilterInput | null,
};

export type OnDeleteLicenseBillingSubscription = {
  onDeleteLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteLicenseNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseNotificationsFilterInput | null,
};

export type OnDeleteLicenseNotificationsSubscription = {
  onDeleteLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteLicenseServicesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseServicesFilterInput | null,
};

export type OnDeleteLicenseServicesSubscription = {
  onDeleteLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteLicenseTypesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseTypesFilterInput | null,
};

export type OnDeleteLicenseTypesSubscription = {
  onDeleteLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnDeleteLocationHistorySubscriptionVariables = {
  filter?: ModelSubscriptionLocationHistoryFilterInput | null,
};

export type OnDeleteLocationHistorySubscription = {
  onDeleteLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteMessagesSubscriptionVariables = {
  filter?: ModelSubscriptionMessagesFilterInput | null,
};

export type OnDeleteMessagesSubscription = {
  onDeleteMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionNotificationsFilterInput | null,
};

export type OnDeleteNotificationsSubscription = {
  onDeleteNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteServiceContentSubscriptionVariables = {
  filter?: ModelSubscriptionServiceContentFilterInput | null,
};

export type OnDeleteServiceContentSubscription = {
  onDeleteServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteServiceNamesSubscriptionVariables = {
  filter?: ModelSubscriptionServiceNamesFilterInput | null,
};

export type OnDeleteServiceNamesSubscription = {
  onDeleteServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteStaffAttendanceSubscriptionVariables = {
  filter?: ModelSubscriptionStaffAttendanceFilterInput | null,
};

export type OnDeleteStaffAttendanceSubscription = {
  onDeleteStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteStaffLocationsSubscriptionVariables = {
  filter?: ModelSubscriptionStaffLocationsFilterInput | null,
};

export type OnDeleteStaffLocationsSubscription = {
  onDeleteStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type OnDeleteSysCronLogsSubscriptionVariables = {
  filter?: ModelSubscriptionSysCronLogsFilterInput | null,
};

export type OnDeleteSysCronLogsSubscription = {
  onDeleteSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnDeleteTasksSubscriptionVariables = {
  filter?: ModelSubscriptionTasksFilterInput | null,
};

export type OnDeleteTasksSubscription = {
  onDeleteTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnDeleteTravelLogsSubscriptionVariables = {
  filter?: ModelSubscriptionTravelLogsFilterInput | null,
};

export type OnDeleteTravelLogsSubscription = {
  onDeleteTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteUserSessionsSubscriptionVariables = {
  filter?: ModelSubscriptionUserSessionsFilterInput | null,
};

export type OnDeleteUserSessionsSubscription = {
  onDeleteUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnDeleteUsersSubscriptionVariables = {
  filter?: ModelSubscriptionUsersFilterInput | null,
};

export type OnDeleteUsersSubscription = {
  onDeleteUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};

export type OnUpdateActivityLogsSubscriptionVariables = {
  filter?: ModelSubscriptionActivityLogsFilterInput | null,
};

export type OnUpdateActivityLogsSubscription = {
  onUpdateActivityLogs?:  {
    __typename: "ActivityLogs",
    action?: string | null,
    createdAt: string,
    created_at?: string | null,
    details?: string | null,
    id: string,
    target_id?: string | null,
    target_type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateBillingsSubscriptionVariables = {
  filter?: ModelSubscriptionBillingsFilterInput | null,
};

export type OnUpdateBillingsSubscription = {
  onUpdateBillings?:  {
    __typename: "Billings",
    amount?: string | null,
    authorities?: string | null,
    category?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    data?: string | null,
    date?: string | null,
    id: string,
    invoice_no?: string | null,
    status?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateChecklistsSubscriptionVariables = {
  filter?: ModelSubscriptionChecklistsFilterInput | null,
};

export type OnUpdateChecklistsSubscription = {
  onUpdateChecklists?:  {
    __typename: "Checklists",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    manager_id?: number | null,
    reason?: string | null,
    remarks?: string | null,
    responsible_id?: number | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnUpdateClientDocumentsSubscriptionVariables = {
  filter?: ModelSubscriptionClientDocumentsFilterInput | null,
};

export type OnUpdateClientDocumentsSubscription = {
  onUpdateClientDocuments?:  {
    __typename: "ClientDocuments",
    client_id?: string | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    document_name?: string | null,
    id: string,
    og_copy?: string | null,
    remarks?: string | null,
    storage_path?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateClientLicensesSubscriptionVariables = {
  filter?: ModelSubscriptionClientLicensesFilterInput | null,
};

export type OnUpdateClientLicensesSubscription = {
  onUpdateClientLicenses?:  {
    __typename: "ClientLicenses",
    client_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    expiry_date?: string | null,
    file_no?: string | null,
    id: string,
    license_type_id?: number | null,
    manual_client_name?: string | null,
    notes?: string | null,
    service_date?: string | null,
    status?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnUpdateClientsSubscriptionVariables = {
  filter?: ModelSubscriptionClientsFilterInput | null,
};

export type OnUpdateClientsSubscription = {
  onUpdateClients?:  {
    __typename: "Clients",
    address?: string | null,
    balance_due?: string | null,
    case_number?: string | null,
    createdAt: string,
    created_at?: string | null,
    dob?: string | null,
    email?: string | null,
    file_date?: string | null,
    file_no?: string | null,
    id: string,
    is_contacted?: boolean | null,
    managed_by?: string | null,
    name?: string | null,
    phone?: string | null,
    review_rating?: number | null,
    type_of_work?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateCompanyBillsSubscriptionVariables = {
  filter?: ModelSubscriptionCompanyBillsFilterInput | null,
};

export type OnUpdateCompanyBillsSubscription = {
  onUpdateCompanyBills?:  {
    __typename: "CompanyBills",
    amount?: number | null,
    bill_date?: string | null,
    category?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    spent_by?: number | null,
    spent_by_name?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateDealActivitiesSubscriptionVariables = {
  filter?: ModelSubscriptionDealActivitiesFilterInput | null,
};

export type OnUpdateDealActivitiesSubscription = {
  onUpdateDealActivities?:  {
    __typename: "DealActivities",
    createdAt: string,
    created_at?: string | null,
    created_by?: number | null,
    deal_id?: number | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    is_completed?: boolean | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateDealAssigneesSubscriptionVariables = {
  filter?: ModelSubscriptionDealAssigneesFilterInput | null,
};

export type OnUpdateDealAssigneesSubscription = {
  onUpdateDealAssignees?:  {
    __typename: "DealAssignees",
    assigned_at?: string | null,
    createdAt: string,
    deal_id?: number | null,
    id: string,
    role?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateDealHandoverHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealHandoverHistoryFilterInput | null,
};

export type OnUpdateDealHandoverHistorySubscription = {
  onUpdateDealHandoverHistory?:  {
    __typename: "DealHandoverHistory",
    createdAt: string,
    deal_id?: number | null,
    from_user_id?: number | null,
    handed_over_at?: string | null,
    id: string,
    note?: string | null,
    to_user_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateDealStageHistorySubscriptionVariables = {
  filter?: ModelSubscriptionDealStageHistoryFilterInput | null,
};

export type OnUpdateDealStageHistorySubscription = {
  onUpdateDealStageHistory?:  {
    __typename: "DealStageHistory",
    changed_at?: string | null,
    changed_by?: number | null,
    createdAt: string,
    deal_id?: number | null,
    from_stage?: string | null,
    id: string,
    to_stage?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateDealsSubscriptionVariables = {
  filter?: ModelSubscriptionDealsFilterInput | null,
};

export type OnUpdateDealsSubscription = {
  onUpdateDeals?:  {
    __typename: "Deals",
    amount?: number | null,
    billing_id?: number | null,
    client_id?: number | null,
    client_name?: string | null,
    closed_at?: string | null,
    company?: string | null,
    contact_info?: string | null,
    contact_status?: string | null,
    create_invoice_share?: string | null,
    createdAt: string,
    created_at?: string | null,
    currency?: string | null,
    description?: string | null,
    drive_link?: string | null,
    est_amount_work?: number | null,
    expense_spent?: number | null,
    expenses_list?: string | null,
    files_asked?: string | null,
    files_received?: string | null,
    id: string,
    invoice_amount?: number | null,
    is_won?: boolean | null,
    name?: string | null,
    noc_obtained?: boolean | null,
    part_payment_amount?: number | null,
    payment_received?: number | null,
    payment_type?: string | null,
    pipeline?: string | null,
    priority?: string | null,
    quotation_id?: number | null,
    referred_by?: string | null,
    reg_fee_required?: string | null,
    register_no?: string | null,
    responsible_id?: number | null,
    responsible_name?: string | null,
    send_to_customer?: string | null,
    stage?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    upload_invoice_path?: string | null,
    work_type?: string | null,
  } | null,
};

export type OnUpdateDscRecordsSubscriptionVariables = {
  filter?: ModelSubscriptionDscRecordsFilterInput | null,
};

export type OnUpdateDscRecordsSubscription = {
  onUpdateDscRecords?:  {
    __typename: "DscRecords",
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    dsc_expiry_date?: string | null,
    dsc_taken_date?: string | null,
    email_id?: string | null,
    id: string,
    password?: string | null,
    phone_no?: string | null,
    updatedAt: string,
    updated_at?: string | null,
    username?: string | null,
  } | null,
};

export type OnUpdateInwardPostsSubscriptionVariables = {
  filter?: ModelSubscriptionInwardPostsFilterInput | null,
};

export type OnUpdateInwardPostsSubscription = {
  onUpdateInwardPosts?:  {
    __typename: "InwardPosts",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    received_by?: string | null,
    received_date?: string | null,
    recipient_name?: string | null,
    sender_name?: string | null,
    status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateLicenseBillingSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseBillingFilterInput | null,
};

export type OnUpdateLicenseBillingSubscription = {
  onUpdateLicenseBilling?:  {
    __typename: "LicenseBilling",
    amount?: number | null,
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    invoice_no?: string | null,
    payment_date?: string | null,
    payment_status?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateLicenseNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseNotificationsFilterInput | null,
};

export type OnUpdateLicenseNotificationsSubscription = {
  onUpdateLicenseNotifications?:  {
    __typename: "LicenseNotifications",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_sent?: boolean | null,
    message?: string | null,
    notification_type?: string | null,
    scheduled_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateLicenseServicesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseServicesFilterInput | null,
};

export type OnUpdateLicenseServicesSubscription = {
  onUpdateLicenseServices?:  {
    __typename: "LicenseServices",
    client_license_id?: number | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    service_cost?: number | null,
    service_date?: string | null,
    service_description?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateLicenseTypesSubscriptionVariables = {
  filter?: ModelSubscriptionLicenseTypesFilterInput | null,
};

export type OnUpdateLicenseTypesSubscription = {
  onUpdateLicenseTypes?:  {
    __typename: "LicenseTypes",
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnUpdateLocationHistorySubscriptionVariables = {
  filter?: ModelSubscriptionLocationHistoryFilterInput | null,
};

export type OnUpdateLocationHistorySubscription = {
  onUpdateLocationHistory?:  {
    __typename: "LocationHistory",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    recorded_at?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateMessagesSubscriptionVariables = {
  filter?: ModelSubscriptionMessagesFilterInput | null,
};

export type OnUpdateMessagesSubscription = {
  onUpdateMessages?:  {
    __typename: "Messages",
    attachment_id?: number | null,
    attachment_type?: string | null,
    content?: string | null,
    createdAt: string,
    created_at?: string | null,
    id: string,
    is_read?: boolean | null,
    receiver_id?: number | null,
    sender_id?: number | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateNotificationsSubscriptionVariables = {
  filter?: ModelSubscriptionNotificationsFilterInput | null,
};

export type OnUpdateNotificationsSubscription = {
  onUpdateNotifications?:  {
    __typename: "Notifications",
    createdAt: string,
    created_at?: string | null,
    deal_id?: number | null,
    id: string,
    is_read?: boolean | null,
    message?: string | null,
    task_id?: number | null,
    title?: string | null,
    type?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateServiceContentSubscriptionVariables = {
  filter?: ModelSubscriptionServiceContentFilterInput | null,
};

export type OnUpdateServiceContentSubscription = {
  onUpdateServiceContent?:  {
    __typename: "ServiceContent",
    createdAt: string,
    description?: string | null,
    details?: string | null,
    id: string,
    image_path?: string | null,
    service_id?: number | null,
    title?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateServiceNamesSubscriptionVariables = {
  filter?: ModelSubscriptionServiceNamesFilterInput | null,
};

export type OnUpdateServiceNamesSubscription = {
  onUpdateServiceNames?:  {
    __typename: "ServiceNames",
    createdAt: string,
    created_at?: string | null,
    id: string,
    name?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateStaffAttendanceSubscriptionVariables = {
  filter?: ModelSubscriptionStaffAttendanceFilterInput | null,
};

export type OnUpdateStaffAttendanceSubscription = {
  onUpdateStaffAttendance?:  {
    __typename: "StaffAttendance",
    attendance_date?: string | null,
    check_in_time?: string | null,
    check_out_time?: string | null,
    createdAt: string,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateStaffLocationsSubscriptionVariables = {
  filter?: ModelSubscriptionStaffLocationsFilterInput | null,
};

export type OnUpdateStaffLocationsSubscription = {
  onUpdateStaffLocations?:  {
    __typename: "StaffLocations",
    createdAt: string,
    id: string,
    latitude?: number | null,
    longitude?: number | null,
    updatedAt: string,
    updated_at?: string | null,
    user_id?: number | null,
  } | null,
};

export type OnUpdateSysCronLogsSubscriptionVariables = {
  filter?: ModelSubscriptionSysCronLogsFilterInput | null,
};

export type OnUpdateSysCronLogsSubscription = {
  onUpdateSysCronLogs?:  {
    __typename: "SysCronLogs",
    createdAt: string,
    id: string,
    job_name?: string | null,
    last_run_date?: string | null,
    updatedAt: string,
  } | null,
};

export type OnUpdateTasksSubscriptionVariables = {
  filter?: ModelSubscriptionTasksFilterInput | null,
};

export type OnUpdateTasksSubscription = {
  onUpdateTasks?:  {
    __typename: "Tasks",
    assigned_by?: number | null,
    assigned_to?: number | null,
    client_name?: string | null,
    createdAt: string,
    created_at?: string | null,
    description?: string | null,
    due_date?: string | null,
    id: string,
    location?: string | null,
    phone_number?: string | null,
    status?: string | null,
    title?: string | null,
    updatedAt: string,
    updated_at?: string | null,
  } | null,
};

export type OnUpdateTravelLogsSubscriptionVariables = {
  filter?: ModelSubscriptionTravelLogsFilterInput | null,
};

export type OnUpdateTravelLogsSubscription = {
  onUpdateTravelLogs?:  {
    __typename: "TravelLogs",
    createdAt: string,
    created_at?: string | null,
    destination?: string | null,
    id: string,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateUserSessionsSubscriptionVariables = {
  filter?: ModelSubscriptionUserSessionsFilterInput | null,
};

export type OnUpdateUserSessionsSubscription = {
  onUpdateUserSessions?:  {
    __typename: "UserSessions",
    active_seconds?: number | null,
    createdAt: string,
    id: string,
    idle_seconds?: number | null,
    ip_address?: string | null,
    is_active?: boolean | null,
    login_time?: string | null,
    logout_time?: string | null,
    status?: string | null,
    updatedAt: string,
    user_id?: number | null,
  } | null,
};

export type OnUpdateUsersSubscriptionVariables = {
  filter?: ModelSubscriptionUsersFilterInput | null,
};

export type OnUpdateUsersSubscription = {
  onUpdateUsers?:  {
    __typename: "Users",
    createdAt: string,
    created_at?: string | null,
    email?: string | null,
    id: string,
    last_seen?: string | null,
    name?: string | null,
    password?: string | null,
    role?: string | null,
    updatedAt: string,
    username?: string | null,
  } | null,
};
