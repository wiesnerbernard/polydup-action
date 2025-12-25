#!/bin/bash
set -e

# Input parameters
THRESHOLD=$1
SIMILARITY=$2
FAIL_ON_DUPLICATES=$3
FORMAT=$4
BASE_REF=$5
GITHUB_TOKEN=$6
COMMENT_ON_PR=$7

echo "🔍 PolyDup Code Duplicate Detector"
echo "=================================="

# Detect base reference for git-diff
if [ -z "$BASE_REF" ]; then
  if [ -n "$GITHUB_BASE_REF" ]; then
    # Pull Request context
    BASE_REF="origin/$GITHUB_BASE_REF"
    echo "📊 Detected PR context: comparing against $BASE_REF"
  else
    # Fallback to HEAD
    BASE_REF="HEAD"
    echo "⚠️  No PR context detected, comparing against HEAD"
  fi
else
  echo "📊 Using provided base reference: $BASE_REF"
fi

# Build git-diff range
if [ "$BASE_REF" == "HEAD" ]; then
  GIT_RANGE="HEAD"
else
  # Fetch the base branch for comparison
  echo "🔄 Fetching base branch..."
  git fetch origin "$GITHUB_BASE_REF" --depth=1 2>/dev/null || true
  GIT_RANGE="${BASE_REF}..HEAD"
fi

echo "🎯 Scanning files changed in: $GIT_RANGE"
echo "   Threshold: $THRESHOLD tokens"
echo "   Similarity: $SIMILARITY"
echo ""

# Run polydup scan
OUTPUT_FILE="/tmp/polydup-output.txt"
JSON_FILE="/tmp/polydup-output.json"

# Run with text output for display
set +e
polydup scan . \
  --git-diff "$GIT_RANGE" \
  --threshold "$THRESHOLD" \
  --similarity "$SIMILARITY" \
  --format text \
  > "$OUTPUT_FILE" 2>&1
POLYDUP_EXIT_CODE=$?
set -e

# Also get JSON for parsing
polydup scan . \
  --git-diff "$GIT_RANGE" \
  --threshold "$THRESHOLD" \
  --similarity "$SIMILARITY" \
  --format json \
  > "$JSON_FILE" 2>/dev/null || echo '{"files_scanned":0,"duplicates":[]}' > "$JSON_FILE"

# Display results
cat "$OUTPUT_FILE"

# Parse JSON results
DUPLICATES_FOUND=$(jq -r '.duplicates | length' "$JSON_FILE" 2>/dev/null || echo "0")
FILES_SCANNED=$(jq -r '.files_scanned' "$JSON_FILE" 2>/dev/null || echo "0")

# Set GitHub Action outputs
echo "duplicates-found=$DUPLICATES_FOUND" >> "$GITHUB_OUTPUT"
echo "files-scanned=$FILES_SCANNED" >> "$GITHUB_OUTPUT"
echo "exit-code=$POLYDUP_EXIT_CODE" >> "$GITHUB_OUTPUT"

# Post PR comment if enabled
if [ "$COMMENT_ON_PR" == "true" ] && [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_EVENT_PATH" ]; then
  PR_NUMBER=$(jq -r '.pull_request.number' "$GITHUB_EVENT_PATH" 2>/dev/null || echo "")
  
  if [ -n "$PR_NUMBER" ] && [ "$PR_NUMBER" != "null" ]; then
    echo ""
    echo "💬 Posting results to PR #$PR_NUMBER..."
    
    # Create comment body
    COMMENT_BODY="## 🔍 PolyDup Duplicate Code Report

"
    
    if [ "$DUPLICATES_FOUND" -eq 0 ]; then
      COMMENT_BODY+="✅ **No duplicate code detected!**

"
      COMMENT_BODY+="- Files scanned: $FILES_SCANNED
- Threshold: $THRESHOLD tokens
- Similarity: $SIMILARITY

Great work keeping the codebase clean! 🎉"
    else
      COMMENT_BODY+="⚠️ **Found $DUPLICATES_FOUND duplicate code block(s)**

"
      COMMENT_BODY+="- Files scanned: $FILES_SCANNED
- Threshold: $THRESHOLD tokens
- Similarity: $SIMILARITY

<details>
<summary>📋 View Details</summary>

\`\`\`
$(cat "$OUTPUT_FILE" | head -100)
\`\`\`

</details>

💡 **Tip**: Consider refactoring duplicated code to improve maintainability."
    fi
    
    # Post comment using GitHub API
    COMMENT_JSON=$(jq -n --arg body "$COMMENT_BODY" '{body: $body}')
    
    curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
      -d "$COMMENT_JSON" > /dev/null
    
    echo "✅ Comment posted successfully"
  fi
fi

# Exit based on configuration
if [ "$FAIL_ON_DUPLICATES" == "true" ] && [ "$POLYDUP_EXIT_CODE" -eq 1 ]; then
  echo ""
  echo "❌ Check failed: duplicates found (fail-on-duplicates=true)"
  exit 1
else
  echo ""
  echo "✅ Check completed successfully"
  exit 0
fi
