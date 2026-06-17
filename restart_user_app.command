#!/bin/bash
echo "======================================================"
echo "  Restarting GMG User App on Chrome (port 8080)"
echo "======================================================"

# Kill any existing flutter run on port 8080
lsof -ti tcp:8080 | xargs kill -9 2>/dev/null
pkill -f "flutter run.*8080" 2>/dev/null
sleep 2

cd /Users/alyeldinmuhammad/Desktop/gmg
flutter pub get
flutter run -d chrome --web-port 8080
