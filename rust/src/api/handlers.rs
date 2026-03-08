use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
    response::IntoResponse,
    body::Bytes,
};
use std::sync::{Arc, Mutex};
use rusqlite::Connection;
use uuid::Uuid;
use chrono::Utc;

use crate::api::models::*;
use crate::database::{get_request, get_requests_by_status, insert_request, update_request_result};
use crate::{calculate_probability, UserInput};

pub type DbConnection = Arc<Mutex<Connection>>;

/// Handle user submission of birth data
pub async fn submit_request(
    State(db): State<DbConnection>,
    Json(req): Json<SubmitRequest>,
) -> impl IntoResponse {
    // Generate unique request ID
    let request_id = Uuid::new_v4().to_string();
    let now = Utc::now().timestamp();

    // Create request record
    let record = RequestRecord {
        id: request_id.clone(),
        birth_city: req.birth_city,
        birth_date: req.birth_date,
        birth_time: req.birth_time,
        emotional_state: req.emotional_state,
        belief_science: req.belief_science,
        belief_god: req.belief_god,
        belief_spirituality: req.belief_spirituality,
        status: RequestStatus::Pending,
        submitted_at: now,
        processed_at: None,
        result_json: None,
        error_message: None,
    };

    // Insert into database
    let db_lock = db.lock().unwrap();
    match insert_request(&db_lock, &record) {
        Ok(_) => {
            drop(db_lock);
            (
                StatusCode::OK,
                Json(SubmitResponse {
                    success: true,
                    request_id,
                    message: "Request queued for processing. You will receive results soon.".to_string(),
                }),
            )
        }
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(SubmitResponse {
                success: false,
                request_id: String::new(),
                message: format!("Error: {}", e),
            }),
        ),
    }
}

