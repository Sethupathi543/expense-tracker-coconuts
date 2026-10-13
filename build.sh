#!/bin/bash
set -e

echo "===> Setting up Flutter SDK..."

if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "===> Checking Flutter version..."
flutter --version

echo "===> Checking API_URL environment variable..."

if [ -z "$API_URL" ]; then
    echo "ERROR: API_URL environment variable is not set!"
    exit 1
fi

echo "API_URL is configured successfully."

echo "===> Setting up Flutter web..."
cd frontend

flutter config --enable-web

echo "===> Getting Flutter dependencies..."
flutter pub get

echo "===> Building Flutter web application..."
flutter build web --release --dart-define="API_URL=${API_URL}"

echo "===> Build completed successfully!"