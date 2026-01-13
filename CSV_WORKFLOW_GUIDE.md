# YouMean CSV Export/Import Workflow

## Overview

For maximum control and offline processing, you can export pending requests as CSV, process them in your separate program (e.g., "umean toad"), and upload results back.

---

## Export Pending Requests as CSV

### Via Admin Panel (Easiest)

1. Open admin panel: `https://your-ngrok-url.ngrok-free.dev/admin`
2. Click **"📊 Export Pending as CSV"** button
3. CSV file will download automatically: `pending_requests.csv`

### Via API (for automation)

```bash
curl -o pending_requests.csv http://localhost:3000/api/admin/export-csv
```

Or via ngrok:
```bash
curl -o pending_requests.csv https://your-ngrok-url.ngrok-free.dev/api/admin/export-csv
```

---

## CSV Format

### Export Format (Pending Requests)

```csv
request_id,birth_city,birth_date,birth_time,emotional_state,belief_science,belief_god,belief_spirituality,submitted_at
"32d4e5fc-...","New York","1995-06-15","14:30","Feeling curious",1,0,0,1768258076
"csv-test-001","Los Angeles","1990-03-15","10:30","Feeling reflective",1,0,1,1768297138
```

**Column Descriptions:**
- `request_id`: Unique UUID for this request
- `birth_city`: City of birth (string)
- `birth_date`: Date in YYYY-MM-DD format
- `birth_time`: Time in HH:MM format (24-hour)
- `emotional_state`: User's emotional description (string)
- `belief_science`: 1 if user believes in science, 0 otherwise
- `belief_god`: 1 if user believes in god(s), 0 otherwise
- `belief_spirituality`: 1 if user believes in spirituality, 0 otherwise
- `submitted_at`: Unix timestamp

---

## Offline Processing Workflow

### Option 1: Python Manual Script (Already Available)

```bash
cd /Users/redradzn/desktop/YouMean/rust
python3 manual_process.py
```

This script:
1. Reads pending requests from database
2. Calls your `astro_engine.py` for each request
3. Saves results back to database
4. 100% offline processing on your MacBook

### Option 2: External Program ("umean toad")

You can process the CSV in your separate program:

1. **Export CSV** from admin panel
2. **Load CSV** into your external program
3. **Process each row** with your algorithms
4. **Generate results** in the expected format
5. **Import results back** (see below)

---

## Expected Result Format

When processing requests, your results should be in JSON format:

```json
{
  "probability_score": 0.138,
  "insights": [
    "Astronomical analysis complete for New York",
    "Birth data processed: 1995-06-15"
  ],
  "historical_correlations": [
    "Historical data analyzed for birth year"
  ],
  "calculated_at": 1768258076,
  "mind_selfie": {
    "belief_system": "science",
    "user_age": 30,
    "total_years_available": 36,
    "years": [
      {
        "age": 0,
        "row1": "Foundation Building",
        "row2": "No significant transits affecting mental state currently.",
        "row3": "100% activation",
        "row4": "100% synthesis",
        "row5": "93% understanding"
      },
      ...
    ]
  }
}
```

---

## Import Results Back (Manual Method)

### Using Python to Update Database

Create a script to import results:

```python
import json
import sqlite3
from datetime import datetime

DB_PATH = "/Users/redradzn/desktop/YouMean/rust/youmean_data.db"

def import_result(request_id, result_dict):
    """Import a single result back to database"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    result_json = json.dumps(result_dict)
    processed_at = int(datetime.now().timestamp())

    cursor.execute("""
        UPDATE request_queue
        SET status = 'completed',
            result_json = ?,
            processed_at = ?
        WHERE id = ?
    """, (result_json, processed_at, request_id))

    conn.commit()
    conn.close()
    print(f"✅ Result imported for request: {request_id}")

# Example usage:
result = {
    "probability_score": 0.15,
    "insights": ["Analysis complete"],
    "historical_correlations": ["Data processed"],
    "calculated_at": int(datetime.now().timestamp()),
    "mind_selfie": {...}
}

import_result("32d4e5fc-fd5f-4cae-8a9e-a1b617ffab54", result)
```

---

## Complete Offline Workflow Example

### Step 1: Export Pending Requests

```bash
# Open admin panel
open https://your-ngrok-url.ngrok-free.dev/admin

# Click "Export Pending as CSV" button
# File downloads as: pending_requests.csv
```

### Step 2: Process Offline

**Option A: Use manual_process.py**
```bash
cd /Users/redradzn/desktop/YouMean/rust

# Optionally disconnect from internet (paranoid mode!)
# Your algorithms run 100% offline

python3 manual_process.py
```

**Option B: Use your external program**
```bash
# Load pending_requests.csv into your program
# Process with your algorithms
# Save results in JSON format
```

### Step 3: Results Available

After processing, users can:
1. Visit umean.app
2. Click "Check Results Now" button
3. Enter their request ID
4. View their Mind Selfie!

---

## Security Benefits

### Why This Workflow is Secure

1. **Data Export**: Only anonymous birth data exported (no PII)
2. **Offline Processing**: Your algorithms run on YOUR MacBook
3. **No Code Exposure**: Your proprietary code never leaves your machine
4. **Manual Control**: You decide when to process requests
5. **Air-Gapped Option**: Can disconnect from internet during processing

### What's Exported vs What Stays Private

**Exported (CSV):**
- ✅ Birth date, time, place
- ✅ Emotional state description
- ✅ Belief system flags
- ✅ Request ID

**Stays Private (NEVER exported):**
- ❌ Your Python algorithms
- ❌ astro_engine.py logic
- ❌ translation_engine.py logic
- ❌ Any proprietary calculations
- ❌ Database file

---

## Future: Automated CSV Import Endpoint

If you want to automate result uploads from your external program, we can add:

```rust
// POST /api/admin/import-results
// Body: CSV with columns: request_id, result_json
```

This would allow your external program to upload results via HTTP API.

**Let me know if you want this feature added!**

---

## Troubleshooting

### CSV Export Shows No Data

**Problem**: No pending requests in database

**Solution**:
```bash
# Check database
sqlite3 /Users/redradzn/desktop/YouMean/rust/youmean_data.db "SELECT COUNT(*) FROM request_queue WHERE status='pending';"

# If 0, submit a test request from umean.app
```

### Can't Access Admin Panel

**Problem**: Server not running or ngrok tunnel down

**Solution**:
```bash
# Restart server
bash /Users/redradzn/desktop/YouMean/start-youmean-server.sh

# Check ngrok URL in terminal output
```

### Results Not Showing on umean.app

**Problem**: Results saved with wrong format

**Solution**:
- Verify result_json matches expected format (see above)
- Check `status = 'completed'` in database
- Ensure Mind Selfie data structure is correct

---

## Summary

**Your CSV Workflow:**
1. 📊 Export pending requests from admin panel
2. 🔐 Process offline with your algorithms (MacBook or external program)
3. 💾 Import results back to database (manual_process.py or custom script)
4. ✅ Users retrieve results from umean.app

**Privacy Guarantee:**
- Only anonymous data exported
- Algorithms stay 100% private
- Processing happens offline on your machine
- Full control over when/how processing occurs

---

**Need help?** Check the other guides:
- `SECURITY_AND_PRIVACY.md` - Security architecture explained
- `PROCESSING_WORKFLOW.md` - Complete processing flow
- `MACBOOK_SERVER_GUIDE.md` - Server setup and management
