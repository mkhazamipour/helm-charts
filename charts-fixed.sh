#!/bin/bash

REPO_URL="https://mkhazamipour.github.io/helm-charts"
DOCS_DIR="docs"

# Create docs directory if it doesn't exist
mkdir -p $DOCS_DIR

# Clean up any nested docs directories to prevent duplicates
if [ -d "$DOCS_DIR/docs" ]; then
    echo "Removing nested docs directory to prevent duplicates..."
    rm -rf "$DOCS_DIR/docs"
fi

# Copy all tgz files to both root and docs directory for GitHub Pages compatibility
find . -maxdepth 1 -name "*.tgz" -exec cp {} $DOCS_DIR/ \;
find . -maxdepth 1 -name "*.tgz" -exec cp {} . \; 2>/dev/null || true

# Also copy existing tgz files from docs to root
find $DOCS_DIR -maxdepth 1 -name "*.tgz" -exec cp {} . \;

echo "Processing charts..."

# Generate repository index in docs directory
helm repo index $DOCS_DIR --url $REPO_URL

# Also generate in root for compatibility
helm repo index . --url $REPO_URL

HTML_FILE="$DOCS_DIR/index.html"

# Create index.html
cat > $HTML_FILE <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Helm Charts Repository</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; padding: 20px; }
        h1 { color: #333; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .description { color: #666; }
    </style>
</head>
<body>
    <h1>Helm Charts Repository</h1>
    <p>Available Helm charts in this repository:</p>
    <table>
        <tr>
            <th>Chart Name</th>
            <th>Version</th>
            <th>Description</th>
            <th>Download</th>
        </tr>
EOL

# Check if any chart files exist
charts_exist=$(find . -maxdepth 1 -name "*.tgz" -print -quit)
if [ -z "$charts_exist" ]; then
    echo "No chart packages found"
    cat >> $HTML_FILE <<EOL
        <tr><td colspan="4">No charts available at this time.</td></tr>
EOL
else
    echo "Found chart packages, processing..."
    # Process each chart file from root directory to avoid duplicates
    find . -maxdepth 1 -name "*.tgz" | sort | while read -r chart_file; do
        filename=$(basename "$chart_file")
        if [ -f "$chart_file" ]; then
            # Extract chart info using helm inspect
            chart_info=$(helm inspect chart "$chart_file" 2>/dev/null)
            if [ $? -eq 0 ]; then
                name=$(echo "$chart_info" | grep '^name:' | cut -d':' -f2- | tr -d ' ')
                version=$(echo "$chart_info" | grep '^version:' | cut -d':' -f2- | tr -d ' ')
                description=$(echo "$chart_info" | grep '^description:' | sed 's/^ *//')
                download_url="$REPO_URL/$filename"
                
                echo "Processing: $name-$version -> $download_url"
                
                if [[ -n "$name" && -n "$version" ]]; then
                    cat >> $HTML_FILE <<EOL
        <tr>
            <td>$name</td>
            <td>$version</td>
            <td class="description">$description</td>
            <td><a href="$download_url">Download</a></td>
        </tr>
EOL
                fi
            fi
        fi
    done
fi

cat >> $HTML_FILE <<EOL
    </table>
</body>
</html>
EOL

# Copy the index.html to root as well for compatibility
cp $HTML_FILE ./index.html

# Git operations
git add .
git commit -m "Update Helm repository and index files"
git push origin main

echo "✅ Helm repository updated successfully!"
echo "📦 Charts available at: $REPO_URL"
echo ""
echo "Files have been placed in both root and docs directories for maximum compatibility"
