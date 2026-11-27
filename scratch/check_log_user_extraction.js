const https = require('https');

const supabaseUrl = 'https://bzxtgiqjgfojblezdubd.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6eHRnaXFqZ2ZvamJsZXpkdWJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTMxMzIsImV4cCI6MjA4MTM2OTEzMn0.E8IKI5PvnW9WoEX4EcXvcSVk0b74LGrrQhNhFX99Dxo';

function fetchSupabase(path) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, supabaseUrl);
    const req = https.request(url, {
      method: 'GET',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json'
      }
    }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve(data);
        }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

async function main() {
  const logs = await fetchSupabase('/rest/v1/activity_logs?order=created_at.desc&limit=50&select=id,action,user_id,details,created_at');
  console.log('--- SAMPLE 50 RECENT LOGS WITH EXTRACTED USER ---');
  for (const l of logs) {
    const match = /\[User:\s*([^\]]+)\]/i.exec(l.details || '');
    const user = match ? match[1].trim() : 'NONE';
    console.log(`Action: ${l.action.padEnd(25)} | Extracted User: ${user.padEnd(20)} | Time: ${l.created_at}`);
  }
}

main().catch(console.error);