/// Handle polling for results
pub async fn poll_results(
    State(db): State<DbConnection>,
    Path(request_id): Path<String>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    match get_request(&db_lock, &request_id) {
        Ok(Some(record)) => {
            drop(db_lock);

            // Check status and return appropriate response
            match record.status {
                RequestStatus::Pending => (
                    StatusCode::OK,
                    Json(PollResponse {
                        status: "pending".to_string(),
                        result: None,
                        error: None,
                    }),
                ),
                RequestStatus::Processing => (
                    StatusCode::OK,
                    Json(PollResponse {
                        status: "processing".to_string(),
                        result: None,
                        error: None,
                    }),
                ),
                RequestStatus::Completed => {
                    // Parse result JSON
                    let result = if let Some(json_str) = record.result_json {
                        serde_json::from_str::<ProbabilityResultResponse>(&json_str).ok()
                    } else {
                        None
                    };

                    (
                        StatusCode::OK,
                        Json(PollResponse {
                            status: "completed".to_string(),
                            result,
                            error: None,
                        }),
                    )
                },
                RequestStatus::Failed => (
                    StatusCode::OK,
                    Json(PollResponse {
                        status: "failed".to_string(),
                        result: None,
                        error: record.error_message,
                    }),
                ),
            }
        }
        Ok(None) => (
            StatusCode::NOT_FOUND,
            Json(PollResponse {
                status: "not_found".to_string(),
                result: None,
                error: Some("Request ID not found".to_string()),
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(PollResponse {
                status: "error".to_string(),
                result: None,
                error: Some(format!("Database error: {}", e)),
            }),
        ),
    }
}

/// Admin: Get all pending requests
pub async fn get_pending_requests(
    State(db): State<DbConnection>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    match get_requests_by_status(&db_lock, &RequestStatus::Pending) {
        Ok(requests) => {
            drop(db_lock);

            let admin_views: Vec<AdminRequestView> = requests
                .into_iter()
                .map(|r| AdminRequestView {
                    id: r.id,
                    birth_city: r.birth_city,
                    birth_date: r.birth_date,
                    birth_time: r.birth_time,
                    emotional_state: r.emotional_state,
                    belief_science: r.belief_science,
                    belief_god: r.belief_god,
                    belief_spirituality: r.belief_spirituality,
                    submitted_at: r.submitted_at,
                    status: r.status.to_string(),
                })
                .collect();

            (StatusCode::OK, Json(admin_views))
        }
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(vec![]),
        ),
    }
}

/// Admin: Process a specific request
pub async fn process_request(
    State(db): State<DbConnection>,
    Json(req): Json<ProcessRequest>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    // Get the request
    let record = match get_request(&db_lock, &req.request_id) {
        Ok(Some(r)) => r,
        Ok(None) => {
            drop(db_lock);
            return (
                StatusCode::NOT_FOUND,
                Json(ProcessResponse {
                    success: false,
                    message: "Request not found".to_string(),
                    result: None,
                }),
            );
        }
        Err(e) => {
            drop(db_lock);
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ProcessResponse {
                    success: false,
                    message: format!("Database error: {}", e),
                    result: None,
                }),
            );
        }
    };

    drop(db_lock);

    // Run the calculation
    let user_input = UserInput {
        birth_city: record.birth_city.clone(),
        birth_date: record.birth_date.clone(),
        birth_time: record.birth_time.clone().unwrap_or_else(|| "12:00".to_string()),
        emotional_state: record.emotional_state.clone(),
    };

    match calculate_probability(user_input.clone()) {
        Ok(probability_result) => {
            // Generate Mind Selfie data
            let mind_selfie = crate::generate_mind_selfie(
                &record.birth_date,
                record.belief_science,
                record.belief_god,
                record.belief_spirituality,
                &user_input,
            ).ok();

            // Convert to response format
            let result_response = ProbabilityResultResponse {
                probability_score: probability_result.probability_score,
                insights: probability_result.insights,
                historical_correlations: probability_result.historical_correlations,
                calculated_at: Utc::now().timestamp(),
                mind_selfie,
            };

            // Serialize result
            let result_json = serde_json::to_string(&result_response).ok();

            // Update database
            let db_lock = db.lock().unwrap();
            if let Err(e) = update_request_result(
                &db_lock,
                &req.request_id,
                &RequestStatus::Completed,
                result_json,
                None,
            ) {
                drop(db_lock);
                return (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(ProcessResponse {
                        success: false,
                        message: format!("Failed to save result: {}", e),
                        result: None,
                    }),
                );
            }
            drop(db_lock);

            (
                StatusCode::OK,
                Json(ProcessResponse {
                    success: true,
                    message: "Calculation completed successfully".to_string(),
                    result: Some(result_response),
                }),
            )
        }
        Err(e) => {
            // Update database with error
            let db_lock = db.lock().unwrap();
            let _ = update_request_result(
                &db_lock,
                &req.request_id,
                &RequestStatus::Failed,
                None,
                Some(e.to_string()),
            );
            drop(db_lock);

            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ProcessResponse {
                    success: false,
                    message: format!("Calculation failed: {}", e),
                    result: None,
                }),
            )
        }
    }
}

/// Admin: Get statistics
pub async fn get_stats(State(db): State<DbConnection>) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    // Get total requests
    let total: i32 = db_lock
        .query_row("SELECT COUNT(*) FROM request_queue", [], |row| row.get(0))
        .unwrap_or(0);

    // Get pending count
    let pending: i32 = db_lock
        .query_row(
            "SELECT COUNT(*) FROM request_queue WHERE status = 'pending'",
            [],
            |row| row.get(0),
        )
        .unwrap_or(0);

    // Get completed today
    let today_start = chrono::Utc::now().date_naive().and_hms_opt(0, 0, 0).unwrap().and_utc().timestamp();
    let completed_today: i32 = db_lock
        .query_row(
            "SELECT COUNT(*) FROM request_queue WHERE status = 'completed' AND processed_at >= ?1",
            [today_start],
            |row| row.get(0),
        )
        .unwrap_or(0);

    // Get feedback count
    let feedback_count: i32 = db_lock
        .query_row("SELECT COUNT(*) FROM feedback", [], |row| row.get(0))
        .unwrap_or(0);

    drop(db_lock);

    use crate::api::models::StatsResponse;
    (
        StatusCode::OK,
        Json(StatsResponse {
            total_requests: total,
            pending_requests: pending,
            completed_today: completed_today,
            feedback_count,
        }),
    )
}

