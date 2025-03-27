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

# Read chart information from index.yaml and populate the table
yq '.entries.* | .[]' $DOCS_DIR/index.yaml | while read -r entry; do
    name=$(echo "$entry" | yq '.name')
    version=$(echo "$entry" | yq '.version')
    description=$(echo "$entry" | yq '.description // "No description available"')
    url=$(echo "$entry" | yq '.urls[0]')
    
    # Only add entry if we have valid name and version
    if [[ -n "$name" && "$name" != "null" && -n "$version" && "$version" != "null" ]]; then
        cat >> $HTML_FILE <<EOL
        <tr>
            <td>$name</td>
            <td>$version</td>
            <td class="description">$description</td>
            <td><a href="$url">Download</a></td>
        </tr>
EOL
    fi
done

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
