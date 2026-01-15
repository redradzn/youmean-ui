#!/usr/bin/env python3
"""
Convert TOAD Mind Selfie CSV to YouMean import format
"""
import csv
import json
import sys
from datetime import datetime

def parse_toad_csv(toad_csv_path):
    """Parse TOAD Mind Selfie CSV and convert to JSON"""

    with open(toad_csv_path, 'r') as f:
        lines = f.readlines()

    # Find the belief system from line 2
    belief_line = lines[1].strip()
    if "SCIENCE" in belief_line:
        belief_system = "science"
    elif "GOD" in belief_line:
        belief_system = "god"
    elif "SPIRITUALITY" in belief_line:
        belief_system = "spirituality"
    else:
        belief_system = "science"  # default

    # Parse the CSV table (starts at line 4)
    csv_reader = csv.reader(lines[3:])
    rows = list(csv_reader)

    if len(rows) < 5:
        raise ValueError("Invalid TOAD CSV format - need at least 5 rows")

    # Row 0 is header with ages
    age_headers = rows[0][1:]  # Skip first column

    # Extract row data
    self_summary_row = rows[1][1:]
    mental_health_row = rows[2][1:]
    spark_row = rows[3][1:]
    integration_row = rows[4][1:]
    completion_row = rows[5][1:]

    # Build years array
    years = []
    for i, age_header in enumerate(age_headers):
        if not age_header:
            continue

        # Extract age number
        age = int(age_header.replace("Age ", ""))

        years.append({
            "age": age,
            "row1": self_summary_row[i] if i < len(self_summary_row) else "",
            "row2": mental_health_row[i] if i < len(mental_health_row) else "",
            "row3": spark_row[i] if i < len(spark_row) else "",
            "row4": integration_row[i] if i < len(integration_row) else "",
            "row5": completion_row[i] if i < len(completion_row) else ""
        })

    # Calculate user age (last age in the list)
    user_age = years[-1]["age"] if years else 0

    # Create Mind Selfie result
    result = {
        "probability_score": 0.15,  # Default value
        "insights": [
            f"Mind Selfie processed with {belief_system} perspective",
            f"Total of {len(years)} years analyzed"
        ],
        "historical_correlations": [
            "Historical data analyzed for birth period"
        ],
        "calculated_at": int(datetime.now().timestamp()),
        "mind_selfie": {
            "belief_system": belief_system,
            "user_age": user_age,
            "total_years_available": len(years),
            "years": years
        }
    }

    return result

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 convert_toad_to_import.py <toad_csv> <request_id>")
        print("\nExample:")
        print("  python3 convert_toad_to_import.py toad_results.csv b1691a87-5ca8-41be-99a6-169da9b27100")
        sys.exit(1)

    toad_csv_path = sys.argv[1]
    request_id = sys.argv[2]

    print(f"🔮 Converting TOAD CSV to import format...")
    print(f"   Input: {toad_csv_path}")
    print(f"   Request ID: {request_id}\n")

    # Parse TOAD CSV
    result = parse_toad_csv(toad_csv_path)

    # Create import CSV
    output_file = f"import_{request_id[:8]}.csv"
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['ID', 'RESULT_JSON'])
        writer.writerow([request_id, json.dumps(result)])

    print(f"✅ Created import CSV: {output_file}")
    print(f"   Belief System: {result['mind_selfie']['belief_system']}")
    print(f"   User Age: {result['mind_selfie']['user_age']}")
    print(f"   Years: {len(result['mind_selfie']['years'])}")
    print(f"\n📥 Now upload this file in admin panel!")

if __name__ == "__main__":
    main()
