#!/bin/bash
# Usage: ./scripts/update-html.sh <zip_file> <version> <size_kb>

ZIP_FILE="$1"
VERSION="$2"
SIZE_KB="$3"

HTML_FILE="docs/index.html"
ZIP_NAME=$(basename "$ZIP_FILE")
ZIP_URL="https://github.com/Drift-King/NFS-HELPER/releases/download/${VERSION}/${ZIP_NAME}"

# Ensure docs folder exists
mkdir -p docs

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

# Remove existing row for this version if it exists
grep -v "nfs_helper-${VERSION}" "$HTML_FILE.bak" > "$HTML_FILE.tmp"

# Insert new row before </table>
awk -v zip_url="$ZIP_URL" -v version="$VERSION" -v size_kb="$SIZE_KB" '
  /<\/table>/ {
    print "  <tr>"
    print "    <td><tt><a href=\"" zip_url "?repository=index.json&blender_version_min=4.2.0\">nfs_helper-" version "</a></tt></td>"
    print "    <td>NFS HELPER</td>"
    print "    <td>NFS HELPER</td>"
    print "    <td><a href=\"https://github.com/Drift-King/NFS-HELPER\">link</a></td>"
    print "    <td>4.2.0 - ~</td>"
    print "    <td>all</td>"
    print "    <td>all</td>"
    print "    <td>" size_kb "KB</td>"
    print "  </tr>"
  }
  { print }
' "$HTML_FILE.tmp" > "$HTML_FILE"

# Clean up
rm "$HTML_FILE.tmp"