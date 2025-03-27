#!/bin/bash

REPO_URL="https://mkhazamipour.github.io/helm-charts"
DOCS_DIR="docs"

# Create docs directory if it doesn't exist
mkdir -p $DOCS_DIR

# Copy all tgz files to docs directory
find . -maxdepth 1 -name "*.tgz" -exec cp {} $DOCS_DIR/ \;

# Generate or update the Helm repository index
helm repo index $DOCS_DIR --url $REPO_URL

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
charts_exist=$(find $DOCS_DIR -name "*.tgz" -print -quit)
if [ -z "$charts_exist" ]; then
    echo "No chart packages found in $DOCS_DIR"
    cat >> $HTML_FILE <<EOL
        <tr><td colspan="4">No charts available at this time.</td></tr>
EOL
else
    # Process each chart file
    find $DOCS_DIR -name "*.tgz" | while read -r chart_file; do
        filename=$(basename "$chart_file")
        if [ -f "$chart_file" ]; then
            # Extract chart info using helm inspect
            chart_info=$(helm inspect chart "$chart_file" 2>/dev/null)
            if [ $? -eq 0 ]; then
                name=$(echo "$chart_info" | grep '^name:' | cut -d':' -f2- | tr -d ' ')
                version=$(echo "$chart_info" | grep '^version:' | cut -d':' -f2- | tr -d ' ')
                description=$(echo "$chart_info" | grep '^description:' | sed 's/^ *//')
                download_url="$REPO_URL/docs/$filename"
                
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

# Git operations
git add .
git commit -m "Update Helm repository and index.html"
git push origin main
echo "✅ Helm repository updated successfully!"
echo "📦 Charts available at: $REPO_URL"