/// Health check endpoint
pub async fn health_check() -> impl IntoResponse {
    (StatusCode::OK, "OK")
}

/// Helper function to parse YYYY-MM-DD date format
fn parse_date(date_str: &str) -> Option<(String, String, String)> {
    let parts: Vec<&str> = date_str.split('-').collect();
    if parts.len() == 3 {
        Some((parts[0].to_string(), parts[1].to_string(), parts[2].to_string()))
    } else {
        None
    }
}

/// Helper function to convert 24-hour time to 12-hour AM/PM format
fn format_time_ampm(time_str: &str) -> String {
    // Parse HH:MM format
    let parts: Vec<&str> = time_str.split(':').collect();
    if parts.len() != 2 {
        return time_str.to_string(); // Return original if invalid
    }

    let hour: i32 = parts[0].parse().unwrap_or(0);
    let minute = parts[1];

    let (hour_12, period) = if hour == 0 {
        (12, "AM")
    } else if hour < 12 {
        (hour, "AM")
    } else if hour == 12 {
        (12, "PM")
    } else {
        (hour - 12, "PM")
    };

    format!("{}:{} {}", hour_12, minute, period)
}

/// Wipe all requests from database (for development)
pub async fn wipe_all_requests(
    State(db): State<DbConnection>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    match db_lock.execute("DELETE FROM request_queue", []) {
        Ok(deleted_count) => {
            drop(db_lock);
            (
                StatusCode::OK,
                Json(serde_json::json!({
                    "success": true,
                    "message": format!("Deleted {} requests", deleted_count)
                }))
            )
        }
        Err(e) => {
            drop(db_lock);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "success": false,
                    "message": format!("Error: {}", e)
                }))
            )
        }
    }
}

/// Export all requests as CSV
pub async fn export_all_csv(
    State(db): State<DbConnection>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    // Get ALL requests (not just pending)
    let query = "SELECT id, birth_city, birth_date, birth_time, emotional_state,
                        belief_science, belief_god, belief_spirituality, status, submitted_at
                 FROM request_queue
                 ORDER BY submitted_at DESC";

    let mut stmt = match db_lock.prepare(query) {
        Ok(s) => s,
        Err(e) => {
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                [("Content-Type", "text/plain"), ("Content-Disposition", "")],
                format!("Error: {}", e)
            );
        }
    };

    let rows = match stmt.query_map([], |row| {
        Ok((
            row.get::<_, String>(0)?,  // id
            row.get::<_, String>(1)?,  // birth_city
            row.get::<_, String>(2)?,  // birth_date
            row.get::<_, Option<String>>(3)?,  // birth_time
            row.get::<_, String>(4)?,  // emotional_state
            row.get::<_, bool>(5)?,    // belief_science
            row.get::<_, bool>(6)?,    // belief_god
            row.get::<_, bool>(7)?,    // belief_spirituality
            row.get::<_, String>(8)?,  // status
            row.get::<_, i64>(9)?,     // submitted_at
        ))
    }) {
        Ok(r) => r,
        Err(e) => {
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                [("Content-Type", "text/plain"), ("Content-Disposition", "")],
                format!("Error: {}", e)
            );
        }
    };

    // Collect all rows into a Vec before dropping the lock
    let mut collected_rows = Vec::new();
    for row_result in rows {
        if let Ok(row_data) = row_result {
            collected_rows.push(row_data);
        }
    }

    drop(stmt);
    drop(db_lock);

    // Build CSV with simplified headers (removed SUBMITTED)
    let mut csv = String::from("ID,TIME,DATE,PLACE,FEELINGS,SCIENCE,GOD,SPIRITUAL,STATUS\n");

    for (id, city, date, time, feelings, science, god, spiritual, status, _submitted) in collected_rows {
        // Convert date from YYYY-MM-DD to D/M/Y format
        let formatted_date = if let Some((y, m, d)) = parse_date(&date) {
            format!("{}/{}/{}", d, m, y)
        } else {
            date.clone() // Fallback to original if parsing fails
        };

        // Convert time from 24-hour to 12-hour AM/PM format
        let formatted_time = if let Some(t) = time {
            format_time_ampm(&t)
        } else {
            String::new()
        };

        csv.push_str(&format!(
            "\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",{},{},{},\"{}\"\n",
            id,
            formatted_time.replace("\"", "\"\""),
            formatted_date,
            city.replace("\"", "\"\""),
            feelings.replace("\"", "\"\""),
            if science { "1" } else { "0" },
            if god { "1" } else { "0" },
            if spiritual { "1" } else { "0" },
            status
        ));
    }

    (
        StatusCode::OK,
        [("Content-Type", "text/csv"), ("Content-Disposition", "attachment; filename=youmean_requests.csv")],
        csv
    )
}

