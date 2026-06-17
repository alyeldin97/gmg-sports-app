#!/bin/bash
# GMG Sports — Seeds Supabase DB and runs the user app on Chrome
set -e

SUPABASE_URL="https://nmyzqekuqeneahzuhnap.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5teXpxZWt1cWVuZWFoenVobmFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NTExNTAsImV4cCI6MjA5NzAyNzE1MH0.aiXNR68kUcbdxUbvUcN2p1UuwfV_3gvFsOZBUqjGHDU"

echo "======================================================"
echo "  GMG Sports — User App Setup"
echo "======================================================"

# ── Check DB status ──────────────────────────────────────
echo ""
echo "Checking database..."
DB_RESPONSE=$(curl -s "${SUPABASE_URL}/rest/v1/products?select=id&limit=1" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}" 2>/dev/null)

if [[ "$DB_RESPONSE" == "["* ]] || [[ "$DB_RESPONSE" == "null" ]]; then
  echo "✅ Database schema exists."
  if [[ "$DB_RESPONSE" == "[]" ]]; then
    echo "⚠️  Products table is empty — you may need to seed data."
    echo "   Open: https://supabase.com/dashboard/project/nmyzqekuqeneahzuhnap/sql/new"
    echo "   and run: Desktop/gmg/supabase/schema.sql  then  seed.sql"
  else
    echo "✅ Database has products data."
  fi
elif [[ "$DB_RESPONSE" == *"does not exist"* ]] || [[ "$DB_RESPONSE" == *"relation"* ]]; then
  echo "❌ Database schema NOT found. You need to run the SQL manually:"
  echo "   1. Open: https://supabase.com/dashboard/project/nmyzqekuqeneahzuhnap/sql/new"
  echo "   2. Paste and run: supabase/schema.sql"
  echo "   3. Paste and run: supabase/seed.sql"
  open "https://supabase.com/dashboard/project/nmyzqekuqekeahzuhnap/sql/new"
else
  echo "ℹ️  DB status: $DB_RESPONSE"
fi

echo ""
echo "── Flutter pub get ─────────────────────────────────"
cd "$(dirname "$0")"
flutter pub get

echo ""
echo "── Running GMG User App on Chrome (port 8080) ─────"
echo "   Press 'q' to quit, 'r' to hot-reload"
flutter run -d chrome --web-port 8080
