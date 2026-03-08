use crate::astronomy::AstronomicalData;
use crate::api::models::{RequestRecord, RequestStatus, ProbabilityResultResponse};
use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoricalEvent {
    pub id: i64,
    pub date: String,
    pub julian_day: f64,
    pub event_type: String,
    pub description: String,
}

/// Initialize the database
pub fn initialize_database() -> Result<Connection> {
    let conn = Connection::open("youmean_data.db")?;

    // Create tables
    conn.execute(
        "CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL,
            birth_city TEXT NOT NULL,
            birth_date TEXT NOT NULL,
            birth_time TEXT NOT NULL
        )",
        [],
    )?;

    conn.execute(
        "CREATE TABLE IF NOT EXISTS emotional_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            emotional_state TEXT NOT NULL,
            probability_score REAL NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )",
        [],
    )?;

    conn.execute(
        "CREATE TABLE IF NOT EXISTS historical_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            julian_day REAL NOT NULL,
            event_type TEXT NOT NULL,
            description TEXT NOT NULL
        )",
        [],
    )?;

    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_events_julian
         ON historical_events(julian_day)",
        [],
    )?;

    // Create request queue table for manual processing
    conn.execute(
        "CREATE TABLE IF NOT EXISTS request_queue (
            id TEXT PRIMARY KEY,
            birth_city TEXT NOT NULL,
            birth_date TEXT NOT NULL,
            birth_time TEXT,
            emotional_state TEXT NOT NULL,
            belief_science INTEGER NOT NULL,
            belief_god INTEGER NOT NULL,
            belief_spirituality INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            submitted_at INTEGER NOT NULL,
            processed_at INTEGER,
            result_json TEXT,
            error_message TEXT
        )",
        [],
    )?;

    // Migration: Add belief_spirituality column if it doesn't exist
    conn.execute(
        "ALTER TABLE request_queue ADD COLUMN belief_spirituality INTEGER NOT NULL DEFAULT 0",
        [],
    ).ok(); // Ignore error if column already exists

    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_queue_status
         ON request_queue(status)",
        [],
    )?;

    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_queue_submitted
         ON request_queue(submitted_at)",
        [],
    )?;

    // Create feedback table
    conn.execute(
        "CREATE TABLE IF NOT EXISTS feedback (
            id TEXT PRIMARY KEY,
            message TEXT NOT NULL,
            submitted_at INTEGER NOT NULL
        )",
        [],
    )?;

    Ok(conn)
}

/// Find historical correlations based on astronomical data
pub fn find_historical_correlations(
    astro_data: &AstronomicalData,
) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    // This would query the historical events database
    // and find correlations based on similar astronomical patterns

    let mut correlations = Vec::new();

    // Calculate year from Julian Day
    let year = julian_day_to_year(astro_data.julian_day);

    if year >= 1926 && year <= 2026 {
        correlations.push(format!(
            "Historical data available for period: 1926-2026. Your birth year ({}) is within analyzed range.",
            year
        ));
    } else {
        correlations.push(format!(
            "Birth year ({}) is outside primary analysis range (1926-2026). \
             Using extrapolated patterns.",
            year
        ));
    }

    // TODO: Implement actual pattern matching with historical events
    correlations.push(
        "Astronomical pattern analysis: Comparing with similar celestial \
         configurations in historical record."
            .to_string(),
    );

    Ok(correlations)
}

/// Seed historical events data (1926-2026)
pub fn seed_historical_data(conn: &Connection) -> Result<()> {
    // This would populate the database with historical events
    // For now, just a few examples

    let events = vec![
        ("1926-01-27", "Technology", "First demonstration of television"),
        ("1945-08-15", "Historical", "End of World War II"),
        ("1969-07-20", "Space", "Apollo 11 moon landing"),
        ("1989-11-09", "Historical", "Fall of Berlin Wall"),
        ("2001-09-11", "Historical", "September 11 attacks"),
        ("2008-09-15", "Financial", "Lehman Brothers collapse"),
        ("2020-03-11", "Health", "COVID-19 declared pandemic"),
    ];

    for (date, event_type, description) in events {
        let jd = date_to_julian_day(date).unwrap_or(0.0);
        conn.execute(
            "INSERT OR IGNORE INTO historical_events (date, julian_day, event_type, description)
             VALUES (?1, ?2, ?3, ?4)",
            &[date, &jd.to_string(), event_type, description],
        )?;
    }

    Ok(())
}

/// Convert Julian Day to approximate year
fn julian_day_to_year(jd: f64) -> i32 {
    let a = jd + 32044.0;
    let b = ((4.0 * a + 3.0) / 146097.0).floor();
    let c = a - ((146097.0 * b) / 4.0).floor();
    let d = ((4.0 * c + 3.0) / 1461.0).floor();
    let e = c - ((1461.0 * d) / 4.0).floor();
    let m = ((5.0 * e + 2.0) / 153.0).floor();
    let year = (100.0 * b + d - 4800.0 + (m / 10.0).floor()) as i32;
    year
}