/// Import results from CSV (supports TOAD Mind Selfie table format)
pub async fn import_results_csv(
    State(db): State<DbConnection>,
    body: Bytes,
) -> impl IntoResponse {
    // Convert bytes to string
    let csv_content = match String::from_utf8(body.to_vec()) {
        Ok(s) => s,
        Err(_) => {
            return (
                StatusCode::BAD_REQUEST,
                Json(serde_json::json!({
                    "success": false,
                    "message": "Invalid UTF-8 in CSV file"
                }))
            );
        }
    };

    if csv_content.is_empty() {
        return (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "success": false,
                "message": "No CSV data received"
            }))
        );
    }

    // Detect format: TOAD table or ID,RESULT_JSON
    let lines: Vec<&str> = csv_content.lines().collect();

    // Check for TOAD V2 format:
    // - New format: "REQUEST ID,<uuid>" on line 0
    // - Old format: "Request ID: <uuid>" on line 0
    // Or old TOAD V1 format (Mind Selfie on line 0)
    let first_line_upper = lines.get(0).map(|l| l.to_uppercase()).unwrap_or_default();
    let is_toad_v2 = lines.len() >= 3 && (
        first_line_upper.starts_with("REQUEST ID,") ||
        first_line_upper.starts_with("REQUEST ID:")
    );
    let is_toad_v1 = lines.len() >= 3 && lines[0].contains("Mind Selfie");

    if is_toad_v2 {
        // TOAD V2 format with Request ID
        return import_toad_v2_format(db, lines);
    } else if is_toad_v1 {
        // Old TOAD table format
        return import_toad_table_format(db, lines);
    } else {
        // ID,RESULT_JSON format
        return import_id_json_format(db, lines);
    }
}

