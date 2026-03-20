#!/bin/bash
set -e

# Arguments
ZIP_FILE="$1"
VERSION="$2"
SIZE_KB="$3"

# Ensure docs folder and index.html exist
mkdir -p docs
HTML_FILE="docs/index.html"
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
<center><p>Built $(date "+%Y-%m-%d, %H:%M")</p></center>
</body>
</html>
EOF
fi

# Extract the table contents
TABLE_CONTENT=$(awk '/<table>/,/<\/table>/' "$HTML_FILE")

# Remove any existing row for this version
NEW_TABLE=$(echo "$TABLE_CONTENT" | sed "/nfs_helper-$VERSION/d")

# Create new row
NEW_ROW="  <tr>
    <td><tt><a href=\"https://github.com/Drift-King/NFS-HELPER/releases/download/$VERSION/$ZIP_FILE?repository=index.json&blender_version_min=4.2.0\">nfs_helper-$VERSION</a></tt></td>
    <td>NFS HELPER</td>
    <td>NFS HELPER</td>
    <td><a href=\"https://github.com/Drift-King/NFS-HELPER\">link</a></td>
    <td>4.2.0 - ~</td>
    <td>all</td>
    <td>all</td>
    <td>${SIZE_KB}KB</td>
  </tr>"

# Insert new row just after the header row (after <tr> with <th>)
UPDATED_TABLE=$(echo "$NEW_TABLE" | awk -v row="$NEW_ROW" '
  /<tr>.*<th>/ {print; print row; next} 
  {print}
')

# Replace old table in HTML file
awk -v newtable="$UPDATED_TABLE" 'BEGIN{inside=0} 
  /<table>/ {inside=1; print newtable; next} 
  /<\/table>/ {inside=0; next} 
  {if(!inside) print}' "$HTML_FILE" > "$HTML_FILE.tmp"

mv "$HTML_FILE.tmp" "$HTML_FILE"

echo "Updated $HTML_FILE with version $VERSION."