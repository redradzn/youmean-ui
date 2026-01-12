#!/bin/bash
# ============================================================================
# Netlify Build Script for YouMean Flutter Web
# ============================================================================
set -e

echo "🚀 Starting YouMean Flutter build for Netlify..."

# Save the project root directory
PROJECT_ROOT="${PWD}"
echo "📁 Project root: ${PROJECT_ROOT}"

# Verify pubspec.yaml exists
if [ ! -f "${PROJECT_ROOT}/pubspec.yaml" ]; then
  echo "❌ ERROR: pubspec.yaml not found in ${PROJECT_ROOT}"
  exit 1
fi
echo "✅ Found pubspec.yaml"

# Install Flutter if not present
if [ ! -d "$HOME/flutter" ]; then
  echo "📦 Installing Flutter..."
  cd "$HOME"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$HOME/flutter/bin:$PATH"

  # Return to project directory
  cd "${PROJECT_ROOT}"

  flutter doctor
else
  echo "✅ Flutter already installed"
  export PATH="$HOME/flutter/bin:$PATH"
fi

# Make sure we're in the project root
cd "${PROJECT_ROOT}"
echo "📍 Current directory: ${PWD}"

# Verify Flutter version
echo "📊 Flutter version:"
flutter --version

# Enable web support
echo "🌐 Enabling Flutter web..."
flutter config --enable-web

# Get dependencies
echo "📚 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
if [ -n "$API_URL" ]; then
  echo "🔗 Using API_URL: $API_URL"
  flutter build web --release --base-href=/ --dart-define=API_URL=$API_URL
else
  echo "🔗 Using default API_URL (localhost:3000)"
  flutter build web --release --base-href=/
fi

echo "✅ Build complete! Output in build/web/"
ls -la build/web/ | head -10
