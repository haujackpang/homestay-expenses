const https = require('https');

// Use a real publicly accessible small receipt-like image for testing
const testImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png';

const body = JSON.stringify({
  fileUrl: testImageUrl,
  mimeType: 'image/png'
});

const options = {
  hostname: 'skwogboredsczcyhlqgn.supabase.co',
  path: '/functions/v1/analyze-receipt',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MjUxMzUsImV4cCI6MjA1ODIwMTEzNX0.sb_publishable_92g8DBB_Zf5cv8fqaFBdEA_1fK6e0VL',
    'Content-Length': Buffer.byteLength(body)
  }
};

console.log('Testing deployed Edge Function...');
const req = https.request(options, (res) => {
  let data = '';
  res.on('data', c => data += c);
  res.on('end', () => {
    console.log('STATUS:', res.statusCode);
    try {
      const json = JSON.parse(data);
      if (json.error) {
        console.log('FUNCTION ERROR:', json.error);
      } else {
        console.log('SUCCESS! Result:', JSON.stringify(json, null, 2).substring(0, 300));
      }
    } catch(e) {
      console.log('RAW:', data.substring(0, 300));
    }
  });
});
req.on('error', e => console.log('ERROR:', e.message));
req.write(body);
req.end();
