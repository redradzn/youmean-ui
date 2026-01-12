#!/bin/bash
# ============================================================================
# Netlify Build Script for YouMean Flutter Web
# ============================================================================
set -e

echo "🚀 Starting YouMean Flutter build for Netlify..."

# Install Flutter if not present
if [ ! -d "$HOME/flutter" ]; then
  echo "📦 Installing Flutter..."
  cd $HOME
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$HOME/flutter/bin:$PATH"
  flutter doctor
else
  echo "✅ Flutter already installed"
  export PATH="$HOME/flutter/bin:$PATH"
fi

# Verify Flutter version
echo "📊 Flutter version:"
flutter --version

# Navigate to project
cd $NETLIFY_BUILD_BASE

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
