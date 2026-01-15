# CSV Import Format for YouMean Results

## Overview

After processing requests offline in your "umean toad" program, you can upload the results back to YouMean using the **Import CSV** button in the admin panel.

---

## CSV Format

The import CSV must have exactly 2 columns:

```csv
ID,RESULT_JSON
"request-id-here","{\"probability_score\":0.15,\"insights\":[...],\"mind_selfie\":{...}}"
```

### Column Descriptions:

1. **ID**: The request ID from the exported CSV
2. **RESULT_JSON**: The complete Mind Selfie result as JSON (escaped and in quotes)

---

## Mind Selfie JSON Structure

The `RESULT_JSON` column must contain a JSON object with this exact structure:

```json
{
  "probability_score": 0.15,
  "insights": [
    "Astronomical analysis complete for Birth City",
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
      {
        "age": 1,
        "row1": "Early Development",
        "row2": "Moon square Mercury indicates communication challenges.",
        "row3": "85% activation",
        "row4": "90% synthesis",
        "row5": "88% understanding"
      }
      // ... more years
    ]
  }
}
```

### Required Fields:

- `probability_score` (number): 0.0 to 1.0
- `insights` (array of strings): Analysis insights
- `historical_correlations` (array of strings): Historical patterns
- `calculated_at` (integer): Unix timestamp
- `mind_selfie` (object):
  - `belief_system` (string): "science", "god", or "spirituality"
  - `user_age` (integer): Current age of user
  - `total_years_available` (integer): Total years in the dataset
  - `years` (array of objects): Year-by-year analysis
    - `age` (integer): Age for this year
    - `row1` (string): Self Summary
    - `row2` (string): Mental/Emotional state description
    - `row3` (string): Activation percentage
    - `row4` (string): Synthesis percentage
    - `row5` (string): Understanding percentage

---

## Example: Complete Import CSV

```csv
ID,RESULT_JSON
"1f08e619-3cf2-4130-a276-f718d61907c9","{\"probability_score\":0.13,\"insights\":[\"Astronomical analysis complete for Gliwice, Poland\",\"Birth data processed: 2002-02-20\"],\"historical_correlations\":[\"Historical data available for period: 1926-2026\"],\"calculated_at\":1768300000,\"mind_selfie\":{\"belief_system\":\"science\",\"user_age\":22,\"total_years_available\":36,\"years\":[{\"age\":0,\"row1\":\"Foundation Building\",\"row2\":\"No significant transits.\",\"row3\":\"100% activation\",\"row4\":\"100% synthesis\",\"row5\":\"93% understanding\"},{\"age\":1,\"row1\":\"Early Development\",\"row2\":\"Moon square Mercury.\",\"row3\":\"85% activation\",\"row4\":\"90% synthesis\",\"row5\":\"88% understanding\"}]}}"
```

**Note**: The JSON must be escaped and enclosed in double quotes!

---

## Workflow Example

### Step 1: Export Request from Admin Panel

Click "📊 Export as CSV" on a request card:

```csv
ID,TIME,DATE,PLACE,FEELINGS,SCIENCE,GOD,SPIRITUAL,STATUS,SUBMITTED
"1f08e619-3cf2-4130-a276-f718d61907c9","15:25","2002-02-20","Gliwice, Poland","Okay",1,0,0,"pending",1768298431
```

### Step 2: Process Offline

Use the exported data in your "umean toad" program to generate the Mind Selfie.

Your program should:
1. Read the CSV
2. Extract birth data (TIME, DATE, PLACE, FEELINGS, belief flags)
3. Run your proprietary algorithms
4. Generate Mind Selfie JSON
5. Create import CSV with ID and result JSON

### Step 3: Create Import CSV

Format: `ID,RESULT_JSON`

```csv
ID,RESULT_JSON
"1f08e619-3cf2-4130-a276-f718d61907c9","{\"probability_score\":0.13,\"insights\":[\"Analysis complete\"],\"historical_correlations\":[\"Data processed\"],\"calculated_at\":1768300000,\"mind_selfie\":{\"belief_system\":\"science\",\"user_age\":22,\"total_years_available\":36,\"years\":[{\"age\":0,\"row1\":\"Foundation\",\"row2\":\"Details\",\"row3\":\"100%\",\"row4\":\"100%\",\"row5\":\"93%\"}]}}"
```

