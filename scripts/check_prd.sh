#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"
LOCAL_PRD="$DOCS_DIR/PRD_v1.0_sync.txt"

DOC_ID="1LBk3sP5H48edghAU8TcjxHFcX15pwA7S3fHFAuaE12E"
EXPORT_URL="https://docs.google.com/document/d/${DOC_ID}/export?format=txt"

mkdir -p "$DOCS_DIR"
TEMP_PRD="$DOCS_DIR/temp_prd.txt"
DIFF_FILE="$DOCS_DIR/temp_diff.txt"

echo "=> Fetching latest PRD from Google Docs..."
curl -sL "$EXPORT_URL" -o "$TEMP_PRD"

# Remove Windows-style carriage returns
tr -d '\r' < "$TEMP_PRD" > "${TEMP_PRD}_clean"
mv "${TEMP_PRD}_clean" "$TEMP_PRD"

if [ ! -s "$TEMP_PRD" ]; then
    echo "ERROR: Failed to fetch PRD or URL returned empty text."
    rm -f "$TEMP_PRD"
    exit 1
fi

if [ ! -f "$LOCAL_PRD" ]; then
    echo "=> Initializing tracking for PRD. Saving baseline to $LOCAL_PRD..."
    cp "$TEMP_PRD" "$LOCAL_PRD"
    rm -f "$TEMP_PRD"
    echo "=> Baseline established."
    exit 0
fi

echo "=> Comparing latest Google Doc against local tracking version..."
diff -u "$LOCAL_PRD" "$TEMP_PRD" > "$DIFF_FILE"

if [ -s "$DIFF_FILE" ]; then
    echo "========================================"
    echo "🚨 CHANGES DETECTED IN THE GOOGLE DOC! 🚨"
    echo "========================================"
    
    # Filter out diff headers and only show purely added/removed lines
    grep -E '^\+|^\-' "$DIFF_FILE" | grep -v -E '^\-\-\-|^\+\+\+'
    
    # Auto-sync local file so the next run focuses purely on new changes
    cp "$TEMP_PRD" "$LOCAL_PRD"
    echo "========================================"
    echo "=> Local PRD automatically synchronized with latest changes."
else
    echo "=> No changes detected. PRD is up to date."
fi

rm -f "$TEMP_PRD" "$DIFF_FILE"
