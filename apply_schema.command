#!/bin/bash
# Copies schema+seed SQL to clipboard and opens Supabase SQL editor
echo "======================================================"
echo "  GMG Sports — Apply Database Schema"
echo "======================================================"
echo ""

# Combine schema + seed into one file and copy to clipboard
cat /Users/alyeldinmuhammad/Desktop/gmg/supabase/schema.sql \
    /Users/alyeldinmuhammad/Desktop/gmg/supabase/seed.sql | pbcopy

echo "✅ Full SQL (schema + seed) copied to your clipboard!"
echo ""
echo "Opening Supabase SQL editor..."
open "https://supabase.com/dashboard/project/nmyzqekuqeneahzuhnap/sql/new"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ACTION NEEDED (3 steps):"
echo "  1. In the Supabase SQL editor that just opened,"
echo "     press Cmd+V to paste the SQL"
echo "  2. Click the green 'Run' button"
echo "  3. Come back here — the app will reload automatically"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After running SQL, admin login:"
echo "  Email:    admin@gmgsports.com"
echo "  Password: Admin@123"
echo ""
echo "User login:"
echo "  Email:    customer@gmgsports.com"
echo "  Password: User@123"
echo ""
read -p "Press Enter after you've run the SQL..."

echo ""
echo "Opening the GMG app..."
open "http://localhost:8080"
