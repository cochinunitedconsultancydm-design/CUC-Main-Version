const { CognitoIdentityProviderClient, AdminCreateUserCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const crypto = require('crypto');
const fs = require('fs');

const REGION = "ap-south-1";
const USER_POOL_ID = "ap-south-1_flKhvQrrS";
const DYNAMODB_TABLE = "Users-gkluolxg2vb5zctdoiovv5tuzu-NONE";

const dynamoDb = new DynamoDBClient({ region: REGION });
const cognito = new CognitoIdentityProviderClient({ region: REGION });

function generateTempPassword() {
  // Generate a random 12-character password that meets Cognito's default complexity requirements
  // Requires: uppercase, lowercase, numbers, symbols
  const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const lower = "abcdefghijklmnopqrstuvwxyz";
  const num = "0123456789";
  const sym = "!@#$%^&*()_+";
  
  const all = upper + lower + num + sym;
  let password = "";
  password += upper[Math.floor(Math.random() * upper.length)];
  password += lower[Math.floor(Math.random() * lower.length)];
  password += num[Math.floor(Math.random() * num.length)];
  password += sym[Math.floor(Math.random() * sym.length)];
  
  for (let i = 0; i < 8; i++) {
    password += all[Math.floor(Math.random() * all.length)];
  }
  
  // Shuffle
  return password.split('').sort(() => 0.5 - Math.random()).join('');
}

async function migrateUsers() {
  console.log(`Starting migration from DynamoDB table: ${DYNAMODB_TABLE} to Cognito User Pool: ${USER_POOL_ID}`);
  
  try {
    const scanCommand = new ScanCommand({ TableName: DYNAMODB_TABLE });
    const response = await dynamoDb.send(scanCommand);
    const users = response.Items || [];
    
    console.log(`Found ${users.length} users in DynamoDB.`);
    
    const migrationLog = [];
    
    for (const user of users) {
      const username = user.username?.S || 'unknown';
      let email = user.email?.S;
      
      if (!email || !email.includes('@')) {
        email = `${username.trim().toLowerCase()}@cuc.local`;
      }
      
      const tempPassword = generateTempPassword();
      
      console.log(`Migrating user: ${username} (Email: ${email})...`);
      
      try {
        const createCommand = new AdminCreateUserCommand({
          UserPoolId: USER_POOL_ID,
          Username: email,
          MessageAction: "SUPPRESS", // Don't send email via Cognito default (SES is likely not configured)
          TemporaryPassword: tempPassword,
          UserAttributes: [
            { Name: "email", Value: email },
            { Name: "email_verified", Value: "true" }
          ]
        });
        
        await cognito.send(createCommand);
        console.log(`✅ Successfully migrated ${username}.`);
        migrationLog.push(`Username: ${username} | Email Login: ${email} | Temporary Password: ${tempPassword}`);
        
      } catch (err) {
        if (err.name === 'UsernameExistsException') {
           console.log(`⚠️ User ${email} already exists in Cognito. Skipping.`);
        } else {
           console.error(`❌ Failed to migrate ${username}:`, err.message);
        }
      }
    }
    
    console.log("\n--- MIGRATION COMPLETE ---");
    console.log("Please distribute these temporary passwords to your staff:");
    console.log(migrationLog.join('\n'));
    
    // Save to a local file for the user to keep securely
    fs.writeFileSync('passwords.txt', migrationLog.join('\n'));
    console.log("\nSaved passwords to passwords.txt in the project directory.");
    
  } catch (err) {
    console.error("Migration failed:", err);
  }
}

migrateUsers();
