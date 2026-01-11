# ============================================================================
# YouMean Flutter Web - Dockerfile
# ============================================================================
# Uses Flutter 3.38.5 which includes Dart SDK 3.10.4+
# This matches the requirement in pubspec.yaml: sdk: ^3.10.4
# ============================================================================

# Use specific Flutter version with Dart 3.10.4+
FROM ghcr.io/cirruslabs/flutter:3.38.5

# Set working directory
WORKDIR /app

# Copy dependency files first (for better caching)
COPY pubspec.yaml pubspec.lock ./

# Enable web support and get dependencies
RUN flutter config --enable-web
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Accept API_URL as build argument (defaults to localhost for development)
ARG API_URL=http://localhost:3000

# Build Flutter web app for production with API URL
RUN flutter build web --release --web-renderer canvaskit --dart-define=API_URL=${API_URL}

# Expose port (Railway will assign PORT via env variable)
EXPOSE 8080

# Serve the built app using Python's simple HTTP server
# Railway will set the PORT environment variable dynamically
CMD sh -c "python3 -m http.server ${PORT:-8080} --directory build/web"
