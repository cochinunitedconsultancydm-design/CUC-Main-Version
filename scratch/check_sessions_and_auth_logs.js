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
  const sessions = await fetchSupabase('/rest/v1/user_sessions?order=login_time.desc&limit=30&select=*');
  console.log('--- RECENT USER SESSIONS ---');
  console.table(sessions.map(s => ({
    id: s.id,
    user_id: s.user_id,
    username: s.username,
    login_time: s.login_time,
    logout_time: s.logout_time,
    is_active: s.is_active,
    status: s.status
  })));

  const authLogs = await fetchSupabase('/rest/v1/activity_logs?action=in.(LOGIN,LOGOUT)&order=created_at.desc&limit=30&select=*');
  console.log('--- RECENT LOGIN/LOGOUT ACTIVITY LOGS ---');
  console.table(authLogs.map(l => ({
    id: l.id,
    action: l.action,
    user_id: l.user_id,
    target_id: l.target_id,
    details: l.details,
    created_at: l.created_at
  })));
}

main().catch(console.error);