### Step 4: Import via Admin Panel

1. Open admin panel: `https://your-ngrok-url.ngrok-free.dev/admin`
2. Click **"📥 Import CSV"** button
3. Select your import CSV file
4. Click Open
5. See success message with update count

### Step 5: User Retrieves Results

User goes to umean.app:
1. Enters their request ID
2. Clicks "Check Results Now"
3. Sees their Mind Selfie!

---

## Important Notes

### CSV Escaping

Since the result JSON contains commas and quotes, it MUST be properly escaped:

**Correct**:
```csv
ID,RESULT_JSON
"abc123","{\"probability_score\":0.15,\"insights\":[\"test\"]}"
```

**Wrong** (unescaped):
```csv
ID,RESULT_JSON
abc123,{"probability_score":0.15,"insights":["test"]}
```

### Error Handling

The import will:
- ✅ Update all valid rows
- ⚠️ Skip rows with invalid JSON
- ⚠️ Skip rows with non-existent request IDs
- 📊 Show summary: "Updated X requests" + list of errors

---

## Testing

### Test with a Sample Request

1. **Create test request** from umean.app
2. **Export it** from admin panel (get request ID)
3. **Create test import CSV**:

```csv
ID,RESULT_JSON
"your-request-id-here","{\"probability_score\":0.99,\"insights\":[\"Test result\"],\"historical_correlations\":[\"Test correlation\"],\"calculated_at\":1768300000,\"mind_selfie\":{\"belief_system\":\"science\",\"user_age\":25,\"total_years_available\":5,\"years\":[{\"age\":25,\"row1\":\"Test Summary\",\"row2\":\"Test State\",\"row3\":\"100%\",\"row4\":\"100%\",\"row5\":\"100%\"}]}}"
```

4. **Import via admin panel**
5. **Check results** on umean.app with the request ID

---

## Troubleshooting

### "Invalid JSON" Error

**Problem**: JSON not properly formatted or escaped

**Solution**:
- Ensure JSON is valid (test with `json.loads()` in Python)
- Escape all quotes and special characters
- Wrap entire JSON in double quotes in CSV

### "Request ID not found" Error

**Problem**: ID doesn't exist in database

**Solution**:
- Double-check the request ID matches exactly
- Make sure request was actually submitted to umean.app
- Check admin panel for list of request IDs

### Import Button Does Nothing

**Problem**: File input might be empty

**Solution**:
- Make sure you selected a .csv file
- Check browser console for errors
- Try clicking Import CSV button again

---

## Python Script to Generate Import CSV

Here's a helper script to convert your processed results into the import format:

```python
import json
import csv

def create_import_csv(request_id, mind_selfie_result, output_file):
    """
    Create import CSV from processed Mind Selfie result

    Args:
        request_id: The request ID from export
        mind_selfie_result: Dict with Mind Selfie data
        output_file: Path to output CSV file
    """
    # Convert result to JSON string
    result_json = json.dumps(mind_selfie_result)

    # Write CSV
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['ID', 'RESULT_JSON'])
        writer.writerow([request_id, result_json])

    print(f"✅ Import CSV created: {output_file}")

# Example usage:
result = {
    "probability_score": 0.15,
    "insights": ["Analysis complete"],
    "historical_correlations": ["Data processed"],
    "calculated_at": 1768300000,
    "mind_selfie": {
        "belief_system": "science",
        "user_age": 22,
        "total_years_available": 36,
        "years": [
            {
                "age": 0,
                "row1": "Foundation Building",
                "row2": "No significant transits.",
                "row3": "100% activation",
                "row4": "100% synthesis",
                "row5": "93% understanding"
            }
        ]
    }
}

create_import_csv("your-request-id", result, "import_results.csv")
```

---

## Summary

Your complete offline workflow:

1. **Export** → Click "📊 Export as CSV" on request card
2. **Process** → Run your "umean toad" program offline
3. **Format** → Create import CSV with ID,RESULT_JSON
4. **Import** → Click "📥 Import CSV" in admin panel
5. **Verify** → User checks results on umean.app

**All processing happens 100% offline on your MacBook!** 🔒