/// Import TOAD Mind Selfie table format
fn import_toad_table_format(
    db: DbConnection,
    lines: Vec<&str>,
) -> (StatusCode, Json<serde_json::Value>) {
    use csv::ReaderBuilder;
    use std::io::Cursor;

    // Parse belief system from line 2
    let belief_system = if lines.len() > 1 {
        let belief_line = lines[1].to_uppercase();
        if belief_line.contains("SCIENCE") {
            "science"
        } else if belief_line.contains("GOD") {
            "god"
        } else if belief_line.contains("SPIRITUAL") {
            "spirituality"
        } else {
            "science"
        }
    } else {
        "science"
    };

    // Find where the CSV table starts (after blank lines)
    let table_start = lines.iter().position(|l| l.starts_with(',') || l.starts_with("\"")).unwrap_or(3);
    let table_lines = lines[table_start..].join("\n");

    // Parse CSV table
    let mut rdr = ReaderBuilder::new()
        .has_headers(true)
        .from_reader(Cursor::new(table_lines));

    let mut headers = Vec::new();
    let mut self_summary = Vec::new();
    let mut mental_health = Vec::new();
    let mut spark = Vec::new();
    let mut integration = Vec::new();
    let mut completion = Vec::new();

    // Read headers
    if let Ok(header_record) = rdr.headers() {
        headers = header_record.iter().map(|s| s.to_string()).collect();
    }

    // Read data rows
    let mut row_idx = 0;
    for result in rdr.records() {
        if let Ok(record) = result {
            let row: Vec<String> = record.iter().map(|s| s.to_string()).collect();
            match row_idx {
                0 => self_summary = row,
                1 => mental_health = row,
                2 => spark = row,
                3 => integration = row,
                4 => completion = row,
                _ => {}
            }
            row_idx += 1;
        }
    }

    // Build years array
    let mut years = Vec::new();
    for i in 1..headers.len() {
        let age_str = headers[i].replace("Age ", "").trim().to_string();
        if let Ok(age) = age_str.parse::<i32>() {
            years.push(serde_json::json!({
                "age": age,
                "row1": self_summary.get(i).unwrap_or(&String::new()),
                "row2": mental_health.get(i).unwrap_or(&String::new()),
                "row3": spark.get(i).unwrap_or(&String::new()),
                "row4": integration.get(i).unwrap_or(&String::new()),
                "row5": completion.get(i).unwrap_or(&String::new())
            }));
        }
    }

    let user_age = years.last()
        .and_then(|y| y.get("age"))
        .and_then(|a| a.as_i64())
        .unwrap_or(0) as i32;

    // Create Mind Selfie result
    let result = serde_json::json!({
        "probability_score": 0.15,
        "insights": [
            format!("Mind Selfie processed with {} perspective", belief_system),
            format!("Total of {} years analyzed", years.len())
        ],
        "historical_correlations": ["Historical data analyzed"],
        "calculated_at": Utc::now().timestamp(),
        "mind_selfie": {
            "belief_system": belief_system,
            "user_age": user_age,
            "total_years_available": years.len(),
            "years": years
        }
    });

    let result_json = serde_json::to_string(&result).unwrap();

    // Get first pending request to update
    let db_lock = db.lock().unwrap();
    let query = "SELECT id FROM request_queue WHERE status = 'pending' ORDER BY submitted_at ASC LIMIT 1";

    let request_id: Option<String> = db_lock.query_row(query, [], |row| row.get(0)).ok();

    if let Some(req_id) = request_id {
        match db_lock.execute(
            "UPDATE request_queue SET status = 'completed', result_json = ?, processed_at = ? WHERE id = ?",
            rusqlite::params![&result_json, Utc::now().timestamp(), &req_id]
        ) {
            Ok(_) => {
                drop(db_lock);
                (
                    StatusCode::OK,
                    Json(serde_json::json!({
                        "success": true,
                        "message": format!("Imported Mind Selfie for request {}", &req_id[..8]),
                        "updated": 1,
                        "errors": []
                    }))
                )
            }
            Err(e) => {
                drop(db_lock);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    Json(serde_json::json!({
                        "success": false,
                        "message": format!("Database error: {}", e),
                        "updated": 0,
                        "errors": []
                    }))
                )
            }
        }
    } else {
        drop(db_lock);
        (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "success": false,
                "message": "No pending requests found to import",
                "updated": 0,
                "errors": []
            }))
        )
    }
}

