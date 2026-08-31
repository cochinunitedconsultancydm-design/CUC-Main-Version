const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'amplify', 'data', 'resource.ts');
let content = fs.readFileSync(filePath, 'utf8');

const categories = {
    highlySensitive: ['Users', 'DscRecords', 'UserSessions'],
    personalLogs: ['StaffAttendance', 'TravelLogs', 'ActivityLogs'],
    operational: ['LicenseServices', 'LicenseNotifications', 'ServiceNames', 'ServiceContent', 'Sops', 'OfficeLocations', 'Contacts', 'LicenseTypes'],
    business: ['ClientDocuments', 'Clients', 'Tasks', 'DealStageHistory', 'LicenseBilling', 'ClientLicenses', 'DealHandoverHistory', 'DealActivities', 'Billings', 'Deals', 'Messages', 'CompanyBills', 'SysCronLogs', 'InwardPosts', 'Checklists', 'DealAssignees', 'Notifications', 'Properties']
};

const rules = {
    highlySensitive: `.authorization((allow) => [allow.owner(), allow.groups(['Admin'])])`,
    personalLogs: `.authorization((allow) => [allow.owner(), allow.groups(['Admin', 'Manager'])])`,
    operational: `.authorization((allow) => [allow.groups(['Admin']), allow.authenticated().to(['read'])])`,
    business: `.authorization((allow) => [allow.groups(['Admin', 'Manager']), allow.authenticated().to(['read', 'create'])])`
};

for (const [category, tables] of Object.entries(categories)) {
    for (const table of tables) {
        // Regex to match the start of the model definition until the end of its authorization block
        // Example:  Users: a.model({ ... }).authorization((allow) => [allow.authenticated()]),
        
        const regex = new RegExp(`(${table}:\\s*a\\.model\\(\\{[\\s\\S]*?\\}\\))\\.authorization\\(\\(allow\\)\\s*=>\\s*\\[allow\\.authenticated\\(\\)\\]\\)`, 'g');
        content = content.replace(regex, `$1${rules[category]}`);
    }
}

fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated authorization rules in resource.ts');
