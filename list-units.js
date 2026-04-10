const https = require('https');

const SUPABASE_URL = 'skwogboredsczcyhlqgn.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrd29nYm9yZWRzY3pjeWhscWduIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDI1MzY5OSwiZXhwIjoyMDg5ODI5Njk5fQ.VuxUoTz2SRMqRLaYhZtqfrjfNLVyEKMF3v4MU_mfVoY';

function query(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: SUPABASE_URL,
      path: path,
      method: 'GET',
      headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type': 'application/json'
      }
    };

    https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch(e) {
          reject(e);
        }
      });
    }).on('error', reject).end();
  });
}

async function main() {
  try {
    // 获取所有预订记录
    const reservations = await query('/rest/v1/reservations?select=unit_raw&limit=10000');
    
    // 获取 unit_mapping
    const mappings = await query('/rest/v1/unit_mapping?select=*');
    
    // 构建映射表
    const unitMap = {};
    mappings.forEach(m => {
      unitMap[m.raw_name.toLowerCase()] = m.mapped_unit;
    });
    
    // 收集所有单元
    const unitSet = new Set();
    reservations.forEach(r => {
      if (r.unit_raw) {
        const mapped = unitMap[r.unit_raw.toLowerCase()] || r.unit_raw;
        unitSet.add(mapped);
      }
    });
    
    const units = Array.from(unitSet).sort();
    
    console.log(`✅ 找到 ${units.length} 个单元（来自 ${reservations.length} 条预订）:\n`);
    units.forEach((unit, i) => {
      console.log(`${String(i+1).padStart(2, '0')}. ${unit}`);
    });
    
    console.log(`\n📋 以逗号分隔: ${units.join(', ')}`);
  } catch(e) {
    console.log('Error:', e.message);
  }
}

main();
