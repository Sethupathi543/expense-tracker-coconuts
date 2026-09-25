#!/bin/bash
set -e

echo "===> Setting up Flutter SDK..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi
export PATH="$PATH:$(pwd)/flutter/bin"

echo "===> Checking Flutter version..."
flutter --version

echo "===> Building Frontend for Web..."
cd frontend
flutter config --enable-web
flutter pub get
flutter build web --release

echo "===> Build completed successfully!"
