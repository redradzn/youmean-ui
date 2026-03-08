use serde::{Deserialize, Serialize};

/// Request from user to submit their birth data for calculation
#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct SubmitRequest {
    pub birth_city: String,
    pub birth_date: String,       // YYYY-MM-DD format
    pub birth_time: Option<String>, // HH:MM format (optional if skipped)
    pub emotional_state: String,
    pub belief_science: bool,
    pub belief_god: bool,
    pub belief_spirituality: bool,
}

/// Response after submitting a request
#[derive(Debug, Serialize)]
pub struct SubmitResponse {
    pub success: bool,
    pub request_id: String,  // UUID for polling results
    pub message: String,
}

/// Status of a calculation request
#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum RequestStatus {
    Pending,   // Waiting for manual processing
    Processing, // Currently being calculated
    Completed,  // Done, results ready
    Failed,     // Error during calculation
}

impl RequestStatus {
    pub fn to_string(&self) -> String {
        match self {
            RequestStatus::Pending => "pending".to_string(),
            RequestStatus::Processing => "processing".to_string(),
            RequestStatus::Completed => "completed".to_string(),
            RequestStatus::Failed => "failed".to_string(),
        }
    }

    pub fn from_string(s: &str) -> Self {
        match s {
            "pending" => RequestStatus::Pending,
            "processing" => RequestStatus::Processing,
            "completed" => RequestStatus::Completed,
            "failed" => RequestStatus::Failed,
            _ => RequestStatus::Pending,
        }
    }
}

/// Database record for a calculation request
#[derive(Debug, Clone)]
pub struct RequestRecord {
    pub id: String,              // UUID
    pub birth_city: String,
    pub birth_date: String,
    pub birth_time: Option<String>,
    pub emotional_state: String,
    pub belief_science: bool,
    pub belief_god: bool,
    pub belief_spirituality: bool,
    pub status: RequestStatus,
    pub submitted_at: i64,       // Unix timestamp
    pub processed_at: Option<i64>,
    pub result_json: Option<String>, // JSON serialized result
    pub error_message: Option<String>,
}

/// Response when user polls for results
#[derive(Debug, Serialize)]
pub struct PollResponse {
    pub status: String,  // "pending", "processing", "completed", "failed"
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<ProbabilityResultResponse>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
}

/// Calculation result returned to user
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ProbabilityResultResponse {
    pub probability_score: f64,
    pub insights: Vec<String>,
    pub historical_correlations: Vec<String>,
    pub calculated_at: i64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub mind_selfie: Option<MindSelfieResult>,
}

/// Mind Selfie: Year-by-year analysis based on belief system
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct MindSelfieResult {
    pub belief_system: BeliefSystem,
    #[serde(default)]
    pub location: String,
    #[serde(default)]
    pub babylonian_date: String,
    #[serde(default)]
    pub years: Vec<YearData>,
    #[serde(default)]
    pub light_years: Vec<YearData>,
    #[serde(default)]
    pub psychology_years: Vec<YearData>,
    #[serde(default)]
    pub astronomy_years: Vec<YearData>,
    pub user_age: u32,
    pub total_years_available: u32,
}

/// Belief system determines the row labels
#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "lowercase")]
pub enum BeliefSystem {
    Science,      // Self Summary, Mental Health, Spark, Integration, Completion
    God,          // Self Summary, Inner Peace, Trust, Devotion, Unity
    Spirituality, // Self Summary, Inner Harmony, Motivation, Journey, Enlightenment
}

impl BeliefSystem {
    pub fn row_labels(&self) -> [&'static str; 5] {
        match self {
            BeliefSystem::Science => [
                "Self Summary",
                "Mental Health",
                "Spark",
                "Integration",
                "Completion",
            ],
            BeliefSystem::God => [
                "Self Summary",
                "Inner Peace",
                "Trust",
                "Devotion",
                "Unity",
            ],
            BeliefSystem::Spirituality => [
                "Self Summary",
                "Inner Harmony",
                "Motivation",
                "Journey",
                "Enlightenment",
            ],
        }
    }
}

/// Data for a specific year of life
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct YearData {
    pub age: u32,          // Age in that year (e.g., 18, 19, 20)
    pub row1: String,      // Self Summary (universal)
    pub row2: String,      // Mental Health / Inner Peace / Inner Harmony
    pub row3: String,      // Spark / Trust / Motivation
    pub row4: String,      // Integration / Devotion / Journey
    pub row5: String,      // Completion / Unity / Enlightenment
}

/// Admin view of pending requests
#[derive(Debug, Serialize)]
pub struct AdminRequestView {
    pub id: String,
    pub birth_city: String,
    pub birth_date: String,
    pub birth_time: Option<String>,
    pub emotional_state: String,
    pub belief_science: bool,
    pub belief_god: bool,
    pub belief_spirituality: bool,
    pub submitted_at: i64,
    pub status: String,
}

/// Request to manually process a calculation (from admin panel)
#[derive(Debug, Deserialize)]
pub struct ProcessRequest {
    pub request_id: String,
}

/// Response after processing
#[derive(Debug, Serialize)]
pub struct ProcessResponse {
    pub success: bool,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<ProbabilityResultResponse>,
}

/// Statistics response for admin panel
#[derive(Debug, Serialize)]
pub struct StatsResponse {
    pub total_requests: i32,
    pub pending_requests: i32,
    pub completed_today: i32,
    pub feedback_count: i32,
}

/// Request to submit feedback
#[derive(Debug, Deserialize)]
pub struct FeedbackRequest {
    pub message: String,
}

/// Response after submitting feedback
#[derive(Debug, Serialize)]
pub struct FeedbackResponse {
    pub success: bool,
    pub message: String,
}

/// Feedback item for admin list
#[derive(Debug, Serialize)]
pub struct FeedbackItem {
    pub id: String,
    pub message: String,
    pub submitted_at: i64,
}
