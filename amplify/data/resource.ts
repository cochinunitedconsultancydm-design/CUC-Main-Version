import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

/*== STEP 1 ===============================================================
The section below creates a Todo database table with a "content" field. Try
adding a new "isDone" field as a boolean. The authorization rule below
specifies that any unauthenticated user can "create", "read", "update", 
and "delete" any "Todo" records.
=========================================================================*/
const schema = a.schema({
  LicenseServices: a.model({
    id: a.id().required(),
    client_license_id: a.integer(),
    service_description: a.string(),
    service_cost: a.float(),
    service_date: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  LicenseNotifications: a.model({
    id: a.id().required(),
    client_license_id: a.integer(),
    notification_type: a.string(),
    message: a.string(),
    is_sent: a.boolean(),
    scheduled_date: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  ServiceNames: a.model({
    id: a.id().required(),
    name: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  DscRecords: a.model({
    id: a.id().required(),
    username: a.string(),
    password: a.string(),
    client_name: a.string(),
    email_id: a.string(),
    phone_no: a.string(),
    dsc_taken_date: a.string(),
    dsc_expiry_date: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  ClientDocuments: a.model({
    id: a.id().required(),
    client_id: a.string(),
    client_name: a.string(),
    document_name: a.string(),
    storage_path: a.string(),
    og_copy: a.string(),
    remarks: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  ServiceContent: a.model({
    id: a.id().required(),
    service_id: a.integer(),
    title: a.string(),
    description: a.string(),
    image_path: a.string(),
    details: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  StaffLocations: a.model({
    user_id: a.integer(),
    latitude: a.float(),
    longitude: a.float(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Clients: a.model({
    id: a.id().required(),
    name: a.string(),
    email: a.string(),
    phone: a.string(),
    address: a.string(),
    created_at: a.string(),
    type_of_work: a.string(),
    case_number: a.string(),
    dob: a.string(),
    review_rating: a.integer(),
    file_no: a.string(),
    file_date: a.string(),
    is_contacted: a.boolean(),
    managed_by: a.string(),
    balance_due: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Tasks: a.model({
    id: a.id().required(),
    title: a.string(),
    description: a.string(),
    assigned_to: a.integer(),
    assigned_by: a.integer(),
    status: a.string(),
    due_date: a.string(),
    created_at: a.string(),
    location: a.string(),
    client_name: a.string(),
    phone_number: a.string(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  DealStageHistory: a.model({
    id: a.id().required(),
    deal_id: a.integer(),
    from_stage: a.string(),
    to_stage: a.string(),
    changed_by: a.integer(),
    changed_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  TravelLogs: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    destination: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  LicenseTypes: a.model({
    id: a.id().required(),
    name: a.string(),
    description: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  LicenseBilling: a.model({
    id: a.id().required(),
    client_license_id: a.integer(),
    amount: a.float(),
    payment_status: a.string(),
    invoice_no: a.string(),
    payment_date: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  ActivityLogs: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    action: a.string(),
    target_type: a.string(),
    target_id: a.string(),
    details: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  ClientLicenses: a.model({
    id: a.id().required(),
    client_id: a.integer(),
    license_type_id: a.integer(),
    file_no: a.string(),
    service_date: a.string(),
    expiry_date: a.string(),
    status: a.string(),
    notes: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
    manual_client_name: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  DealHandoverHistory: a.model({
    id: a.id().required(),
    deal_id: a.integer(),
    from_user_id: a.integer(),
    to_user_id: a.integer(),
    note: a.string(),
    handed_over_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  DealActivities: a.model({
    id: a.id().required(),
    deal_id: a.integer(),
    type: a.string(),
    title: a.string(),
    description: a.string(),
    due_date: a.string(),
    is_completed: a.boolean(),
    created_by: a.integer(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Billings: a.model({
    id: a.id().required(),
    invoice_no: a.string(),
    client_name: a.string(),
    date: a.string(),
    amount: a.string(),
    type: a.string(),
    data: a.string(),
    created_at: a.string(),
    category: a.string(),
    authorities: a.string(),
    status: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Deals: a.model({
    id: a.id().required(),
    name: a.string(),
    client_id: a.integer(),
    client_name: a.string(),
    contact_info: a.string(),
    company: a.string(),
    work_type: a.string(),
    stage: a.string(),
    responsible_id: a.integer(),
    responsible_name: a.string(),
    amount: a.float(),
    currency: a.string(),
    pipeline: a.string(),
    priority: a.string(),
    description: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
    closed_at: a.string(),
    is_won: a.boolean(),
    reg_fee_required: a.string(),
    files_received: a.string(),
    contact_status: a.string(),
    files_asked: a.string(),
    est_amount_work: a.float(),
    create_invoice_share: a.string(),
    expense_spent: a.float(),
    upload_invoice_path: a.string(),
    send_to_customer: a.string(),
    register_no: a.string(),
    invoice_amount: a.float(),
    payment_type: a.string(),
    drive_link: a.string(),
    billing_id: a.integer(),
    quotation_id: a.integer(),
    payment_received: a.float(),
    part_payment_amount: a.float(),
    noc_obtained: a.boolean(),
    referred_by: a.string(),
    expenses_list: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Messages: a.model({
    id: a.id().required(),
    sender_id: a.integer(),
    receiver_id: a.integer(),
    content: a.string(),
    is_read: a.boolean(),
    created_at: a.string(),
    attachment_type: a.string(),
    attachment_id: a.integer(),
  }).authorization((allow) => [allow.authenticated()]),
  StaffAttendance: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    check_in_time: a.string(),
    check_out_time: a.string(),
    attendance_date: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  CompanyBills: a.model({
    id: a.id().required(),
    category: a.string(),
    title: a.string(),
    amount: a.float(),
    bill_date: a.string(),
    status: a.string(),
    description: a.string(),
    created_at: a.string(),
    spent_by: a.integer(),
    spent_by_name: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  SysCronLogs: a.model({
    id: a.id().required(),
    job_name: a.string(),
    last_run_date: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Users: a.model({
    id: a.id().required(),
    username: a.string(),
    password: a.string(),
    role: a.string(),
    name: a.string(),
    created_at: a.string(),
    last_seen: a.string(),
    email: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  InwardPosts: a.model({
    id: a.id().required(),
    sender_name: a.string(),
    recipient_name: a.string(),
    received_by: a.string(),
    description: a.string(),
    status: a.string(),
    received_date: a.string(),
    created_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  LocationHistory: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    latitude: a.float(),
    longitude: a.float(),
    recorded_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  UserSessions: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    login_time: a.string(),
    logout_time: a.string(),
    ip_address: a.string(),
    is_active: a.boolean(),
    status: a.string(),
    active_seconds: a.integer(),
    idle_seconds: a.integer(),
  }).authorization((allow) => [allow.authenticated()]),
  Checklists: a.model({
    id: a.id().required(),
    title: a.string(),
    description: a.string(),
    manager_id: a.integer(),
    responsible_id: a.integer(),
    status: a.string(),
    remarks: a.string(),
    reason: a.string(),
    due_date: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  DealAssignees: a.model({
    id: a.id().required(),
    deal_id: a.integer(),
    user_id: a.integer(),
    role: a.string(),
    assigned_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
  Notifications: a.model({
    id: a.id().required(),
    user_id: a.integer(),
    title: a.string(),
    message: a.string(),
    type: a.string(),
    is_read: a.boolean(),
    created_at: a.string(),
    deal_id: a.integer(),
    task_id: a.integer(),
  }).authorization((allow) => [allow.authenticated()]),
  Properties: a.model({
    id: a.id().required(),
    property_name: a.string(),
    client_name: a.string(),
    location: a.string(),
    property_type: a.string(), // "Apartment/flat", "plain land", etc.
    
    // Building owner details
    owner_name: a.string(),
    owner_phone_numbers: a.string().array(),
    
    // Additional Contacts
    broker_details: a.string(),
    care_of: a.string(),
    
    // Area & Price
    area: a.string(),
    price: a.float(),
    is_negotiable: a.boolean(),
    
    // Detailed Specs
    floor: a.string(),
    has_balcony: a.boolean(),
    balcony_count: a.integer(),
    is_furnished: a.boolean(),
    has_car_parking: a.boolean(),
    expenses: a.string(),
    
    // Media
    photos: a.string().array(),
    
    status: a.string(),
    notes: a.string(),
    created_at: a.string(),
    updated_at: a.string(),
  }).authorization((allow) => [allow.authenticated()]),
});


export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPools',
  },
});

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: todos } = await client.models.Todo.list()

// return <ul>{todos.map(todo => <li key={todo.id}>{todo.content}</li>)}</ul>