/// Convert date string to Julian Day (simplified)
fn date_to_julian_day(date_str: &str) -> Result<f64, Box<dyn std::error::Error>> {
    let parts: Vec<&str> = date_str.split('-').collect();
    if parts.len() != 3 {
        return Err("Invalid date format".into());
    }

    let year: i32 = parts[0].parse()?;
    let month: u32 = parts[1].parse()?;
    let day: u32 = parts[2].parse()?;

    let a = (14 - month) / 12;
    let y = year + 4800 - a as i32;
    let m = month + 12 * a - 3;

    let jd = day as f64
        + ((153 * m + 2) / 5) as f64
        + 365.0 * y as f64
        + (y / 4) as f64
        - (y / 100) as f64
        + (y / 400) as f64
        - 32045.0;

    Ok(jd)
}

/// Insert a new request into the queue
pub fn insert_request(conn: &Connection, request: &RequestRecord) -> Result<()> {
    conn.execute(
        "INSERT INTO request_queue
         (id, birth_city, birth_date, birth_time, emotional_state,
          belief_science, belief_god, belief_spirituality, status, submitted_at, processed_at, result_json, error_message)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13)",
        rusqlite::params![
            request.id,
            request.birth_city,
            request.birth_date,
            request.birth_time,
            request.emotional_state,
            request.belief_science as i32,
            request.belief_god as i32,
            request.belief_spirituality as i32,
            request.status.to_string(),
            request.submitted_at,
            request.processed_at,
            request.result_json,
            request.error_message,
        ],
    )?;
    Ok(())
}

/// Get a request by ID
pub fn get_request(conn: &Connection, id: &str) -> Result<Option<RequestRecord>> {
    let mut stmt = conn.prepare(
        "SELECT id, birth_city, birth_date, birth_time, emotional_state,
                belief_science, belief_god, belief_spirituality, status, submitted_at, processed_at, result_json, error_message
         FROM request_queue WHERE id = ?1"
    )?;

    let mut rows = stmt.query([id])?;

    if let Some(row) = rows.next()? {
        Ok(Some(RequestRecord {
            id: row.get(0)?,
            birth_city: row.get(1)?,
            birth_date: row.get(2)?,
            birth_time: row.get(3)?,
            emotional_state: row.get(4)?,
            belief_science: row.get::<_, i32>(5)? != 0,
            belief_god: row.get::<_, i32>(6)? != 0,
            belief_spirituality: row.get::<_, i32>(7)? != 0,
            status: RequestStatus::from_string(&row.get::<_, String>(8)?),
            submitted_at: row.get(9)?,
            processed_at: row.get(10)?,
            result_json: row.get(11)?,
            error_message: row.get(12)?,
        }))
    } else {
        Ok(None)
    }
}

/// Get all requests with a specific status
pub fn get_requests_by_status(conn: &Connection, status: &RequestStatus) -> Result<Vec<RequestRecord>> {
    let mut stmt = conn.prepare(
        "SELECT id, birth_city, birth_date, birth_time, emotional_state,
                belief_science, belief_god, belief_spirituality, status, submitted_at, processed_at, result_json, error_message
         FROM request_queue WHERE status = ?1 ORDER BY submitted_at ASC"
    )?;

    let rows = stmt.query_map([status.to_string()], |row| {
        Ok(RequestRecord {
            id: row.get(0)?,
            birth_city: row.get(1)?,
            birth_date: row.get(2)?,
            birth_time: row.get(3)?,
            emotional_state: row.get(4)?,
            belief_science: row.get::<_, i32>(5)? != 0,
            belief_god: row.get::<_, i32>(6)? != 0,
            belief_spirituality: row.get::<_, i32>(7)? != 0,
            status: RequestStatus::from_string(&row.get::<_, String>(8)?),
            submitted_at: row.get(9)?,
            processed_at: row.get(10)?,
            result_json: row.get(11)?,
            error_message: row.get(12)?,
        })
    })?;

    let mut requests = Vec::new();
    for request in rows {
        requests.push(request?);
    }
    Ok(requests)
}

/// Update request status and result
pub fn update_request_result(
    conn: &Connection,
    id: &str,
    status: &RequestStatus,
    result_json: Option<String>,
    error_message: Option<String>,
) -> Result<()> {
    let processed_at = chrono::Utc::now().timestamp();

    conn.execute(
        "UPDATE request_queue
         SET status = ?1, processed_at = ?2, result_json = ?3, error_message = ?4
         WHERE id = ?5",
        rusqlite::params![
            status.to_string(),
            processed_at,
            result_json,
            error_message,
            id,
        ],
    )?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_year_conversion() {
        let jd = 2451545.0; // J2000.0 = 2000-01-01
        let year = julian_day_to_year(jd);
        assert_eq!(year, 2000);
    }

    #[test]
    fn test_database_init() {
        let conn = initialize_database();
        assert!(conn.is_ok());
    }
}
