#!/bin/bash
# Usage: ./scripts/update-html.sh <zip_file> <version> <size_kb>

ZIP_FILE="$1"
VERSION="$2"
SIZE_KB="${3:-0}"  # Default to 0 KB if not provided

HTML_FILE="docs/index.html"
ZIP_NAME=$(basename "$ZIP_FILE")
ZIP_URL="https://github.com/Drift-King/NFS-HELPER/releases/download/${VERSION}/${ZIP_NAME}"

mkdir -p docs

# --- Wait for ZIP file to exist (up to 60 seconds) ---
MAX_WAIT=60
WAITED=0
while [ ! -f "$ZIP_FILE" ]; do
    if [ "$WAITED" -ge "$MAX_WAIT" ]; then
        echo "Error: ZIP file $ZIP_FILE not found after $MAX_WAIT seconds"
        exit 1
    fi
    echo "Waiting for $ZIP_FILE to be created..."
    sleep 2
    WAITED=$((WAITED + 2))
done
echo "$ZIP_FILE found, proceeding..."

# Create basic HTML if missing
if [ ! -f "$HTML_FILE" ]; then
cat > "$HTML_FILE" <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Blender Extensions</title>
</head>
<body>
<p>Blender Extension Listing:</p>
<p>Add-on</p>
<hr>
<!-- extensions table -->
<table>
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Description</th>
    <th>Website</th>
    <th>Blender Versions</th>
    <th>Python Versions</th>
    <th>Platforms</th>
    <th>Size</th>
  </tr>
</table>
<center><p>Built $(date -u +"%Y-%m-%d, %H:%M UTC")</p></center>
</body>
</html>
EOF
fi

# Backup original HTML
cp "$HTML_FILE" "$HTML_FILE.bak"

# Remove existing row for this version
awk -v ver="$VERSION" '
  /<tr>/ {skip=0}
  /<tr>/,/<\/tr>/ {
    if ($0 ~ ver) {skip=1}
    if (!skip) {print}
    next
  }
  {print}
' "$HTML_FILE.bak" > "$HTML_FILE.tmp"

# Extract existing rows
awk '/<tr>/,/<\/tr>/ {if ($0 !~ /<th>/) print $0}' "$HTML_FILE.tmp" > rows.txt

# Add new row
NEW_ROW="  <tr>
    <td><tt><a href=\"$ZIP_URL?repository=index.json&blender_version_min=4.2.0\">nfs_helper-$VERSION</a></tt></td>
    <td>NFS HELPER</td>
    <td>NFS HELPER</td>
    <td><a href=\"https://github.com/Drift-King/NFS-HELPER\">link</a></td>
    <td>4.2.0 - ~</td>
    <td>all</td>
    <td>all</td>
    <td>$SIZE_KB KB</td>
  </tr>"
echo "$NEW_ROW" >> rows.txt

# Sort rows by version descending
sort -r -V -k1,1 rows.txt > rows_sorted.txt

# Rebuild HTML
awk -v rows_file="rows_sorted.txt" '
  /<!-- extensions table -->/ {in_table=1}
  {print}
  in_table && /<\/table>/ {
    while ((getline row < rows_file) > 0) print row
    in_table=0
  }
' "$HTML_FILE.tmp" > "$HTML_FILE"

rm "$HTML_FILE.tmp" rows.txt rows_sorted.txt

echo "Updated $HTML_FILE with nfs_helper-$VERSION ($SIZE_KB KB)"