/// Import TOAD V2 format with Request ID, Location, Babylonian Date, and 3 modes (LIGHT, PSYCHOLOGY, ASTRONOMY)
fn import_toad_v2_format(
    db: DbConnection,
    lines: Vec<&str>,
) -> (StatusCode, Json<serde_json::Value>) {
    // Parse header section
    // Line 0: "REQUEST ID,<uuid>"
    let request_id = lines.get(0)
        .and_then(|l| {
            // Try "REQUEST ID,<uuid>" format first
            if l.contains(',') {
                let parts: Vec<&str> = l.splitn(2, ',').collect();
                if parts.len() == 2 && parts[0].to_uppercase().contains("REQUEST") {
                    return Some(parts[1].trim().to_string());
                }
            }
            // Fallback to "Request ID: <uuid>" format
            l.strip_prefix("Request ID:").map(|s| s.trim().to_string())
        })
        .unwrap_or_default();

    if request_id.is_empty() {
        return (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "success": false,
                "message": "No Request ID found in CSV"
            }))
        );
    }

    // Line 1: "LOCATION,\"<location>\""
    let location = lines.get(1)
        .and_then(|l| {
            if l.contains(',') {
                let parts: Vec<&str> = l.splitn(2, ',').collect();
                if parts.len() == 2 {
                    return Some(parts[1].trim().trim_matches('"').to_string());
                }
            }
            l.strip_prefix("Location:").map(|s| s.trim().trim_matches('"').to_string())
        })
        .unwrap_or_default();

    // Line 2: "BABYLONIAN DATE,\"<date>\""
    let babylonian_date = lines.get(2)
        .and_then(|l| {
            if l.contains(',') {
                let parts: Vec<&str> = l.splitn(2, ',').collect();
                if parts.len() == 2 {
                    return Some(parts[1].trim().trim_matches('"').to_string());
                }
            }
            l.strip_prefix("Babylonian Date:").map(|s| s.trim().trim_matches('"').to_string())
        })
        .unwrap_or_default();

    // Find MODE sections
    let mut light_start: Option<usize> = None;
    let mut psychology_start: Option<usize> = None;
    let mut astronomy_start: Option<usize> = None;

    for (i, line) in lines.iter().enumerate() {
        let upper = line.to_uppercase();
        if upper.starts_with("MODE,LIGHT") || upper.contains("MODE,LIGHT") {
            light_start = Some(i);
        } else if upper.starts_with("MODE,PSYCHOLOGY") || upper.contains("MODE,PSYCHOLOGY") {
            psychology_start = Some(i);
        } else if upper.starts_with("MODE,ASTRONOMY") || upper.contains("MODE,ASTRONOMY") {
            astronomy_start = Some(i);
        }
    }

    // Helper function to parse a MODE section
    fn parse_mode_section(lines: &[&str], start_idx: usize, end_idx: Option<usize>) -> Vec<serde_json::Value> {
        use csv::ReaderBuilder;
        use std::io::Cursor;

        let end = end_idx.unwrap_or(lines.len());

        // Find the ROW header line (contains "Age 0")
        let header_idx = (start_idx..end).find(|&i| {
            lines.get(i).map(|l| l.contains("Age 0")).unwrap_or(false)
        });

        let Some(header_idx) = header_idx else {
            return Vec::new();
        };

        // Collect lines from header to end of section (until blank line or next MODE)
        let mut section_lines = Vec::new();
        for i in header_idx..end {
            let line = lines.get(i).unwrap_or(&"");
            if line.trim().is_empty() || (i > header_idx && line.to_uppercase().starts_with("MODE,")) {
                break;
            }
            section_lines.push(*line);
        }

        if section_lines.is_empty() {
            return Vec::new();
        }

        let table_content = section_lines.join("\n");
        let mut rdr = ReaderBuilder::new()
            .has_headers(true)
            .flexible(true)
            .from_reader(Cursor::new(table_content));

        let mut headers: Vec<String> = Vec::new();
        let mut rows: Vec<Vec<String>> = Vec::new();

        if let Ok(header_record) = rdr.headers() {
            headers = header_record.iter().map(|s| s.to_string()).collect();
        }

        for result in rdr.records() {
            if let Ok(record) = result {
                rows.push(record.iter().map(|s| s.to_string()).collect());
            }
        }

        // Build years array
        let mut years = Vec::new();
        for i in 1..headers.len() {
            let age_str = headers[i].replace("Age ", "").trim().to_string();
            if let Ok(age) = age_str.parse::<i32>() {
                years.push(serde_json::json!({
                    "age": age,
                    "row1": rows.get(0).and_then(|r| r.get(i)).unwrap_or(&String::new()),
                    "row2": rows.get(1).and_then(|r| r.get(i)).unwrap_or(&String::new()),
                    "row3": rows.get(2).and_then(|r| r.get(i)).unwrap_or(&String::new()),
                    "row4": rows.get(3).and_then(|r| r.get(i)).unwrap_or(&String::new()),
                    "row5": rows.get(4).and_then(|r| r.get(i)).unwrap_or(&String::new())
                }));
            }
        }

        years
    }

    // Parse each mode section
    let light_years = if let Some(start) = light_start {
        parse_mode_section(&lines, start, psychology_start.or(astronomy_start))
    } else {
        Vec::new()
    };

    let psychology_years = if let Some(start) = psychology_start {
        parse_mode_section(&lines, start, astronomy_start)
    } else {
        light_years.clone() // Fallback to light years
    };

    let astronomy_years = if let Some(start) = astronomy_start {
        parse_mode_section(&lines, start, None)
    } else {
        light_years.clone() // Fallback to light years
    };

    let user_age = light_years.last()
        .or(psychology_years.last())
        .or(astronomy_years.last())
        .and_then(|y| y.get("age"))
        .and_then(|a| a.as_i64())
        .unwrap_or(0) as i32;

    let total_years = light_years.len().max(psychology_years.len()).max(astronomy_years.len());

    // Determine belief_system based on which modes have data
    let belief_system = "spirituality"; // Default, can be customized

    // Create Mind Selfie result with all three modes
    let result = serde_json::json!({
        "probability_score": 0.15,
        "insights": [
            format!("Mind Selfie processed with {} perspective", belief_system),
            format!("Total of {} years analyzed across 3 modes", total_years)
        ],
        "historical_correlations": ["Historical data analyzed"],
        "calculated_at": Utc::now().timestamp(),
        "mind_selfie": {
            "belief_system": belief_system,
            "location": location,
            "babylonian_date": babylonian_date,
            "user_age": user_age,
            "total_years_available": total_years,
            "light_years": light_years,
            "psychology_years": psychology_years,
            "astronomy_years": astronomy_years,
            "years": light_years.clone() // Legacy compatibility
        }
    });

    let result_json = serde_json::to_string(&result).unwrap();

    // Try to update the specific request ID first
    let db_lock = db.lock().unwrap();

    // First, try exact match with CSV's request ID
    let rows_updated = db_lock.execute(
        "UPDATE request_queue SET status = 'completed', result_json = ?, processed_at = ? WHERE id = ?",
        rusqlite::params![&result_json, Utc::now().timestamp(), &request_id]
    ).unwrap_or(0);

    if rows_updated > 0 {
        drop(db_lock);
        return (
            StatusCode::OK,
            Json(serde_json::json!({
                "success": true,
                "message": format!("Imported Mind Selfie for request {} ({} years, 3 modes)", &request_id[..8.min(request_id.len())], total_years),
                "updated": 1,
                "errors": []
            }))
        );
    }

    // If no exact match, try partial match (UUID might be truncated)
    let partial_match: Option<String> = db_lock.query_row(
        "SELECT id FROM request_queue WHERE id LIKE ? AND status = 'pending' LIMIT 1",
        rusqlite::params![format!("{}%", &request_id)],
        |row| row.get(0)
    ).ok();

    if let Some(matched_id) = partial_match {
        match db_lock.execute(
            "UPDATE request_queue SET status = 'completed', result_json = ?, processed_at = ? WHERE id = ?",
            rusqlite::params![&result_json, Utc::now().timestamp(), &matched_id]
        ) {
            Ok(rows) if rows > 0 => {
                drop(db_lock);
                return (
                    StatusCode::OK,
                    Json(serde_json::json!({
                        "success": true,
                        "message": format!("Imported Mind Selfie for request {} ({} years, 3 modes)", &matched_id[..8.min(matched_id.len())], total_years),
                        "updated": 1,
                        "errors": []
                    }))
                );
            }
            _ => {}
        }
    }

    // Fallback: use the first pending request
    let first_pending: Option<String> = db_lock.query_row(
        "SELECT id FROM request_queue WHERE status = 'pending' ORDER BY submitted_at ASC LIMIT 1",
        [],
        |row| row.get(0)
    ).ok();

    if let Some(pending_id) = first_pending {
        match db_lock.execute(
            "UPDATE request_queue SET status = 'completed', result_json = ?, processed_at = ? WHERE id = ?",
            rusqlite::params![&result_json, Utc::now().timestamp(), &pending_id]
        ) {
            Ok(rows) if rows > 0 => {
                drop(db_lock);
                return (
                    StatusCode::OK,
                    Json(serde_json::json!({
                        "success": true,
                        "message": format!("Imported Mind Selfie for request {} (auto-assigned, {} years, 3 modes)", &pending_id[..8.min(pending_id.len())], total_years),
                        "updated": 1,
                        "errors": []
                    }))
                );
            }
            _ => {}
        }
    }

    drop(db_lock);
    (
        StatusCode::BAD_REQUEST,
        Json(serde_json::json!({
            "success": false,
            "message": "No pending requests found to import",
            "updated": 0,
            "errors": []
        }))
    )
}

