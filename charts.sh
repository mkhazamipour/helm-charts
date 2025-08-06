#!/bin/bash

REPO_URL="https://mkhazamipour.github.io/helm-charts"
DOCS_DIR="docs"

echo "🔄 Processing Helm Charts Repository..."

# Create docs directory if it doesn't exist
mkdir -p $DOCS_DIR

# Clean up any nested docs directories to prevent duplicates
if [ -d "$DOCS_DIR/docs" ]; then
    echo "Removing nested docs directory to prevent duplicates..."
    rm -rf "$DOCS_DIR/docs"
fi

# Remove any .tgz files from root directory (we only want them in docs)
find . -maxdepth 1 -name "*.tgz" -delete 2>/dev/null || true

# Copy any new .tgz files from root to docs directory (if any)
find . -maxdepth 1 -name "*.tgz" -exec cp {} $DOCS_DIR/ \; 2>/dev/null || true

echo "📦 Processing charts in $DOCS_DIR directory..."

# Generate or update the Helm repository index (this will overwrite existing index.yaml)
# The URL should point to where the files will be accessible via GitHub Pages
helm repo index $DOCS_DIR --url "$REPO_URL/docs"

HTML_FILE="$DOCS_DIR/index.html"

# Create index.html (completely regenerate to avoid duplicates)
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
charts_exist=$(find $DOCS_DIR -maxdepth 1 -name "*.tgz" -print -quit)
if [ -z "$charts_exist" ]; then
    echo "No chart packages found in $DOCS_DIR"
    cat >> $HTML_FILE <<EOL
        <tr><td colspan="4">No charts available at this time.</td></tr>
EOL
else
    echo "Found chart packages, processing..."
    
    # Store chart data in arrays to avoid subshell issues
    declare -a chart_names
    declare -a chart_versions  
    declare -a chart_descriptions
    declare -a chart_urls
    declare -A processed_charts
    
    # Process each chart file (only in docs directory, not recursively)
    while IFS= read -r -d '' chart_file; do
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
                    # Create unique identifier for deduplication
                    chart_id="${name}-${version}"
                    
                    # Only add if not already processed
                    if [[ -z "${processed_charts[$chart_id]}" ]]; then
                        echo "  📋 $name-$version"
                        chart_names+=("$name")
                        chart_versions+=("$version")
                        chart_descriptions+=("$description")
                        chart_urls+=("$download_url")
                        processed_charts[$chart_id]=1
                    fi
                fi
            fi
        fi
    done < <(find $DOCS_DIR -maxdepth 1 -name "*.tgz" -print0 | sort -z)
    
    # Generate HTML rows
    for i in "${!chart_names[@]}"; do
        cat >> $HTML_FILE <<EOL
        <tr>
            <td>${chart_names[$i]}</td>
            <td>${chart_versions[$i]}</td>
            <td class="description">${chart_descriptions[$i]}</td>
            <td><a href="${chart_urls[$i]}">Download</a></td>
        </tr>
EOL
    done
fi

cat >> $HTML_FILE <<EOL
    </table>
</body>
</html>
EOL

# Create a simple index.html in root that redirects to docs
cat > index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url=docs/">
    <title>Helm Charts Repository</title>
</head>
<body>
    <p>Redirecting to <a href="docs/">Helm Charts Repository</a>...</p>
</body>
</html>
EOL

echo "✅ Generated index files successfully!"
echo "📁 Charts are located in: $DOCS_DIR/"
echo "🌐 Repository URL: $REPO_URL"
echo ""

# Count charts
chart_count=$(find $DOCS_DIR -maxdepth 1 -name "*.tgz" | wc -l)
echo "📊 Total charts processed: $chart_count"

# Git operations
git add .
git commit -m "Update Helm repository and index files"
git push origin main

echo "✅ Helm repository updated successfully!"
echo "📦 Charts available at: $REPO_URL"
