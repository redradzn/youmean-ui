pub mod handlers;
pub mod models;

use axum::{
    routing::{get, post},
    Router,
};
use std::sync::{Arc, Mutex};
use rusqlite::Connection;
use tower_http::cors::{CorsLayer, Any};
use tower_http::services::ServeDir;

/// Start the API server
pub async fn start_server(db: Connection, port: u16) -> Result<(), Box<dyn std::error::Error>> {
    // Wrap database connection in Arc<Mutex> for thread-safe sharing
    let db = Arc::new(Mutex::new(db));

    // Build router with all endpoints
    let app = Router::new()
        // Public API endpoints (for Flutter app)
        .route("/api/submit", post(handlers::submit_request))
        .route("/api/poll/:request_id", get(handlers::poll_results))
        .route("/api/health", get(handlers::health_check))

        // Admin API endpoints
        .route("/api/admin/pending", get(handlers::get_pending_requests))
        .route("/api/admin/stats", get(handlers::get_stats))
        .route("/api/admin/export-csv", get(handlers::export_all_csv))
        .route("/api/admin/import-csv", post(handlers::import_results_csv))
        .route("/api/admin/wipe-all", post(handlers::wipe_all_requests))

        // Feedback endpoints
        .route("/api/feedback", post(handlers::submit_feedback))
        .route("/api/admin/feedback", get(handlers::get_all_feedback))

        // Serve static admin panel
        .nest_service("/admin", ServeDir::new("admin_panel"))

        // Share database connection with all handlers
        .with_state(db)

        // Enable CORS for Flutter web app
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        );

    // Start server
    let addr = format!("127.0.0.1:{}", port);
    println!("🚀 YouMean API Server running on http://{}", addr);
    println!("📊 Admin panel: http://{}/admin", addr);
    println!("💚 Health check: http://{}/api/health", addr);

    let listener = tokio::net::TcpListener::bind(&addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
