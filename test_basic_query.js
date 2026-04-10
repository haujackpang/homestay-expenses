const https = require('https');

const SUPABASE_URL = 'skwogboredsczcyhlqgn.supabase.co';
const API_KEY = 'sb_publishable_92g8DBB_Zf5cv8fqaFBdEA_1fK6e0VL';

// 简单查询，不带任何过滤条件
const options = {
  hostname: SUPABASE_URL,
  path: '/rest/v1/reservations?limit=5',
  method: 'GET',
  headers: {
    'apikey': API_KEY,
    'Authorization': `Bearer ${API_KEY}`,
    'Content-Type': 'application/json'
  }
};

console.log('Testing basic query to reservations table...\n');

const req = https.request(options, (res) => {
  let data = '';
  
  console.log('Response Status:', res.statusCode);
  console.log('Headers:', res.headers);
  console.log('');
  
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      if (data) {
        const records = JSON.parse(data);
        console.log(`Response data length: ${data.length} chars`);
        console.log(`Record count: ${Array.isArray(records) ? records.length : 'not array'}`);
        if (Array.isArray(records) && records.length > 0) {
          console.log('\nFirst record keys:', Object.keys(records[0]));
          console.log('\nFirst record:', JSON.stringify(records[0], null, 2).substring(0, 500));
        }
      } else {
        console.log('Empty response');
      }
    } catch(e) {
      console.log('Parse error:', e.message);
      console.log('Raw data:', data.substring(0, 200));
    }
  });
});

req.on('error', e => console.log('Request error:', e.message));
req.end();