/// Import ID,RESULT_JSON format
fn import_id_json_format(
    db: DbConnection,
    lines: Vec<&str>,
) -> (StatusCode, Json<serde_json::Value>) {
    if lines.len() < 2 {
        return (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "success": false,
                "message": "CSV file is empty or has no data rows"
            }))
        );
    }

    let mut updated_count = 0;
    let mut errors = Vec::new();
    let db_lock = db.lock().unwrap();

    for (index, line) in lines.iter().skip(1).enumerate() {
        let parts: Vec<&str> = line.splitn(2, ',').collect();

        if parts.len() < 2 {
            errors.push(format!("Row {}: Invalid format", index + 2));
            continue;
        }

        let request_id = parts[0].trim().trim_matches('"');
        let mut result_json = parts[1].trim().trim_matches('"').to_string();
        result_json = result_json.replace("\"\"", "\"");

        if serde_json::from_str::<serde_json::Value>(&result_json).is_err() {
            errors.push(format!("Row {}: Invalid JSON for ID {}", index + 2, request_id));
            continue;
        }

        match db_lock.execute(
            "UPDATE request_queue SET status = 'completed', result_json = ?, processed_at = ? WHERE id = ?",
            rusqlite::params![&result_json, Utc::now().timestamp(), request_id]
        ) {
            Ok(count) => {
                if count > 0 {
                    updated_count += 1;
                } else {
                    errors.push(format!("Row {}: Request ID {} not found", index + 2, request_id));
                }
            }
            Err(e) => {
                errors.push(format!("Row {}: Database error - {}", index + 2, e));
            }
        }
    }

    drop(db_lock);

    (
        StatusCode::OK,
        Json(serde_json::json!({
            "success": updated_count > 0,
            "message": format!("Updated {} requests", updated_count),
            "updated": updated_count,
            "errors": errors
        }))
    )
}

