const { CognitoIdentityProviderClient, AdminInitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");

const REGION = "ap-south-1";

const fs = require('fs');
const outputs = JSON.parse(fs.readFileSync('amplify_outputs.json', 'utf8'));
const clientId = outputs.auth.user_pool_client_id;
const userPoolId = outputs.auth.user_pool_id;

const cognito = new CognitoIdentityProviderClient({ region: REGION });

async function testLogin(username, password) {
  try {
    console.log(`Testing login for ${username} with client ID ${clientId}`);
    const command = new AdminInitiateAuthCommand({
      AuthFlow: "ADMIN_NO_SRP_AUTH",
      ClientId: clientId,
      UserPoolId: userPoolId,
      AuthParameters: {
        USERNAME: username,
        PASSWORD: password
      }
    });
    
    const response = await cognito.send(command);
    console.log("Response:", response.ChallengeName || "Success");
  } catch (e) {
    console.error("Error:", e.name, e.message);
  }
}

testLogin("jesna@cuc.local", "5Yzf8OUcY9#g");
