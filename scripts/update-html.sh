#!/bin/bash
ZIP_FILE=$1
VERSION=$2
SIZE_KB=$3

DOCS_DIR="docs"
FILE_URL="https://github.com/Drift-King/NFS-HELPER/releases/download/$VERSION/$(basename $ZIP_FILE)?repository=index.json&blender_version_min=4.2.0"

mkdir -p "$DOCS_DIR"

# Create template if missing
if [ ! -f "$DOCS_DIR/releases.html" ]; then
cat <<EOT > "$DOCS_DIR/releases.html"
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
<center><p>Built $(date -u '+%Y-%m-%d, %H:%M UTC')</p></center>
</body>
</html>
EOT
fi

# Remove old row for this version
grep -v "nfs_helper-$VERSION" "$DOCS_DIR/releases.html" > "$DOCS_DIR/releases.tmp.html"

# Insert new row before </table>
awk -v url="$FILE_URL" -v ver="$VERSION" -v size="$SIZE_KB" '{
  if (/<\/table>/) {
    print "  <tr>"
    print "    <td><tt><a href=\"" url "\">nfs_helper-" ver "</a></tt></td>"
    print "    <td>NFS HELPER</td>"
    print "    <td>NFS HELPER</td>"
    print "    <td><a href=\"https://github.com/Drift-King/nfs-helper\">link</a></td>"
    print "    <td>4.2.0 - ~</td>"
    print "    <td>all</td>"
    print "    <td>all</td>"
    print "    <td>" size " KB</td>"
    print "  </tr>"
  }
  print
}' "$DOCS_DIR/releases.tmp.html" > "$DOCS_DIR/releases.new.html"

# Update timestamp
sed -i "s/<center><p>Built .*<\/p><\/center>/<center><p>Built $(date -u '+%Y-%m-%d, %H:%M UTC')<\/p><\/center>/" "$DOCS_DIR/releases.new.html"

mv "$DOCS_DIR/releases.new.html" "$DOCS_DIR/releases.html"