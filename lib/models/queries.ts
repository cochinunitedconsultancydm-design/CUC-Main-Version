/* tslint:disable */
/* eslint-disable */
// this is an auto generated file. This will be overwritten

import * as APITypes from "./API";
type GeneratedQuery<InputType, OutputType> = string & {
  __generatedQueryInput: InputType;
  __generatedQueryOutput: OutputType;
};

export const getActivityLogs = /* GraphQL */ `query GetActivityLogs($id: ID!) {
  getActivityLogs(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetActivityLogsQueryVariables,
  APITypes.GetActivityLogsQuery
>;
export const getBillings = /* GraphQL */ `query GetBillings($id: ID!) {
  getBillings(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetBillingsQueryVariables,
  APITypes.GetBillingsQuery
>;
export const getChecklists = /* GraphQL */ `query GetChecklists($id: ID!) {
  getChecklists(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetChecklistsQueryVariables,
  APITypes.GetChecklistsQuery
>;
export const getClientDocuments = /* GraphQL */ `query GetClientDocuments($id: ID!) {
  getClientDocuments(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetClientDocumentsQueryVariables,
  APITypes.GetClientDocumentsQuery
>;
export const getClientLicenses = /* GraphQL */ `query GetClientLicenses($id: ID!) {
  getClientLicenses(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetClientLicensesQueryVariables,
  APITypes.GetClientLicensesQuery
>;
export const getClients = /* GraphQL */ `query GetClients($id: ID!) {
  getClients(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetClientsQueryVariables,
  APITypes.GetClientsQuery
>;
export const getCompanyBills = /* GraphQL */ `query GetCompanyBills($id: ID!) {
  getCompanyBills(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetCompanyBillsQueryVariables,
  APITypes.GetCompanyBillsQuery
>;
export const getDealActivities = /* GraphQL */ `query GetDealActivities($id: ID!) {
  getDealActivities(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetDealActivitiesQueryVariables,
  APITypes.GetDealActivitiesQuery
>;
export const getDealAssignees = /* GraphQL */ `query GetDealAssignees($id: ID!) {
  getDealAssignees(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetDealAssigneesQueryVariables,
  APITypes.GetDealAssigneesQuery
>;
export const getDealHandoverHistory = /* GraphQL */ `query GetDealHandoverHistory($id: ID!) {
  getDealHandoverHistory(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetDealHandoverHistoryQueryVariables,
  APITypes.GetDealHandoverHistoryQuery
>;
export const getDealStageHistory = /* GraphQL */ `query GetDealStageHistory($id: ID!) {
  getDealStageHistory(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetDealStageHistoryQueryVariables,
  APITypes.GetDealStageHistoryQuery
>;
export const getDeals = /* GraphQL */ `query GetDeals($id: ID!) {
  getDeals(id: $id) {
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
` as GeneratedQuery<APITypes.GetDealsQueryVariables, APITypes.GetDealsQuery>;
export const getDscRecords = /* GraphQL */ `query GetDscRecords($id: ID!) {
  getDscRecords(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetDscRecordsQueryVariables,
  APITypes.GetDscRecordsQuery
>;
export const getInwardPosts = /* GraphQL */ `query GetInwardPosts($id: ID!) {
  getInwardPosts(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetInwardPostsQueryVariables,
  APITypes.GetInwardPostsQuery
>;
export const getLicenseBilling = /* GraphQL */ `query GetLicenseBilling($id: ID!) {
  getLicenseBilling(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetLicenseBillingQueryVariables,
  APITypes.GetLicenseBillingQuery
>;
export const getLicenseNotifications = /* GraphQL */ `query GetLicenseNotifications($id: ID!) {
  getLicenseNotifications(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetLicenseNotificationsQueryVariables,
  APITypes.GetLicenseNotificationsQuery
>;
export const getLicenseServices = /* GraphQL */ `query GetLicenseServices($id: ID!) {
  getLicenseServices(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetLicenseServicesQueryVariables,
  APITypes.GetLicenseServicesQuery
>;
export const getLicenseTypes = /* GraphQL */ `query GetLicenseTypes($id: ID!) {
  getLicenseTypes(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetLicenseTypesQueryVariables,
  APITypes.GetLicenseTypesQuery
>;
export const getLocationHistory = /* GraphQL */ `query GetLocationHistory($id: ID!) {
  getLocationHistory(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetLocationHistoryQueryVariables,
  APITypes.GetLocationHistoryQuery
>;
export const getMessages = /* GraphQL */ `query GetMessages($id: ID!) {
  getMessages(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetMessagesQueryVariables,
  APITypes.GetMessagesQuery
>;
export const getNotifications = /* GraphQL */ `query GetNotifications($id: ID!) {
  getNotifications(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetNotificationsQueryVariables,
  APITypes.GetNotificationsQuery
>;
export const getServiceContent = /* GraphQL */ `query GetServiceContent($id: ID!) {
  getServiceContent(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetServiceContentQueryVariables,
  APITypes.GetServiceContentQuery
>;
export const getServiceNames = /* GraphQL */ `query GetServiceNames($id: ID!) {
  getServiceNames(id: $id) {
    createdAt
    created_at
    id
    name
    updatedAt
    __typename
  }
}
` as GeneratedQuery<
  APITypes.GetServiceNamesQueryVariables,
  APITypes.GetServiceNamesQuery
>;
export const getStaffAttendance = /* GraphQL */ `query GetStaffAttendance($id: ID!) {
  getStaffAttendance(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetStaffAttendanceQueryVariables,
  APITypes.GetStaffAttendanceQuery
>;
export const getStaffLocations = /* GraphQL */ `query GetStaffLocations($id: ID!) {
  getStaffLocations(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetStaffLocationsQueryVariables,
  APITypes.GetStaffLocationsQuery
>;
export const getSysCronLogs = /* GraphQL */ `query GetSysCronLogs($id: ID!) {
  getSysCronLogs(id: $id) {
    createdAt
    id
    job_name
    last_run_date
    updatedAt
    __typename
  }
}
` as GeneratedQuery<
  APITypes.GetSysCronLogsQueryVariables,
  APITypes.GetSysCronLogsQuery
>;
export const getTasks = /* GraphQL */ `query GetTasks($id: ID!) {
  getTasks(id: $id) {
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
` as GeneratedQuery<APITypes.GetTasksQueryVariables, APITypes.GetTasksQuery>;
export const getTravelLogs = /* GraphQL */ `query GetTravelLogs($id: ID!) {
  getTravelLogs(id: $id) {
    createdAt
    created_at
    destination
    id
    updatedAt
    user_id
    __typename
  }
}
` as GeneratedQuery<
  APITypes.GetTravelLogsQueryVariables,
  APITypes.GetTravelLogsQuery
>;
export const getUserSessions = /* GraphQL */ `query GetUserSessions($id: ID!) {
  getUserSessions(id: $id) {
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
` as GeneratedQuery<
  APITypes.GetUserSessionsQueryVariables,
  APITypes.GetUserSessionsQuery
>;
export const getUsers = /* GraphQL */ `query GetUsers($id: ID!) {
  getUsers(id: $id) {
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
` as GeneratedQuery<APITypes.GetUsersQueryVariables, APITypes.GetUsersQuery>;
export const listActivityLogs = /* GraphQL */ `query ListActivityLogs(
  $filter: ModelActivityLogsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listActivityLogs(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListActivityLogsQueryVariables,
  APITypes.ListActivityLogsQuery
>;
export const listBillings = /* GraphQL */ `query ListBillings(
  $filter: ModelBillingsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listBillings(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListBillingsQueryVariables,
  APITypes.ListBillingsQuery
>;
export const listChecklists = /* GraphQL */ `query ListChecklists(
  $filter: ModelChecklistsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listChecklists(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListChecklistsQueryVariables,
  APITypes.ListChecklistsQuery
>;
export const listClientDocuments = /* GraphQL */ `query ListClientDocuments(
  $filter: ModelClientDocumentsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listClientDocuments(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListClientDocumentsQueryVariables,
  APITypes.ListClientDocumentsQuery
>;
export const listClientLicenses = /* GraphQL */ `query ListClientLicenses(
  $filter: ModelClientLicensesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listClientLicenses(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListClientLicensesQueryVariables,
  APITypes.ListClientLicensesQuery
>;
export const listClients = /* GraphQL */ `query ListClients(
  $filter: ModelClientsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listClients(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListClientsQueryVariables,
  APITypes.ListClientsQuery
>;
export const listCompanyBills = /* GraphQL */ `query ListCompanyBills(
  $filter: ModelCompanyBillsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listCompanyBills(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListCompanyBillsQueryVariables,
  APITypes.ListCompanyBillsQuery
>;
export const listDealActivities = /* GraphQL */ `query ListDealActivities(
  $filter: ModelDealActivitiesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDealActivities(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListDealActivitiesQueryVariables,
  APITypes.ListDealActivitiesQuery
>;
export const listDealAssignees = /* GraphQL */ `query ListDealAssignees(
  $filter: ModelDealAssigneesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDealAssignees(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      assigned_at
      createdAt
      deal_id
      id
      role
      updatedAt
      user_id
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListDealAssigneesQueryVariables,
  APITypes.ListDealAssigneesQuery
>;
export const listDealHandoverHistories = /* GraphQL */ `query ListDealHandoverHistories(
  $filter: ModelDealHandoverHistoryFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDealHandoverHistories(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListDealHandoverHistoriesQueryVariables,
  APITypes.ListDealHandoverHistoriesQuery
>;
export const listDealStageHistories = /* GraphQL */ `query ListDealStageHistories(
  $filter: ModelDealStageHistoryFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDealStageHistories(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListDealStageHistoriesQueryVariables,
  APITypes.ListDealStageHistoriesQuery
>;
export const listDeals = /* GraphQL */ `query ListDeals(
  $filter: ModelDealsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDeals(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<APITypes.ListDealsQueryVariables, APITypes.ListDealsQuery>;
export const listDscRecords = /* GraphQL */ `query ListDscRecords(
  $filter: ModelDscRecordsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listDscRecords(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListDscRecordsQueryVariables,
  APITypes.ListDscRecordsQuery
>;
export const listInwardPosts = /* GraphQL */ `query ListInwardPosts(
  $filter: ModelInwardPostsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listInwardPosts(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListInwardPostsQueryVariables,
  APITypes.ListInwardPostsQuery
>;
export const listLicenseBillings = /* GraphQL */ `query ListLicenseBillings(
  $filter: ModelLicenseBillingFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listLicenseBillings(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListLicenseBillingsQueryVariables,
  APITypes.ListLicenseBillingsQuery
>;
export const listLicenseNotifications = /* GraphQL */ `query ListLicenseNotifications(
  $filter: ModelLicenseNotificationsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listLicenseNotifications(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListLicenseNotificationsQueryVariables,
  APITypes.ListLicenseNotificationsQuery
>;
export const listLicenseServices = /* GraphQL */ `query ListLicenseServices(
  $filter: ModelLicenseServicesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listLicenseServices(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListLicenseServicesQueryVariables,
  APITypes.ListLicenseServicesQuery
>;
export const listLicenseTypes = /* GraphQL */ `query ListLicenseTypes(
  $filter: ModelLicenseTypesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listLicenseTypes(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      createdAt
      created_at
      description
      id
      name
      updatedAt
      updated_at
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListLicenseTypesQueryVariables,
  APITypes.ListLicenseTypesQuery
>;
export const listLocationHistories = /* GraphQL */ `query ListLocationHistories(
  $filter: ModelLocationHistoryFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listLocationHistories(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      createdAt
      id
      latitude
      longitude
      recorded_at
      updatedAt
      user_id
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListLocationHistoriesQueryVariables,
  APITypes.ListLocationHistoriesQuery
>;
export const listMessages = /* GraphQL */ `query ListMessages(
  $filter: ModelMessagesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listMessages(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListMessagesQueryVariables,
  APITypes.ListMessagesQuery
>;
export const listNotifications = /* GraphQL */ `query ListNotifications(
  $filter: ModelNotificationsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listNotifications(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListNotificationsQueryVariables,
  APITypes.ListNotificationsQuery
>;
export const listServiceContents = /* GraphQL */ `query ListServiceContents(
  $filter: ModelServiceContentFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listServiceContents(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListServiceContentsQueryVariables,
  APITypes.ListServiceContentsQuery
>;
export const listServiceNames = /* GraphQL */ `query ListServiceNames(
  $filter: ModelServiceNamesFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listServiceNames(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      createdAt
      created_at
      id
      name
      updatedAt
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListServiceNamesQueryVariables,
  APITypes.ListServiceNamesQuery
>;
export const listStaffAttendances = /* GraphQL */ `query ListStaffAttendances(
  $filter: ModelStaffAttendanceFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listStaffAttendances(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      attendance_date
      check_in_time
      check_out_time
      createdAt
      id
      updatedAt
      user_id
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListStaffAttendancesQueryVariables,
  APITypes.ListStaffAttendancesQuery
>;
export const listStaffLocations = /* GraphQL */ `query ListStaffLocations(
  $filter: ModelStaffLocationsFilterInput
  $limit: Int
  $nextToken: String
) {
  listStaffLocations(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      createdAt
      id
      latitude
      longitude
      updatedAt
      updated_at
      user_id
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListStaffLocationsQueryVariables,
  APITypes.ListStaffLocationsQuery
>;
export const listSysCronLogs = /* GraphQL */ `query ListSysCronLogs(
  $filter: ModelSysCronLogsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listSysCronLogs(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      createdAt
      id
      job_name
      last_run_date
      updatedAt
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListSysCronLogsQueryVariables,
  APITypes.ListSysCronLogsQuery
>;
export const listTasks = /* GraphQL */ `query ListTasks(
  $filter: ModelTasksFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listTasks(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<APITypes.ListTasksQueryVariables, APITypes.ListTasksQuery>;
export const listTravelLogs = /* GraphQL */ `query ListTravelLogs(
  $filter: ModelTravelLogsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listTravelLogs(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
      createdAt
      created_at
      destination
      id
      updatedAt
      user_id
      __typename
    }
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListTravelLogsQueryVariables,
  APITypes.ListTravelLogsQuery
>;
export const listUserSessions = /* GraphQL */ `query ListUserSessions(
  $filter: ModelUserSessionsFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listUserSessions(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<
  APITypes.ListUserSessionsQueryVariables,
  APITypes.ListUserSessionsQuery
>;
export const listUsers = /* GraphQL */ `query ListUsers(
  $filter: ModelUsersFilterInput
  $id: ID
  $limit: Int
  $nextToken: String
  $sortDirection: ModelSortDirection
) {
  listUsers(
    filter: $filter
    id: $id
    limit: $limit
    nextToken: $nextToken
    sortDirection: $sortDirection
  ) {
    items {
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
    nextToken
    __typename
  }
}
` as GeneratedQuery<APITypes.ListUsersQueryVariables, APITypes.ListUsersQuery>;
