/* tslint:disable */
/* eslint-disable */
// this is an auto generated file. This will be overwritten

import * as APITypes from "./API";
type GeneratedMutation<InputType, OutputType> = string & {
  __generatedMutationInput: InputType;
  __generatedMutationOutput: OutputType;
};

export const createActivityLogs = /* GraphQL */ `mutation CreateActivityLogs(
  $condition: ModelActivityLogsConditionInput
  $input: CreateActivityLogsInput!
) {
  createActivityLogs(condition: $condition, input: $input) {
    action
    createdAt
    created_at
    details
    id
    target_id
    target_type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateActivityLogsMutationVariables,
  APITypes.CreateActivityLogsMutation
>;
export const createBillings = /* GraphQL */ `mutation CreateBillings(
  $condition: ModelBillingsConditionInput
  $input: CreateBillingsInput!
) {
  createBillings(condition: $condition, input: $input) {
    amount
    authorities
    category
    client_name
    createdAt
    created_at
    data
    date
    id
    invoice_no
    status
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateBillingsMutationVariables,
  APITypes.CreateBillingsMutation
>;
export const createChecklists = /* GraphQL */ `mutation CreateChecklists(
  $condition: ModelChecklistsConditionInput
  $input: CreateChecklistsInput!
) {
  createChecklists(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    due_date
    id
    manager_id
    reason
    remarks
    responsible_id
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateChecklistsMutationVariables,
  APITypes.CreateChecklistsMutation
>;
export const createClientDocuments = /* GraphQL */ `mutation CreateClientDocuments(
  $condition: ModelClientDocumentsConditionInput
  $input: CreateClientDocumentsInput!
) {
  createClientDocuments(condition: $condition, input: $input) {
    client_id
    client_name
    createdAt
    created_at
    document_name
    id
    og_copy
    remarks
    storage_path
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateClientDocumentsMutationVariables,
  APITypes.CreateClientDocumentsMutation
>;
export const createClientLicenses = /* GraphQL */ `mutation CreateClientLicenses(
  $condition: ModelClientLicensesConditionInput
  $input: CreateClientLicensesInput!
) {
  createClientLicenses(condition: $condition, input: $input) {
    client_id
    createdAt
    created_at
    expiry_date
    file_no
    id
    license_type_id
    manual_client_name
    notes
    service_date
    status
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateClientLicensesMutationVariables,
  APITypes.CreateClientLicensesMutation
>;
export const createClients = /* GraphQL */ `mutation CreateClients(
  $condition: ModelClientsConditionInput
  $input: CreateClientsInput!
) {
  createClients(condition: $condition, input: $input) {
    address
    balance_due
    case_number
    createdAt
    created_at
    dob
    email
    file_date
    file_no
    id
    is_contacted
    managed_by
    name
    phone
    review_rating
    type_of_work
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateClientsMutationVariables,
  APITypes.CreateClientsMutation
>;
export const createCompanyBills = /* GraphQL */ `mutation CreateCompanyBills(
  $condition: ModelCompanyBillsConditionInput
  $input: CreateCompanyBillsInput!
) {
  createCompanyBills(condition: $condition, input: $input) {
    amount
    bill_date
    category
    createdAt
    created_at
    description
    id
    spent_by
    spent_by_name
    status
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateCompanyBillsMutationVariables,
  APITypes.CreateCompanyBillsMutation
>;
export const createDealActivities = /* GraphQL */ `mutation CreateDealActivities(
  $condition: ModelDealActivitiesConditionInput
  $input: CreateDealActivitiesInput!
) {
  createDealActivities(condition: $condition, input: $input) {
    createdAt
    created_at
    created_by
    deal_id
    description
    due_date
    id
    is_completed
    title
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDealActivitiesMutationVariables,
  APITypes.CreateDealActivitiesMutation
>;
export const createDealAssignees = /* GraphQL */ `mutation CreateDealAssignees(
  $condition: ModelDealAssigneesConditionInput
  $input: CreateDealAssigneesInput!
) {
  createDealAssignees(condition: $condition, input: $input) {
    assigned_at
    createdAt
    deal_id
    id
    role
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDealAssigneesMutationVariables,
  APITypes.CreateDealAssigneesMutation
>;
export const createDealHandoverHistory = /* GraphQL */ `mutation CreateDealHandoverHistory(
  $condition: ModelDealHandoverHistoryConditionInput
  $input: CreateDealHandoverHistoryInput!
) {
  createDealHandoverHistory(condition: $condition, input: $input) {
    createdAt
    deal_id
    from_user_id
    handed_over_at
    id
    note
    to_user_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDealHandoverHistoryMutationVariables,
  APITypes.CreateDealHandoverHistoryMutation
>;
export const createDealStageHistory = /* GraphQL */ `mutation CreateDealStageHistory(
  $condition: ModelDealStageHistoryConditionInput
  $input: CreateDealStageHistoryInput!
) {
  createDealStageHistory(condition: $condition, input: $input) {
    changed_at
    changed_by
    createdAt
    deal_id
    from_stage
    id
    to_stage
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDealStageHistoryMutationVariables,
  APITypes.CreateDealStageHistoryMutation
>;
export const createDeals = /* GraphQL */ `mutation CreateDeals(
  $condition: ModelDealsConditionInput
  $input: CreateDealsInput!
) {
  createDeals(condition: $condition, input: $input) {
    amount
    billing_id
    client_id
    client_name
    closed_at
    company
    contact_info
    contact_status
    create_invoice_share
    createdAt
    created_at
    currency
    description
    drive_link
    est_amount_work
    expense_spent
    expenses_list
    files_asked
    files_received
    id
    invoice_amount
    is_won
    name
    noc_obtained
    part_payment_amount
    payment_received
    payment_type
    pipeline
    priority
    quotation_id
    referred_by
    reg_fee_required
    register_no
    responsible_id
    responsible_name
    send_to_customer
    stage
    updatedAt
    updated_at
    upload_invoice_path
    work_type
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDealsMutationVariables,
  APITypes.CreateDealsMutation
>;
export const createDscRecords = /* GraphQL */ `mutation CreateDscRecords(
  $condition: ModelDscRecordsConditionInput
  $input: CreateDscRecordsInput!
) {
  createDscRecords(condition: $condition, input: $input) {
    client_name
    createdAt
    created_at
    dsc_expiry_date
    dsc_taken_date
    email_id
    id
    password
    phone_no
    updatedAt
    updated_at
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateDscRecordsMutationVariables,
  APITypes.CreateDscRecordsMutation
>;
export const createInwardPosts = /* GraphQL */ `mutation CreateInwardPosts(
  $condition: ModelInwardPostsConditionInput
  $input: CreateInwardPostsInput!
) {
  createInwardPosts(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    received_by
    received_date
    recipient_name
    sender_name
    status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateInwardPostsMutationVariables,
  APITypes.CreateInwardPostsMutation
>;
export const createLicenseBilling = /* GraphQL */ `mutation CreateLicenseBilling(
  $condition: ModelLicenseBillingConditionInput
  $input: CreateLicenseBillingInput!
) {
  createLicenseBilling(condition: $condition, input: $input) {
    amount
    client_license_id
    createdAt
    created_at
    id
    invoice_no
    payment_date
    payment_status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateLicenseBillingMutationVariables,
  APITypes.CreateLicenseBillingMutation
>;
export const createLicenseNotifications = /* GraphQL */ `mutation CreateLicenseNotifications(
  $condition: ModelLicenseNotificationsConditionInput
  $input: CreateLicenseNotificationsInput!
) {
  createLicenseNotifications(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    is_sent
    message
    notification_type
    scheduled_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateLicenseNotificationsMutationVariables,
  APITypes.CreateLicenseNotificationsMutation
>;
export const createLicenseServices = /* GraphQL */ `mutation CreateLicenseServices(
  $condition: ModelLicenseServicesConditionInput
  $input: CreateLicenseServicesInput!
) {
  createLicenseServices(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    service_cost
    service_date
    service_description
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateLicenseServicesMutationVariables,
  APITypes.CreateLicenseServicesMutation
>;
export const createLicenseTypes = /* GraphQL */ `mutation CreateLicenseTypes(
  $condition: ModelLicenseTypesConditionInput
  $input: CreateLicenseTypesInput!
) {
  createLicenseTypes(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    name
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateLicenseTypesMutationVariables,
  APITypes.CreateLicenseTypesMutation
>;
export const createLocationHistory = /* GraphQL */ `mutation CreateLocationHistory(
  $condition: ModelLocationHistoryConditionInput
  $input: CreateLocationHistoryInput!
) {
  createLocationHistory(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    recorded_at
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateLocationHistoryMutationVariables,
  APITypes.CreateLocationHistoryMutation
>;
export const createMessages = /* GraphQL */ `mutation CreateMessages(
  $condition: ModelMessagesConditionInput
  $input: CreateMessagesInput!
) {
  createMessages(condition: $condition, input: $input) {
    attachment_id
    attachment_type
    content
    createdAt
    created_at
    id
    is_read
    receiver_id
    sender_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateMessagesMutationVariables,
  APITypes.CreateMessagesMutation
>;
export const createNotifications = /* GraphQL */ `mutation CreateNotifications(
  $condition: ModelNotificationsConditionInput
  $input: CreateNotificationsInput!
) {
  createNotifications(condition: $condition, input: $input) {
    createdAt
    created_at
    deal_id
    id
    is_read
    message
    task_id
    title
    type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateNotificationsMutationVariables,
  APITypes.CreateNotificationsMutation
>;
export const createServiceContent = /* GraphQL */ `mutation CreateServiceContent(
  $condition: ModelServiceContentConditionInput
  $input: CreateServiceContentInput!
) {
  createServiceContent(condition: $condition, input: $input) {
    createdAt
    description
    details
    id
    image_path
    service_id
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateServiceContentMutationVariables,
  APITypes.CreateServiceContentMutation
>;
export const createServiceNames = /* GraphQL */ `mutation CreateServiceNames(
  $condition: ModelServiceNamesConditionInput
  $input: CreateServiceNamesInput!
) {
  createServiceNames(condition: $condition, input: $input) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateServiceNamesMutationVariables,
  APITypes.CreateServiceNamesMutation
>;
export const createStaffAttendance = /* GraphQL */ `mutation CreateStaffAttendance(
  $condition: ModelStaffAttendanceConditionInput
  $input: CreateStaffAttendanceInput!
) {
  createStaffAttendance(condition: $condition, input: $input) {
    attendance_date
    check_in_time
    check_out_time
    createdAt
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateStaffAttendanceMutationVariables,
  APITypes.CreateStaffAttendanceMutation
>;
export const createStaffLocations = /* GraphQL */ `mutation CreateStaffLocations(
  $condition: ModelStaffLocationsConditionInput
  $input: CreateStaffLocationsInput!
) {
  createStaffLocations(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    updatedAt
    updated_at
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateStaffLocationsMutationVariables,
  APITypes.CreateStaffLocationsMutation
>;
export const createSysCronLogs = /* GraphQL */ `mutation CreateSysCronLogs(
  $condition: ModelSysCronLogsConditionInput
  $input: CreateSysCronLogsInput!
) {
  createSysCronLogs(condition: $condition, input: $input) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateSysCronLogsMutationVariables,
  APITypes.CreateSysCronLogsMutation
>;
export const createTasks = /* GraphQL */ `mutation CreateTasks(
  $condition: ModelTasksConditionInput
  $input: CreateTasksInput!
) {
  createTasks(condition: $condition, input: $input) {
    assigned_by
    assigned_to
    client_name
    createdAt
    created_at
    description
    due_date
    id
    location
    phone_number
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateTasksMutationVariables,
  APITypes.CreateTasksMutation
>;
export const createTravelLogs = /* GraphQL */ `mutation CreateTravelLogs(
  $condition: ModelTravelLogsConditionInput
  $input: CreateTravelLogsInput!
) {
  createTravelLogs(condition: $condition, input: $input) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateTravelLogsMutationVariables,
  APITypes.CreateTravelLogsMutation
>;
export const createUserSessions = /* GraphQL */ `mutation CreateUserSessions(
  $condition: ModelUserSessionsConditionInput
  $input: CreateUserSessionsInput!
) {
  createUserSessions(condition: $condition, input: $input) {
    active_seconds
    createdAt
    id
    idle_seconds
    ip_address
    is_active
    login_time
    logout_time
    status
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateUserSessionsMutationVariables,
  APITypes.CreateUserSessionsMutation
>;
export const createUsers = /* GraphQL */ `mutation CreateUsers(
  $condition: ModelUsersConditionInput
  $input: CreateUsersInput!
) {
  createUsers(condition: $condition, input: $input) {
    createdAt
    created_at
    email
    id
    last_seen
    name
    password
    role
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateUsersMutationVariables,
  APITypes.CreateUsersMutation
>;
export const deleteActivityLogs = /* GraphQL */ `mutation DeleteActivityLogs(
  $condition: ModelActivityLogsConditionInput
  $input: DeleteActivityLogsInput!
) {
  deleteActivityLogs(condition: $condition, input: $input) {
    action
    createdAt
    created_at
    details
    id
    target_id
    target_type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteActivityLogsMutationVariables,
  APITypes.DeleteActivityLogsMutation
>;
export const deleteBillings = /* GraphQL */ `mutation DeleteBillings(
  $condition: ModelBillingsConditionInput
  $input: DeleteBillingsInput!
) {
  deleteBillings(condition: $condition, input: $input) {
    amount
    authorities
    category
    client_name
    createdAt
    created_at
    data
    date
    id
    invoice_no
    status
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteBillingsMutationVariables,
  APITypes.DeleteBillingsMutation
>;
export const deleteChecklists = /* GraphQL */ `mutation DeleteChecklists(
  $condition: ModelChecklistsConditionInput
  $input: DeleteChecklistsInput!
) {
  deleteChecklists(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    due_date
    id
    manager_id
    reason
    remarks
    responsible_id
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteChecklistsMutationVariables,
  APITypes.DeleteChecklistsMutation
>;
export const deleteClientDocuments = /* GraphQL */ `mutation DeleteClientDocuments(
  $condition: ModelClientDocumentsConditionInput
  $input: DeleteClientDocumentsInput!
) {
  deleteClientDocuments(condition: $condition, input: $input) {
    client_id
    client_name
    createdAt
    created_at
    document_name
    id
    og_copy
    remarks
    storage_path
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteClientDocumentsMutationVariables,
  APITypes.DeleteClientDocumentsMutation
>;
export const deleteClientLicenses = /* GraphQL */ `mutation DeleteClientLicenses(
  $condition: ModelClientLicensesConditionInput
  $input: DeleteClientLicensesInput!
) {
  deleteClientLicenses(condition: $condition, input: $input) {
    client_id
    createdAt
    created_at
    expiry_date
    file_no
    id
    license_type_id
    manual_client_name
    notes
    service_date
    status
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteClientLicensesMutationVariables,
  APITypes.DeleteClientLicensesMutation
>;
export const deleteClients = /* GraphQL */ `mutation DeleteClients(
  $condition: ModelClientsConditionInput
  $input: DeleteClientsInput!
) {
  deleteClients(condition: $condition, input: $input) {
    address
    balance_due
    case_number
    createdAt
    created_at
    dob
    email
    file_date
    file_no
    id
    is_contacted
    managed_by
    name
    phone
    review_rating
    type_of_work
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteClientsMutationVariables,
  APITypes.DeleteClientsMutation
>;
export const deleteCompanyBills = /* GraphQL */ `mutation DeleteCompanyBills(
  $condition: ModelCompanyBillsConditionInput
  $input: DeleteCompanyBillsInput!
) {
  deleteCompanyBills(condition: $condition, input: $input) {
    amount
    bill_date
    category
    createdAt
    created_at
    description
    id
    spent_by
    spent_by_name
    status
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteCompanyBillsMutationVariables,
  APITypes.DeleteCompanyBillsMutation
>;
export const deleteDealActivities = /* GraphQL */ `mutation DeleteDealActivities(
  $condition: ModelDealActivitiesConditionInput
  $input: DeleteDealActivitiesInput!
) {
  deleteDealActivities(condition: $condition, input: $input) {
    createdAt
    created_at
    created_by
    deal_id
    description
    due_date
    id
    is_completed
    title
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDealActivitiesMutationVariables,
  APITypes.DeleteDealActivitiesMutation
>;
export const deleteDealAssignees = /* GraphQL */ `mutation DeleteDealAssignees(
  $condition: ModelDealAssigneesConditionInput
  $input: DeleteDealAssigneesInput!
) {
  deleteDealAssignees(condition: $condition, input: $input) {
    assigned_at
    createdAt
    deal_id
    id
    role
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDealAssigneesMutationVariables,
  APITypes.DeleteDealAssigneesMutation
>;
export const deleteDealHandoverHistory = /* GraphQL */ `mutation DeleteDealHandoverHistory(
  $condition: ModelDealHandoverHistoryConditionInput
  $input: DeleteDealHandoverHistoryInput!
) {
  deleteDealHandoverHistory(condition: $condition, input: $input) {
    createdAt
    deal_id
    from_user_id
    handed_over_at
    id
    note
    to_user_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDealHandoverHistoryMutationVariables,
  APITypes.DeleteDealHandoverHistoryMutation
>;
export const deleteDealStageHistory = /* GraphQL */ `mutation DeleteDealStageHistory(
  $condition: ModelDealStageHistoryConditionInput
  $input: DeleteDealStageHistoryInput!
) {
  deleteDealStageHistory(condition: $condition, input: $input) {
    changed_at
    changed_by
    createdAt
    deal_id
    from_stage
    id
    to_stage
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDealStageHistoryMutationVariables,
  APITypes.DeleteDealStageHistoryMutation
>;
export const deleteDeals = /* GraphQL */ `mutation DeleteDeals(
  $condition: ModelDealsConditionInput
  $input: DeleteDealsInput!
) {
  deleteDeals(condition: $condition, input: $input) {
    amount
    billing_id
    client_id
    client_name
    closed_at
    company
    contact_info
    contact_status
    create_invoice_share
    createdAt
    created_at
    currency
    description
    drive_link
    est_amount_work
    expense_spent
    expenses_list
    files_asked
    files_received
    id
    invoice_amount
    is_won
    name
    noc_obtained
    part_payment_amount
    payment_received
    payment_type
    pipeline
    priority
    quotation_id
    referred_by
    reg_fee_required
    register_no
    responsible_id
    responsible_name
    send_to_customer
    stage
    updatedAt
    updated_at
    upload_invoice_path
    work_type
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDealsMutationVariables,
  APITypes.DeleteDealsMutation
>;
export const deleteDscRecords = /* GraphQL */ `mutation DeleteDscRecords(
  $condition: ModelDscRecordsConditionInput
  $input: DeleteDscRecordsInput!
) {
  deleteDscRecords(condition: $condition, input: $input) {
    client_name
    createdAt
    created_at
    dsc_expiry_date
    dsc_taken_date
    email_id
    id
    password
    phone_no
    updatedAt
    updated_at
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteDscRecordsMutationVariables,
  APITypes.DeleteDscRecordsMutation
>;
export const deleteInwardPosts = /* GraphQL */ `mutation DeleteInwardPosts(
  $condition: ModelInwardPostsConditionInput
  $input: DeleteInwardPostsInput!
) {
  deleteInwardPosts(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    received_by
    received_date
    recipient_name
    sender_name
    status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteInwardPostsMutationVariables,
  APITypes.DeleteInwardPostsMutation
>;
export const deleteLicenseBilling = /* GraphQL */ `mutation DeleteLicenseBilling(
  $condition: ModelLicenseBillingConditionInput
  $input: DeleteLicenseBillingInput!
) {
  deleteLicenseBilling(condition: $condition, input: $input) {
    amount
    client_license_id
    createdAt
    created_at
    id
    invoice_no
    payment_date
    payment_status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteLicenseBillingMutationVariables,
  APITypes.DeleteLicenseBillingMutation
>;
export const deleteLicenseNotifications = /* GraphQL */ `mutation DeleteLicenseNotifications(
  $condition: ModelLicenseNotificationsConditionInput
  $input: DeleteLicenseNotificationsInput!
) {
  deleteLicenseNotifications(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    is_sent
    message
    notification_type
    scheduled_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteLicenseNotificationsMutationVariables,
  APITypes.DeleteLicenseNotificationsMutation
>;
export const deleteLicenseServices = /* GraphQL */ `mutation DeleteLicenseServices(
  $condition: ModelLicenseServicesConditionInput
  $input: DeleteLicenseServicesInput!
) {
  deleteLicenseServices(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    service_cost
    service_date
    service_description
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteLicenseServicesMutationVariables,
  APITypes.DeleteLicenseServicesMutation
>;
export const deleteLicenseTypes = /* GraphQL */ `mutation DeleteLicenseTypes(
  $condition: ModelLicenseTypesConditionInput
  $input: DeleteLicenseTypesInput!
) {
  deleteLicenseTypes(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    name
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteLicenseTypesMutationVariables,
  APITypes.DeleteLicenseTypesMutation
>;
export const deleteLocationHistory = /* GraphQL */ `mutation DeleteLocationHistory(
  $condition: ModelLocationHistoryConditionInput
  $input: DeleteLocationHistoryInput!
) {
  deleteLocationHistory(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    recorded_at
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteLocationHistoryMutationVariables,
  APITypes.DeleteLocationHistoryMutation
>;
export const deleteMessages = /* GraphQL */ `mutation DeleteMessages(
  $condition: ModelMessagesConditionInput
  $input: DeleteMessagesInput!
) {
  deleteMessages(condition: $condition, input: $input) {
    attachment_id
    attachment_type
    content
    createdAt
    created_at
    id
    is_read
    receiver_id
    sender_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteMessagesMutationVariables,
  APITypes.DeleteMessagesMutation
>;
export const deleteNotifications = /* GraphQL */ `mutation DeleteNotifications(
  $condition: ModelNotificationsConditionInput
  $input: DeleteNotificationsInput!
) {
  deleteNotifications(condition: $condition, input: $input) {
    createdAt
    created_at
    deal_id
    id
    is_read
    message
    task_id
    title
    type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteNotificationsMutationVariables,
  APITypes.DeleteNotificationsMutation
>;
export const deleteServiceContent = /* GraphQL */ `mutation DeleteServiceContent(
  $condition: ModelServiceContentConditionInput
  $input: DeleteServiceContentInput!
) {
  deleteServiceContent(condition: $condition, input: $input) {
    createdAt
    description
    details
    id
    image_path
    service_id
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteServiceContentMutationVariables,
  APITypes.DeleteServiceContentMutation
>;
export const deleteServiceNames = /* GraphQL */ `mutation DeleteServiceNames(
  $condition: ModelServiceNamesConditionInput
  $input: DeleteServiceNamesInput!
) {
  deleteServiceNames(condition: $condition, input: $input) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteServiceNamesMutationVariables,
  APITypes.DeleteServiceNamesMutation
>;
export const deleteStaffAttendance = /* GraphQL */ `mutation DeleteStaffAttendance(
  $condition: ModelStaffAttendanceConditionInput
  $input: DeleteStaffAttendanceInput!
) {
  deleteStaffAttendance(condition: $condition, input: $input) {
    attendance_date
    check_in_time
    check_out_time
    createdAt
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteStaffAttendanceMutationVariables,
  APITypes.DeleteStaffAttendanceMutation
>;
export const deleteStaffLocations = /* GraphQL */ `mutation DeleteStaffLocations(
  $condition: ModelStaffLocationsConditionInput
  $input: DeleteStaffLocationsInput!
) {
  deleteStaffLocations(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    updatedAt
    updated_at
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteStaffLocationsMutationVariables,
  APITypes.DeleteStaffLocationsMutation
>;
export const deleteSysCronLogs = /* GraphQL */ `mutation DeleteSysCronLogs(
  $condition: ModelSysCronLogsConditionInput
  $input: DeleteSysCronLogsInput!
) {
  deleteSysCronLogs(condition: $condition, input: $input) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteSysCronLogsMutationVariables,
  APITypes.DeleteSysCronLogsMutation
>;
export const deleteTasks = /* GraphQL */ `mutation DeleteTasks(
  $condition: ModelTasksConditionInput
  $input: DeleteTasksInput!
) {
  deleteTasks(condition: $condition, input: $input) {
    assigned_by
    assigned_to
    client_name
    createdAt
    created_at
    description
    due_date
    id
    location
    phone_number
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteTasksMutationVariables,
  APITypes.DeleteTasksMutation
>;
export const deleteTravelLogs = /* GraphQL */ `mutation DeleteTravelLogs(
  $condition: ModelTravelLogsConditionInput
  $input: DeleteTravelLogsInput!
) {
  deleteTravelLogs(condition: $condition, input: $input) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteTravelLogsMutationVariables,
  APITypes.DeleteTravelLogsMutation
>;
export const deleteUserSessions = /* GraphQL */ `mutation DeleteUserSessions(
  $condition: ModelUserSessionsConditionInput
  $input: DeleteUserSessionsInput!
) {
  deleteUserSessions(condition: $condition, input: $input) {
    active_seconds
    createdAt
    id
    idle_seconds
    ip_address
    is_active
    login_time
    logout_time
    status
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteUserSessionsMutationVariables,
  APITypes.DeleteUserSessionsMutation
>;
export const deleteUsers = /* GraphQL */ `mutation DeleteUsers(
  $condition: ModelUsersConditionInput
  $input: DeleteUsersInput!
) {
  deleteUsers(condition: $condition, input: $input) {
    createdAt
    created_at
    email
    id
    last_seen
    name
    password
    role
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteUsersMutationVariables,
  APITypes.DeleteUsersMutation
>;
export const updateActivityLogs = /* GraphQL */ `mutation UpdateActivityLogs(
  $condition: ModelActivityLogsConditionInput
  $input: UpdateActivityLogsInput!
) {
  updateActivityLogs(condition: $condition, input: $input) {
    action
    createdAt
    created_at
    details
    id
    target_id
    target_type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateActivityLogsMutationVariables,
  APITypes.UpdateActivityLogsMutation
>;
export const updateBillings = /* GraphQL */ `mutation UpdateBillings(
  $condition: ModelBillingsConditionInput
  $input: UpdateBillingsInput!
) {
  updateBillings(condition: $condition, input: $input) {
    amount
    authorities
    category
    client_name
    createdAt
    created_at
    data
    date
    id
    invoice_no
    status
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateBillingsMutationVariables,
  APITypes.UpdateBillingsMutation
>;
export const updateChecklists = /* GraphQL */ `mutation UpdateChecklists(
  $condition: ModelChecklistsConditionInput
  $input: UpdateChecklistsInput!
) {
  updateChecklists(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    due_date
    id
    manager_id
    reason
    remarks
    responsible_id
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateChecklistsMutationVariables,
  APITypes.UpdateChecklistsMutation
>;
export const updateClientDocuments = /* GraphQL */ `mutation UpdateClientDocuments(
  $condition: ModelClientDocumentsConditionInput
  $input: UpdateClientDocumentsInput!
) {
  updateClientDocuments(condition: $condition, input: $input) {
    client_id
    client_name
    createdAt
    created_at
    document_name
    id
    og_copy
    remarks
    storage_path
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateClientDocumentsMutationVariables,
  APITypes.UpdateClientDocumentsMutation
>;
export const updateClientLicenses = /* GraphQL */ `mutation UpdateClientLicenses(
  $condition: ModelClientLicensesConditionInput
  $input: UpdateClientLicensesInput!
) {
  updateClientLicenses(condition: $condition, input: $input) {
    client_id
    createdAt
    created_at
    expiry_date
    file_no
    id
    license_type_id
    manual_client_name
    notes
    service_date
    status
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateClientLicensesMutationVariables,
  APITypes.UpdateClientLicensesMutation
>;
export const updateClients = /* GraphQL */ `mutation UpdateClients(
  $condition: ModelClientsConditionInput
  $input: UpdateClientsInput!
) {
  updateClients(condition: $condition, input: $input) {
    address
    balance_due
    case_number
    createdAt
    created_at
    dob
    email
    file_date
    file_no
    id
    is_contacted
    managed_by
    name
    phone
    review_rating
    type_of_work
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateClientsMutationVariables,
  APITypes.UpdateClientsMutation
>;
export const updateCompanyBills = /* GraphQL */ `mutation UpdateCompanyBills(
  $condition: ModelCompanyBillsConditionInput
  $input: UpdateCompanyBillsInput!
) {
  updateCompanyBills(condition: $condition, input: $input) {
    amount
    bill_date
    category
    createdAt
    created_at
    description
    id
    spent_by
    spent_by_name
    status
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateCompanyBillsMutationVariables,
  APITypes.UpdateCompanyBillsMutation
>;
export const updateDealActivities = /* GraphQL */ `mutation UpdateDealActivities(
  $condition: ModelDealActivitiesConditionInput
  $input: UpdateDealActivitiesInput!
) {
  updateDealActivities(condition: $condition, input: $input) {
    createdAt
    created_at
    created_by
    deal_id
    description
    due_date
    id
    is_completed
    title
    type
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDealActivitiesMutationVariables,
  APITypes.UpdateDealActivitiesMutation
>;
export const updateDealAssignees = /* GraphQL */ `mutation UpdateDealAssignees(
  $condition: ModelDealAssigneesConditionInput
  $input: UpdateDealAssigneesInput!
) {
  updateDealAssignees(condition: $condition, input: $input) {
    assigned_at
    createdAt
    deal_id
    id
    role
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDealAssigneesMutationVariables,
  APITypes.UpdateDealAssigneesMutation
>;
export const updateDealHandoverHistory = /* GraphQL */ `mutation UpdateDealHandoverHistory(
  $condition: ModelDealHandoverHistoryConditionInput
  $input: UpdateDealHandoverHistoryInput!
) {
  updateDealHandoverHistory(condition: $condition, input: $input) {
    createdAt
    deal_id
    from_user_id
    handed_over_at
    id
    note
    to_user_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDealHandoverHistoryMutationVariables,
  APITypes.UpdateDealHandoverHistoryMutation
>;
export const updateDealStageHistory = /* GraphQL */ `mutation UpdateDealStageHistory(
  $condition: ModelDealStageHistoryConditionInput
  $input: UpdateDealStageHistoryInput!
) {
  updateDealStageHistory(condition: $condition, input: $input) {
    changed_at
    changed_by
    createdAt
    deal_id
    from_stage
    id
    to_stage
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDealStageHistoryMutationVariables,
  APITypes.UpdateDealStageHistoryMutation
>;
export const updateDeals = /* GraphQL */ `mutation UpdateDeals(
  $condition: ModelDealsConditionInput
  $input: UpdateDealsInput!
) {
  updateDeals(condition: $condition, input: $input) {
    amount
    billing_id
    client_id
    client_name
    closed_at
    company
    contact_info
    contact_status
    create_invoice_share
    createdAt
    created_at
    currency
    description
    drive_link
    est_amount_work
    expense_spent
    expenses_list
    files_asked
    files_received
    id
    invoice_amount
    is_won
    name
    noc_obtained
    part_payment_amount
    payment_received
    payment_type
    pipeline
    priority
    quotation_id
    referred_by
    reg_fee_required
    register_no
    responsible_id
    responsible_name
    send_to_customer
    stage
    updatedAt
    updated_at
    upload_invoice_path
    work_type
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDealsMutationVariables,
  APITypes.UpdateDealsMutation
>;
export const updateDscRecords = /* GraphQL */ `mutation UpdateDscRecords(
  $condition: ModelDscRecordsConditionInput
  $input: UpdateDscRecordsInput!
) {
  updateDscRecords(condition: $condition, input: $input) {
    client_name
    createdAt
    created_at
    dsc_expiry_date
    dsc_taken_date
    email_id
    id
    password
    phone_no
    updatedAt
    updated_at
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateDscRecordsMutationVariables,
  APITypes.UpdateDscRecordsMutation
>;
export const updateInwardPosts = /* GraphQL */ `mutation UpdateInwardPosts(
  $condition: ModelInwardPostsConditionInput
  $input: UpdateInwardPostsInput!
) {
  updateInwardPosts(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    received_by
    received_date
    recipient_name
    sender_name
    status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateInwardPostsMutationVariables,
  APITypes.UpdateInwardPostsMutation
>;
export const updateLicenseBilling = /* GraphQL */ `mutation UpdateLicenseBilling(
  $condition: ModelLicenseBillingConditionInput
  $input: UpdateLicenseBillingInput!
) {
  updateLicenseBilling(condition: $condition, input: $input) {
    amount
    client_license_id
    createdAt
    created_at
    id
    invoice_no
    payment_date
    payment_status
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateLicenseBillingMutationVariables,
  APITypes.UpdateLicenseBillingMutation
>;
export const updateLicenseNotifications = /* GraphQL */ `mutation UpdateLicenseNotifications(
  $condition: ModelLicenseNotificationsConditionInput
  $input: UpdateLicenseNotificationsInput!
) {
  updateLicenseNotifications(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    is_sent
    message
    notification_type
    scheduled_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateLicenseNotificationsMutationVariables,
  APITypes.UpdateLicenseNotificationsMutation
>;
export const updateLicenseServices = /* GraphQL */ `mutation UpdateLicenseServices(
  $condition: ModelLicenseServicesConditionInput
  $input: UpdateLicenseServicesInput!
) {
  updateLicenseServices(condition: $condition, input: $input) {
    client_license_id
    createdAt
    created_at
    id
    service_cost
    service_date
    service_description
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateLicenseServicesMutationVariables,
  APITypes.UpdateLicenseServicesMutation
>;
export const updateLicenseTypes = /* GraphQL */ `mutation UpdateLicenseTypes(
  $condition: ModelLicenseTypesConditionInput
  $input: UpdateLicenseTypesInput!
) {
  updateLicenseTypes(condition: $condition, input: $input) {
    createdAt
    created_at
    description
    id
    name
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateLicenseTypesMutationVariables,
  APITypes.UpdateLicenseTypesMutation
>;
export const updateLocationHistory = /* GraphQL */ `mutation UpdateLocationHistory(
  $condition: ModelLocationHistoryConditionInput
  $input: UpdateLocationHistoryInput!
) {
  updateLocationHistory(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    recorded_at
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateLocationHistoryMutationVariables,
  APITypes.UpdateLocationHistoryMutation
>;
export const updateMessages = /* GraphQL */ `mutation UpdateMessages(
  $condition: ModelMessagesConditionInput
  $input: UpdateMessagesInput!
) {
  updateMessages(condition: $condition, input: $input) {
    attachment_id
    attachment_type
    content
    createdAt
    created_at
    id
    is_read
    receiver_id
    sender_id
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateMessagesMutationVariables,
  APITypes.UpdateMessagesMutation
>;
export const updateNotifications = /* GraphQL */ `mutation UpdateNotifications(
  $condition: ModelNotificationsConditionInput
  $input: UpdateNotificationsInput!
) {
  updateNotifications(condition: $condition, input: $input) {
    createdAt
    created_at
    deal_id
    id
    is_read
    message
    task_id
    title
    type
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateNotificationsMutationVariables,
  APITypes.UpdateNotificationsMutation
>;
export const updateServiceContent = /* GraphQL */ `mutation UpdateServiceContent(
  $condition: ModelServiceContentConditionInput
  $input: UpdateServiceContentInput!
) {
  updateServiceContent(condition: $condition, input: $input) {
    createdAt
    description
    details
    id
    image_path
    service_id
    title
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateServiceContentMutationVariables,
  APITypes.UpdateServiceContentMutation
>;
export const updateServiceNames = /* GraphQL */ `mutation UpdateServiceNames(
  $condition: ModelServiceNamesConditionInput
  $input: UpdateServiceNamesInput!
) {
  updateServiceNames(condition: $condition, input: $input) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateServiceNamesMutationVariables,
  APITypes.UpdateServiceNamesMutation
>;
export const updateStaffAttendance = /* GraphQL */ `mutation UpdateStaffAttendance(
  $condition: ModelStaffAttendanceConditionInput
  $input: UpdateStaffAttendanceInput!
) {
  updateStaffAttendance(condition: $condition, input: $input) {
    attendance_date
    check_in_time
    check_out_time
    createdAt
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateStaffAttendanceMutationVariables,
  APITypes.UpdateStaffAttendanceMutation
>;
export const updateStaffLocations = /* GraphQL */ `mutation UpdateStaffLocations(
  $condition: ModelStaffLocationsConditionInput
  $input: UpdateStaffLocationsInput!
) {
  updateStaffLocations(condition: $condition, input: $input) {
    createdAt
    id
    latitude
    longitude
    updatedAt
    updated_at
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateStaffLocationsMutationVariables,
  APITypes.UpdateStaffLocationsMutation
>;
export const updateSysCronLogs = /* GraphQL */ `mutation UpdateSysCronLogs(
  $condition: ModelSysCronLogsConditionInput
  $input: UpdateSysCronLogsInput!
) {
  updateSysCronLogs(condition: $condition, input: $input) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateSysCronLogsMutationVariables,
  APITypes.UpdateSysCronLogsMutation
>;
export const updateTasks = /* GraphQL */ `mutation UpdateTasks(
  $condition: ModelTasksConditionInput
  $input: UpdateTasksInput!
) {
  updateTasks(condition: $condition, input: $input) {
    assigned_by
    assigned_to
    client_name
    createdAt
    created_at
    description
    due_date
    id
    location
    phone_number
    status
    title
    updatedAt
    updated_at
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateTasksMutationVariables,
  APITypes.UpdateTasksMutation
>;
export const updateTravelLogs = /* GraphQL */ `mutation UpdateTravelLogs(
  $condition: ModelTravelLogsConditionInput
  $input: UpdateTravelLogsInput!
) {
  updateTravelLogs(condition: $condition, input: $input) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateTravelLogsMutationVariables,
  APITypes.UpdateTravelLogsMutation
>;
export const updateUserSessions = /* GraphQL */ `mutation UpdateUserSessions(
  $condition: ModelUserSessionsConditionInput
  $input: UpdateUserSessionsInput!
) {
  updateUserSessions(condition: $condition, input: $input) {
    active_seconds
    createdAt
    id
    idle_seconds
    ip_address
    is_active
    login_time
    logout_time
    status
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateUserSessionsMutationVariables,
  APITypes.UpdateUserSessionsMutation
>;
export const updateUsers = /* GraphQL */ `mutation UpdateUsers(
  $condition: ModelUsersConditionInput
  $input: UpdateUsersInput!
) {
  updateUsers(condition: $condition, input: $input) {
    createdAt
    created_at
    email
    id
    last_seen
    name
    password
    role
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateUsersMutationVariables,
  APITypes.UpdateUsersMutation
>;
