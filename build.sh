#!/bin/bash
set -e

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

echo ">>> Installing Flutter ($FLUTTER_CHANNEL)..."
git clone https://github.com/flutter/flutter.git \
  --depth 1 -b "$FLUTTER_CHANNEL" "$HOME/flutter"

export PATH="$PATH:$HOME/flutter/bin"

echo ">>> Flutter version:"
flutter --version

echo ">>> Fetching dependencies..."
flutter pub get

echo ">>> Building Flutter Web..."
flutter build web --release --base-href "/"

echo ">>> Build complete. Output in build/web/"
