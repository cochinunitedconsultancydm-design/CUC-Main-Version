import fs from 'fs';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co/rest/v1';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTc5MzEzMiwiZXhwIjoyMDgxMzY5MTMyfQ.w15N2FZ8xHeDBDcwj79Kl-JBXi1h0QnB9UDNRbAhVZ4';

// Initialize DynamoDB Client
const client = new DynamoDBClient({ region: 'ap-south-1' });
const docClient = DynamoDBDocumentClient.from(client);

const SUFFIX = '-gkluolxg2vb5zctdoiovv5tuzu-NONE';

// Map supabase table names to Amplify model names (DynamoDB prefix)
const tableMapping = {
    'users': 'Users',
    'tasks': 'Tasks',
    'deals': 'Deals',
    'clients': 'Clients',
    'billings': 'Billings',
    'company_bills': 'CompanyBills',
    'client_documents': 'ClientDocuments',
    'client_licenses': 'ClientLicenses',
    'license_types': 'LicenseTypes',
    'license_services': 'LicenseServices',
    'license_billing': 'LicenseBilling',
    'license_notifications': 'LicenseNotifications',
    'deal_assignees': 'DealAssignees',
    'deal_stage_history': 'DealStageHistory',
    'deal_handover_history': 'DealHandoverHistory',
    'deal_activities': 'DealActivities',
    'messages': 'Messages',
    'activity_logs': 'ActivityLogs',
    'notifications': 'Notifications',
    'user_sessions': 'UserSessions',
    'checklists': 'Checklists',
    'staff_attendance': 'StaffAttendance',
    'staff_locations': 'StaffLocations',
    'location_history': 'LocationHistory',
    'travel_logs': 'TravelLogs',
    'inward_posts': 'InwardPosts',
    'dsc_records': 'DscRecords',
    'service_names': 'ServiceNames',
    'service_content': 'ServiceContent',
    'sys_cron_logs': 'SysCronLogs'
};

async function fetchSupabase(table) {
    let allData = [];
    let offset = 0;
    while (true) {
        const res = await fetch(`${supabaseUrl}/${table}?select=*&limit=1000&offset=${offset}`, {
            headers: {
                'apikey': anonKey,
                'Authorization': `Bearer ${anonKey}`
            }
        });
        const data = await res.json();
        if (data.error) throw data.error;
        if (data.length === 0) break;
        allData = allData.concat(data);
        offset += data.length;
    }
    return allData;
}

async function migrate() {
    for (const [sbTable, amModel] of Object.entries(tableMapping)) {
        console.log(`\nFetching ${sbTable} from Supabase...`);
        try {
            const rows = await fetchSupabase(sbTable);
            console.log(`Fetched ${rows.length} rows for ${sbTable}`);
            
            const dynamoTable = `${amModel}${SUFFIX}`;
            let inserted = 0;
            
            for (const row of rows) {
                // Ensure ID is a string for DynamoDB
                if (row.id !== undefined && row.id !== null) {
                    row.id = String(row.id);
                } else if (sbTable === 'staff_locations' && row.user_id) {
                    // special table without id
                    row.id = String(row.user_id);
                }
                
                // Add Amplify metadata fields so Datastore works
                row.__typename = amModel;
                if (!row.createdAt) row.createdAt = new Date().toISOString();
                if (!row.updatedAt) row.updatedAt = new Date().toISOString();
                
                try {
                    await docClient.send(new PutCommand({
                        TableName: dynamoTable,
                        Item: row
                    }));
                    inserted++;
                } catch(e) {
                    console.error(`Failed to insert row ${row.id} into ${dynamoTable}:`, e);
                }
            }
            console.log(`Successfully migrated ${inserted}/${rows.length} rows into ${dynamoTable}`);
        } catch(e) {
            console.error(`Error processing table ${sbTable}:`, e);
        }
    }
}

migrate().catch(console.error);
