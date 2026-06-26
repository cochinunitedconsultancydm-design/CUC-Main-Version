/* tslint:disable */
/* eslint-disable */
// this is an auto generated file. This will be overwritten

import * as APITypes from "./API";
type GeneratedSubscription<InputType, OutputType> = string & {
  __generatedSubscriptionInput: InputType;
  __generatedSubscriptionOutput: OutputType;
};

export const onCreateActivityLogs = /* GraphQL */ `subscription OnCreateActivityLogs(
  $filter: ModelSubscriptionActivityLogsFilterInput
) {
  onCreateActivityLogs(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateActivityLogsSubscriptionVariables,
  APITypes.OnCreateActivityLogsSubscription
>;
export const onCreateBillings = /* GraphQL */ `subscription OnCreateBillings($filter: ModelSubscriptionBillingsFilterInput) {
  onCreateBillings(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateBillingsSubscriptionVariables,
  APITypes.OnCreateBillingsSubscription
>;
export const onCreateChecklists = /* GraphQL */ `subscription OnCreateChecklists(
  $filter: ModelSubscriptionChecklistsFilterInput
) {
  onCreateChecklists(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateChecklistsSubscriptionVariables,
  APITypes.OnCreateChecklistsSubscription
>;
export const onCreateClientDocuments = /* GraphQL */ `subscription OnCreateClientDocuments(
  $filter: ModelSubscriptionClientDocumentsFilterInput
) {
  onCreateClientDocuments(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateClientDocumentsSubscriptionVariables,
  APITypes.OnCreateClientDocumentsSubscription
>;
export const onCreateClientLicenses = /* GraphQL */ `subscription OnCreateClientLicenses(
  $filter: ModelSubscriptionClientLicensesFilterInput
) {
  onCreateClientLicenses(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateClientLicensesSubscriptionVariables,
  APITypes.OnCreateClientLicensesSubscription
>;
export const onCreateClients = /* GraphQL */ `subscription OnCreateClients($filter: ModelSubscriptionClientsFilterInput) {
  onCreateClients(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateClientsSubscriptionVariables,
  APITypes.OnCreateClientsSubscription
>;
export const onCreateCompanyBills = /* GraphQL */ `subscription OnCreateCompanyBills(
  $filter: ModelSubscriptionCompanyBillsFilterInput
) {
  onCreateCompanyBills(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateCompanyBillsSubscriptionVariables,
  APITypes.OnCreateCompanyBillsSubscription
>;
export const onCreateDealActivities = /* GraphQL */ `subscription OnCreateDealActivities(
  $filter: ModelSubscriptionDealActivitiesFilterInput
) {
  onCreateDealActivities(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDealActivitiesSubscriptionVariables,
  APITypes.OnCreateDealActivitiesSubscription
>;
export const onCreateDealAssignees = /* GraphQL */ `subscription OnCreateDealAssignees(
  $filter: ModelSubscriptionDealAssigneesFilterInput
) {
  onCreateDealAssignees(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDealAssigneesSubscriptionVariables,
  APITypes.OnCreateDealAssigneesSubscription
>;
export const onCreateDealHandoverHistory = /* GraphQL */ `subscription OnCreateDealHandoverHistory(
  $filter: ModelSubscriptionDealHandoverHistoryFilterInput
) {
  onCreateDealHandoverHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDealHandoverHistorySubscriptionVariables,
  APITypes.OnCreateDealHandoverHistorySubscription
>;
export const onCreateDealStageHistory = /* GraphQL */ `subscription OnCreateDealStageHistory(
  $filter: ModelSubscriptionDealStageHistoryFilterInput
) {
  onCreateDealStageHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDealStageHistorySubscriptionVariables,
  APITypes.OnCreateDealStageHistorySubscription
>;
export const onCreateDeals = /* GraphQL */ `subscription OnCreateDeals($filter: ModelSubscriptionDealsFilterInput) {
  onCreateDeals(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDealsSubscriptionVariables,
  APITypes.OnCreateDealsSubscription
>;
export const onCreateDscRecords = /* GraphQL */ `subscription OnCreateDscRecords(
  $filter: ModelSubscriptionDscRecordsFilterInput
) {
  onCreateDscRecords(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateDscRecordsSubscriptionVariables,
  APITypes.OnCreateDscRecordsSubscription
>;
export const onCreateInwardPosts = /* GraphQL */ `subscription OnCreateInwardPosts(
  $filter: ModelSubscriptionInwardPostsFilterInput
) {
  onCreateInwardPosts(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateInwardPostsSubscriptionVariables,
  APITypes.OnCreateInwardPostsSubscription
>;
export const onCreateLicenseBilling = /* GraphQL */ `subscription OnCreateLicenseBilling(
  $filter: ModelSubscriptionLicenseBillingFilterInput
) {
  onCreateLicenseBilling(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateLicenseBillingSubscriptionVariables,
  APITypes.OnCreateLicenseBillingSubscription
>;
export const onCreateLicenseNotifications = /* GraphQL */ `subscription OnCreateLicenseNotifications(
  $filter: ModelSubscriptionLicenseNotificationsFilterInput
) {
  onCreateLicenseNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateLicenseNotificationsSubscriptionVariables,
  APITypes.OnCreateLicenseNotificationsSubscription
>;
export const onCreateLicenseServices = /* GraphQL */ `subscription OnCreateLicenseServices(
  $filter: ModelSubscriptionLicenseServicesFilterInput
) {
  onCreateLicenseServices(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateLicenseServicesSubscriptionVariables,
  APITypes.OnCreateLicenseServicesSubscription
>;
export const onCreateLicenseTypes = /* GraphQL */ `subscription OnCreateLicenseTypes(
  $filter: ModelSubscriptionLicenseTypesFilterInput
) {
  onCreateLicenseTypes(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateLicenseTypesSubscriptionVariables,
  APITypes.OnCreateLicenseTypesSubscription
>;
export const onCreateLocationHistory = /* GraphQL */ `subscription OnCreateLocationHistory(
  $filter: ModelSubscriptionLocationHistoryFilterInput
) {
  onCreateLocationHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateLocationHistorySubscriptionVariables,
  APITypes.OnCreateLocationHistorySubscription
>;
export const onCreateMessages = /* GraphQL */ `subscription OnCreateMessages($filter: ModelSubscriptionMessagesFilterInput) {
  onCreateMessages(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateMessagesSubscriptionVariables,
  APITypes.OnCreateMessagesSubscription
>;
export const onCreateNotifications = /* GraphQL */ `subscription OnCreateNotifications(
  $filter: ModelSubscriptionNotificationsFilterInput
) {
  onCreateNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateNotificationsSubscriptionVariables,
  APITypes.OnCreateNotificationsSubscription
>;
export const onCreateServiceContent = /* GraphQL */ `subscription OnCreateServiceContent(
  $filter: ModelSubscriptionServiceContentFilterInput
) {
  onCreateServiceContent(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateServiceContentSubscriptionVariables,
  APITypes.OnCreateServiceContentSubscription
>;
export const onCreateServiceNames = /* GraphQL */ `subscription OnCreateServiceNames(
  $filter: ModelSubscriptionServiceNamesFilterInput
) {
  onCreateServiceNames(filter: $filter) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnCreateServiceNamesSubscriptionVariables,
  APITypes.OnCreateServiceNamesSubscription
>;
export const onCreateStaffAttendance = /* GraphQL */ `subscription OnCreateStaffAttendance(
  $filter: ModelSubscriptionStaffAttendanceFilterInput
) {
  onCreateStaffAttendance(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateStaffAttendanceSubscriptionVariables,
  APITypes.OnCreateStaffAttendanceSubscription
>;
export const onCreateStaffLocations = /* GraphQL */ `subscription OnCreateStaffLocations(
  $filter: ModelSubscriptionStaffLocationsFilterInput
) {
  onCreateStaffLocations(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateStaffLocationsSubscriptionVariables,
  APITypes.OnCreateStaffLocationsSubscription
>;
export const onCreateSysCronLogs = /* GraphQL */ `subscription OnCreateSysCronLogs(
  $filter: ModelSubscriptionSysCronLogsFilterInput
) {
  onCreateSysCronLogs(filter: $filter) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnCreateSysCronLogsSubscriptionVariables,
  APITypes.OnCreateSysCronLogsSubscription
>;
export const onCreateTasks = /* GraphQL */ `subscription OnCreateTasks($filter: ModelSubscriptionTasksFilterInput) {
  onCreateTasks(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateTasksSubscriptionVariables,
  APITypes.OnCreateTasksSubscription
>;
export const onCreateTravelLogs = /* GraphQL */ `subscription OnCreateTravelLogs(
  $filter: ModelSubscriptionTravelLogsFilterInput
) {
  onCreateTravelLogs(filter: $filter) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnCreateTravelLogsSubscriptionVariables,
  APITypes.OnCreateTravelLogsSubscription
>;
export const onCreateUserSessions = /* GraphQL */ `subscription OnCreateUserSessions(
  $filter: ModelSubscriptionUserSessionsFilterInput
) {
  onCreateUserSessions(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateUserSessionsSubscriptionVariables,
  APITypes.OnCreateUserSessionsSubscription
>;
export const onCreateUsers = /* GraphQL */ `subscription OnCreateUsers($filter: ModelSubscriptionUsersFilterInput) {
  onCreateUsers(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnCreateUsersSubscriptionVariables,
  APITypes.OnCreateUsersSubscription
>;
export const onDeleteActivityLogs = /* GraphQL */ `subscription OnDeleteActivityLogs(
  $filter: ModelSubscriptionActivityLogsFilterInput
) {
  onDeleteActivityLogs(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteActivityLogsSubscriptionVariables,
  APITypes.OnDeleteActivityLogsSubscription
>;
export const onDeleteBillings = /* GraphQL */ `subscription OnDeleteBillings($filter: ModelSubscriptionBillingsFilterInput) {
  onDeleteBillings(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteBillingsSubscriptionVariables,
  APITypes.OnDeleteBillingsSubscription
>;
export const onDeleteChecklists = /* GraphQL */ `subscription OnDeleteChecklists(
  $filter: ModelSubscriptionChecklistsFilterInput
) {
  onDeleteChecklists(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteChecklistsSubscriptionVariables,
  APITypes.OnDeleteChecklistsSubscription
>;
export const onDeleteClientDocuments = /* GraphQL */ `subscription OnDeleteClientDocuments(
  $filter: ModelSubscriptionClientDocumentsFilterInput
) {
  onDeleteClientDocuments(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteClientDocumentsSubscriptionVariables,
  APITypes.OnDeleteClientDocumentsSubscription
>;
export const onDeleteClientLicenses = /* GraphQL */ `subscription OnDeleteClientLicenses(
  $filter: ModelSubscriptionClientLicensesFilterInput
) {
  onDeleteClientLicenses(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteClientLicensesSubscriptionVariables,
  APITypes.OnDeleteClientLicensesSubscription
>;
export const onDeleteClients = /* GraphQL */ `subscription OnDeleteClients($filter: ModelSubscriptionClientsFilterInput) {
  onDeleteClients(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteClientsSubscriptionVariables,
  APITypes.OnDeleteClientsSubscription
>;
export const onDeleteCompanyBills = /* GraphQL */ `subscription OnDeleteCompanyBills(
  $filter: ModelSubscriptionCompanyBillsFilterInput
) {
  onDeleteCompanyBills(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteCompanyBillsSubscriptionVariables,
  APITypes.OnDeleteCompanyBillsSubscription
>;
export const onDeleteDealActivities = /* GraphQL */ `subscription OnDeleteDealActivities(
  $filter: ModelSubscriptionDealActivitiesFilterInput
) {
  onDeleteDealActivities(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDealActivitiesSubscriptionVariables,
  APITypes.OnDeleteDealActivitiesSubscription
>;
export const onDeleteDealAssignees = /* GraphQL */ `subscription OnDeleteDealAssignees(
  $filter: ModelSubscriptionDealAssigneesFilterInput
) {
  onDeleteDealAssignees(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDealAssigneesSubscriptionVariables,
  APITypes.OnDeleteDealAssigneesSubscription
>;
export const onDeleteDealHandoverHistory = /* GraphQL */ `subscription OnDeleteDealHandoverHistory(
  $filter: ModelSubscriptionDealHandoverHistoryFilterInput
) {
  onDeleteDealHandoverHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDealHandoverHistorySubscriptionVariables,
  APITypes.OnDeleteDealHandoverHistorySubscription
>;
export const onDeleteDealStageHistory = /* GraphQL */ `subscription OnDeleteDealStageHistory(
  $filter: ModelSubscriptionDealStageHistoryFilterInput
) {
  onDeleteDealStageHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDealStageHistorySubscriptionVariables,
  APITypes.OnDeleteDealStageHistorySubscription
>;
export const onDeleteDeals = /* GraphQL */ `subscription OnDeleteDeals($filter: ModelSubscriptionDealsFilterInput) {
  onDeleteDeals(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDealsSubscriptionVariables,
  APITypes.OnDeleteDealsSubscription
>;
export const onDeleteDscRecords = /* GraphQL */ `subscription OnDeleteDscRecords(
  $filter: ModelSubscriptionDscRecordsFilterInput
) {
  onDeleteDscRecords(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteDscRecordsSubscriptionVariables,
  APITypes.OnDeleteDscRecordsSubscription
>;
export const onDeleteInwardPosts = /* GraphQL */ `subscription OnDeleteInwardPosts(
  $filter: ModelSubscriptionInwardPostsFilterInput
) {
  onDeleteInwardPosts(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteInwardPostsSubscriptionVariables,
  APITypes.OnDeleteInwardPostsSubscription
>;
export const onDeleteLicenseBilling = /* GraphQL */ `subscription OnDeleteLicenseBilling(
  $filter: ModelSubscriptionLicenseBillingFilterInput
) {
  onDeleteLicenseBilling(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteLicenseBillingSubscriptionVariables,
  APITypes.OnDeleteLicenseBillingSubscription
>;
export const onDeleteLicenseNotifications = /* GraphQL */ `subscription OnDeleteLicenseNotifications(
  $filter: ModelSubscriptionLicenseNotificationsFilterInput
) {
  onDeleteLicenseNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteLicenseNotificationsSubscriptionVariables,
  APITypes.OnDeleteLicenseNotificationsSubscription
>;
export const onDeleteLicenseServices = /* GraphQL */ `subscription OnDeleteLicenseServices(
  $filter: ModelSubscriptionLicenseServicesFilterInput
) {
  onDeleteLicenseServices(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteLicenseServicesSubscriptionVariables,
  APITypes.OnDeleteLicenseServicesSubscription
>;
export const onDeleteLicenseTypes = /* GraphQL */ `subscription OnDeleteLicenseTypes(
  $filter: ModelSubscriptionLicenseTypesFilterInput
) {
  onDeleteLicenseTypes(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteLicenseTypesSubscriptionVariables,
  APITypes.OnDeleteLicenseTypesSubscription
>;
export const onDeleteLocationHistory = /* GraphQL */ `subscription OnDeleteLocationHistory(
  $filter: ModelSubscriptionLocationHistoryFilterInput
) {
  onDeleteLocationHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteLocationHistorySubscriptionVariables,
  APITypes.OnDeleteLocationHistorySubscription
>;
export const onDeleteMessages = /* GraphQL */ `subscription OnDeleteMessages($filter: ModelSubscriptionMessagesFilterInput) {
  onDeleteMessages(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteMessagesSubscriptionVariables,
  APITypes.OnDeleteMessagesSubscription
>;
export const onDeleteNotifications = /* GraphQL */ `subscription OnDeleteNotifications(
  $filter: ModelSubscriptionNotificationsFilterInput
) {
  onDeleteNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteNotificationsSubscriptionVariables,
  APITypes.OnDeleteNotificationsSubscription
>;
export const onDeleteServiceContent = /* GraphQL */ `subscription OnDeleteServiceContent(
  $filter: ModelSubscriptionServiceContentFilterInput
) {
  onDeleteServiceContent(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteServiceContentSubscriptionVariables,
  APITypes.OnDeleteServiceContentSubscription
>;
export const onDeleteServiceNames = /* GraphQL */ `subscription OnDeleteServiceNames(
  $filter: ModelSubscriptionServiceNamesFilterInput
) {
  onDeleteServiceNames(filter: $filter) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnDeleteServiceNamesSubscriptionVariables,
  APITypes.OnDeleteServiceNamesSubscription
>;
export const onDeleteStaffAttendance = /* GraphQL */ `subscription OnDeleteStaffAttendance(
  $filter: ModelSubscriptionStaffAttendanceFilterInput
) {
  onDeleteStaffAttendance(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteStaffAttendanceSubscriptionVariables,
  APITypes.OnDeleteStaffAttendanceSubscription
>;
export const onDeleteStaffLocations = /* GraphQL */ `subscription OnDeleteStaffLocations(
  $filter: ModelSubscriptionStaffLocationsFilterInput
) {
  onDeleteStaffLocations(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteStaffLocationsSubscriptionVariables,
  APITypes.OnDeleteStaffLocationsSubscription
>;
export const onDeleteSysCronLogs = /* GraphQL */ `subscription OnDeleteSysCronLogs(
  $filter: ModelSubscriptionSysCronLogsFilterInput
) {
  onDeleteSysCronLogs(filter: $filter) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnDeleteSysCronLogsSubscriptionVariables,
  APITypes.OnDeleteSysCronLogsSubscription
>;
export const onDeleteTasks = /* GraphQL */ `subscription OnDeleteTasks($filter: ModelSubscriptionTasksFilterInput) {
  onDeleteTasks(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteTasksSubscriptionVariables,
  APITypes.OnDeleteTasksSubscription
>;
export const onDeleteTravelLogs = /* GraphQL */ `subscription OnDeleteTravelLogs(
  $filter: ModelSubscriptionTravelLogsFilterInput
) {
  onDeleteTravelLogs(filter: $filter) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnDeleteTravelLogsSubscriptionVariables,
  APITypes.OnDeleteTravelLogsSubscription
>;
export const onDeleteUserSessions = /* GraphQL */ `subscription OnDeleteUserSessions(
  $filter: ModelSubscriptionUserSessionsFilterInput
) {
  onDeleteUserSessions(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteUserSessionsSubscriptionVariables,
  APITypes.OnDeleteUserSessionsSubscription
>;
export const onDeleteUsers = /* GraphQL */ `subscription OnDeleteUsers($filter: ModelSubscriptionUsersFilterInput) {
  onDeleteUsers(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteUsersSubscriptionVariables,
  APITypes.OnDeleteUsersSubscription
>;
export const onUpdateActivityLogs = /* GraphQL */ `subscription OnUpdateActivityLogs(
  $filter: ModelSubscriptionActivityLogsFilterInput
) {
  onUpdateActivityLogs(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateActivityLogsSubscriptionVariables,
  APITypes.OnUpdateActivityLogsSubscription
>;
export const onUpdateBillings = /* GraphQL */ `subscription OnUpdateBillings($filter: ModelSubscriptionBillingsFilterInput) {
  onUpdateBillings(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateBillingsSubscriptionVariables,
  APITypes.OnUpdateBillingsSubscription
>;
export const onUpdateChecklists = /* GraphQL */ `subscription OnUpdateChecklists(
  $filter: ModelSubscriptionChecklistsFilterInput
) {
  onUpdateChecklists(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateChecklistsSubscriptionVariables,
  APITypes.OnUpdateChecklistsSubscription
>;
export const onUpdateClientDocuments = /* GraphQL */ `subscription OnUpdateClientDocuments(
  $filter: ModelSubscriptionClientDocumentsFilterInput
) {
  onUpdateClientDocuments(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateClientDocumentsSubscriptionVariables,
  APITypes.OnUpdateClientDocumentsSubscription
>;
export const onUpdateClientLicenses = /* GraphQL */ `subscription OnUpdateClientLicenses(
  $filter: ModelSubscriptionClientLicensesFilterInput
) {
  onUpdateClientLicenses(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateClientLicensesSubscriptionVariables,
  APITypes.OnUpdateClientLicensesSubscription
>;
export const onUpdateClients = /* GraphQL */ `subscription OnUpdateClients($filter: ModelSubscriptionClientsFilterInput) {
  onUpdateClients(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateClientsSubscriptionVariables,
  APITypes.OnUpdateClientsSubscription
>;
export const onUpdateCompanyBills = /* GraphQL */ `subscription OnUpdateCompanyBills(
  $filter: ModelSubscriptionCompanyBillsFilterInput
) {
  onUpdateCompanyBills(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateCompanyBillsSubscriptionVariables,
  APITypes.OnUpdateCompanyBillsSubscription
>;
export const onUpdateDealActivities = /* GraphQL */ `subscription OnUpdateDealActivities(
  $filter: ModelSubscriptionDealActivitiesFilterInput
) {
  onUpdateDealActivities(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDealActivitiesSubscriptionVariables,
  APITypes.OnUpdateDealActivitiesSubscription
>;
export const onUpdateDealAssignees = /* GraphQL */ `subscription OnUpdateDealAssignees(
  $filter: ModelSubscriptionDealAssigneesFilterInput
) {
  onUpdateDealAssignees(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDealAssigneesSubscriptionVariables,
  APITypes.OnUpdateDealAssigneesSubscription
>;
export const onUpdateDealHandoverHistory = /* GraphQL */ `subscription OnUpdateDealHandoverHistory(
  $filter: ModelSubscriptionDealHandoverHistoryFilterInput
) {
  onUpdateDealHandoverHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDealHandoverHistorySubscriptionVariables,
  APITypes.OnUpdateDealHandoverHistorySubscription
>;
export const onUpdateDealStageHistory = /* GraphQL */ `subscription OnUpdateDealStageHistory(
  $filter: ModelSubscriptionDealStageHistoryFilterInput
) {
  onUpdateDealStageHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDealStageHistorySubscriptionVariables,
  APITypes.OnUpdateDealStageHistorySubscription
>;
export const onUpdateDeals = /* GraphQL */ `subscription OnUpdateDeals($filter: ModelSubscriptionDealsFilterInput) {
  onUpdateDeals(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDealsSubscriptionVariables,
  APITypes.OnUpdateDealsSubscription
>;
export const onUpdateDscRecords = /* GraphQL */ `subscription OnUpdateDscRecords(
  $filter: ModelSubscriptionDscRecordsFilterInput
) {
  onUpdateDscRecords(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateDscRecordsSubscriptionVariables,
  APITypes.OnUpdateDscRecordsSubscription
>;
export const onUpdateInwardPosts = /* GraphQL */ `subscription OnUpdateInwardPosts(
  $filter: ModelSubscriptionInwardPostsFilterInput
) {
  onUpdateInwardPosts(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateInwardPostsSubscriptionVariables,
  APITypes.OnUpdateInwardPostsSubscription
>;
export const onUpdateLicenseBilling = /* GraphQL */ `subscription OnUpdateLicenseBilling(
  $filter: ModelSubscriptionLicenseBillingFilterInput
) {
  onUpdateLicenseBilling(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateLicenseBillingSubscriptionVariables,
  APITypes.OnUpdateLicenseBillingSubscription
>;
export const onUpdateLicenseNotifications = /* GraphQL */ `subscription OnUpdateLicenseNotifications(
  $filter: ModelSubscriptionLicenseNotificationsFilterInput
) {
  onUpdateLicenseNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateLicenseNotificationsSubscriptionVariables,
  APITypes.OnUpdateLicenseNotificationsSubscription
>;
export const onUpdateLicenseServices = /* GraphQL */ `subscription OnUpdateLicenseServices(
  $filter: ModelSubscriptionLicenseServicesFilterInput
) {
  onUpdateLicenseServices(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateLicenseServicesSubscriptionVariables,
  APITypes.OnUpdateLicenseServicesSubscription
>;
export const onUpdateLicenseTypes = /* GraphQL */ `subscription OnUpdateLicenseTypes(
  $filter: ModelSubscriptionLicenseTypesFilterInput
) {
  onUpdateLicenseTypes(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateLicenseTypesSubscriptionVariables,
  APITypes.OnUpdateLicenseTypesSubscription
>;
export const onUpdateLocationHistory = /* GraphQL */ `subscription OnUpdateLocationHistory(
  $filter: ModelSubscriptionLocationHistoryFilterInput
) {
  onUpdateLocationHistory(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateLocationHistorySubscriptionVariables,
  APITypes.OnUpdateLocationHistorySubscription
>;
export const onUpdateMessages = /* GraphQL */ `subscription OnUpdateMessages($filter: ModelSubscriptionMessagesFilterInput) {
  onUpdateMessages(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateMessagesSubscriptionVariables,
  APITypes.OnUpdateMessagesSubscription
>;
export const onUpdateNotifications = /* GraphQL */ `subscription OnUpdateNotifications(
  $filter: ModelSubscriptionNotificationsFilterInput
) {
  onUpdateNotifications(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateNotificationsSubscriptionVariables,
  APITypes.OnUpdateNotificationsSubscription
>;
export const onUpdateServiceContent = /* GraphQL */ `subscription OnUpdateServiceContent(
  $filter: ModelSubscriptionServiceContentFilterInput
) {
  onUpdateServiceContent(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateServiceContentSubscriptionVariables,
  APITypes.OnUpdateServiceContentSubscription
>;
export const onUpdateServiceNames = /* GraphQL */ `subscription OnUpdateServiceNames(
  $filter: ModelSubscriptionServiceNamesFilterInput
) {
  onUpdateServiceNames(filter: $filter) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnUpdateServiceNamesSubscriptionVariables,
  APITypes.OnUpdateServiceNamesSubscription
>;
export const onUpdateStaffAttendance = /* GraphQL */ `subscription OnUpdateStaffAttendance(
  $filter: ModelSubscriptionStaffAttendanceFilterInput
) {
  onUpdateStaffAttendance(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateStaffAttendanceSubscriptionVariables,
  APITypes.OnUpdateStaffAttendanceSubscription
>;
export const onUpdateStaffLocations = /* GraphQL */ `subscription OnUpdateStaffLocations(
  $filter: ModelSubscriptionStaffLocationsFilterInput
) {
  onUpdateStaffLocations(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateStaffLocationsSubscriptionVariables,
  APITypes.OnUpdateStaffLocationsSubscription
>;
export const onUpdateSysCronLogs = /* GraphQL */ `subscription OnUpdateSysCronLogs(
  $filter: ModelSubscriptionSysCronLogsFilterInput
) {
  onUpdateSysCronLogs(filter: $filter) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnUpdateSysCronLogsSubscriptionVariables,
  APITypes.OnUpdateSysCronLogsSubscription
>;
export const onUpdateTasks = /* GraphQL */ `subscription OnUpdateTasks($filter: ModelSubscriptionTasksFilterInput) {
  onUpdateTasks(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateTasksSubscriptionVariables,
  APITypes.OnUpdateTasksSubscription
>;
export const onUpdateTravelLogs = /* GraphQL */ `subscription OnUpdateTravelLogs(
  $filter: ModelSubscriptionTravelLogsFilterInput
) {
  onUpdateTravelLogs(filter: $filter) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedSubscription<
  APITypes.OnUpdateTravelLogsSubscriptionVariables,
  APITypes.OnUpdateTravelLogsSubscription
>;
export const onUpdateUserSessions = /* GraphQL */ `subscription OnUpdateUserSessions(
  $filter: ModelSubscriptionUserSessionsFilterInput
) {
  onUpdateUserSessions(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateUserSessionsSubscriptionVariables,
  APITypes.OnUpdateUserSessionsSubscription
>;
export const onUpdateUsers = /* GraphQL */ `subscription OnUpdateUsers($filter: ModelSubscriptionUsersFilterInput) {
  onUpdateUsers(filter: $filter) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateUsersSubscriptionVariables,
  APITypes.OnUpdateUsersSubscription
>;
