#!/bin/bash

# Configuration
SRC_DIR="src"
DIST_DIR="dist"
DATA_FILE="$SRC_DIR/data/publications.json"
REDIRECTS_FILE="$DIST_DIR/_redirects"

echo "cleaning dist directory..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "Copying source files..."
cp -r "$SRC_DIR/"* "$DIST_DIR/"

echo "Generating _redirects file..."

echo "# Generated on $(date)" >> "$REDIRECTS_FILE"
echo "" >> "$REDIRECTS_FILE"

jq -r '.[] | "\(.slug) \(.doi // "null") \(.url // "null")"' "$DATA_FILE" | while read -r slug doi url; do
    target=""

    if [ "$doi" != "null" ] && [ -n "$doi" ]; then
        # Check if doi already starts with http
        if [[ "$doi" == http* ]]; then
            target="$doi"
        else
            target="https://doi.org/$doi"
        fi
    elif [ "$url" != "null" ] && [ -n "$url" ]; then
        target="$url"
    fi

    if [[ -n "$target" ]] && [[ -n "$slug" ]]; then
        echo "/$slug  $target  301" >> "$REDIRECTS_FILE"
        echo "  -> /$slug redirects to $target"
    fi
done
echo "/*  /index.html  200" >> "$REDIRECTS_FILE"

echo ""
echo "✅ Build complete. Contents of dist/_redirects:"
cat "$REDIRECTS_FILE"
