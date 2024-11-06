#!/bin/bash

REPO_URL="https://mkhazamipour.github.io/helm-charts"
DOCS_DIR="docs"

mv *.tgz $DOCS_DIR/

helm repo index $DOCS_DIR --url $REPO_URL

HTML_FILE="$DOCS_DIR/index.html"

cat > $HTML_FILE <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Helm Charts Repository</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; }
        h1 { color: #333; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>My Helm Charts Repository</h1>
    <p>Welcome to my Helm chart repository! Below is a list of available charts:</p>
    <table>
        <tr>
            <th>Chart Name</th>
            <th>Version</th>
            <th>Download</th>
        </tr>
EOL

while IFS= read -r line; do
    chart_name=$(echo "$line" | yq '.name' 2>/dev/null)
    chart_version=$(echo "$line" | yq '.version' 2>/dev/null)
    chart_url=$(echo "$line" | yq '.urls[0]' 2>/dev/null)

    if [[ -n "$chart_name" && -n "$chart_version" && -n "$chart_url" ]]; then
        cat >> $HTML_FILE <<EOL
        <tr>
            <td>$chart_name</td>
            <td>$chart_version</td>
            <td><a href="$chart_url">Download</a></td>
        </tr>
EOL
    fi
done <<< "$(yq '.entries[] | .[]' $DOCS_DIR/index.yaml)"

cat >> $HTML_FILE <<EOL
    </table>
</body>
</html>
EOL

git add .
git commit -m "Update Helm repo with new charts and generate index.html"
git push origin main

echo "Helm repository updated and index.html generated successfully!"