/// Submit user feedback
pub async fn submit_feedback(
    State(db): State<DbConnection>,
    Json(req): Json<FeedbackRequest>,
) -> impl IntoResponse {
    let id = Uuid::new_v4().to_string();
    let now = Utc::now().timestamp();

    let db_lock = db.lock().unwrap();
    match db_lock.execute(
        "INSERT INTO feedback (id, message, submitted_at) VALUES (?1, ?2, ?3)",
        rusqlite::params![id, req.message, now],
    ) {
        Ok(_) => {
            drop(db_lock);
            (
                StatusCode::OK,
                Json(FeedbackResponse {
                    success: true,
                    message: "Feedback submitted successfully".to_string(),
                }),
            )
        }
        Err(e) => {
            drop(db_lock);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(FeedbackResponse {
                    success: false,
                    message: format!("Error: {}", e),
                }),
            )
        }
    }
}

/// Admin: Get all feedback
pub async fn get_all_feedback(
    State(db): State<DbConnection>,
) -> impl IntoResponse {
    let db_lock = db.lock().unwrap();

    let result = (|| -> Result<Vec<FeedbackItem>, rusqlite::Error> {
        let mut stmt = db_lock.prepare(
            "SELECT id, message, submitted_at FROM feedback ORDER BY submitted_at DESC"
        )?;

        let items = stmt.query_map([], |row| {
            Ok(FeedbackItem {
                id: row.get(0)?,
                message: row.get(1)?,
                submitted_at: row.get(2)?,
            })
        })?;

        Ok(items.filter_map(|r| r.ok()).collect())
    })();

    drop(db_lock);

    match result {
        Ok(feedback) => (StatusCode::OK, Json(feedback)),
        Err(_) => (StatusCode::INTERNAL_SERVER_ERROR, Json(vec![])),
    }
}
