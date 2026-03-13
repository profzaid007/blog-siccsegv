#!/bin/bash

# Script to convert Markdown posts with frontmatter to HTML
# Usage: ./build-post.sh posts/my-post.md

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <markdown-file>"
  echo "Example: $0 posts/my-new-post.md"
  exit 1
fi

INPUT_FILE="$1"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: File '$INPUT_FILE' not found"
  exit 1
fi

# Extract filename without extension
BASENAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="posts/${BASENAME}.html"

# Extract frontmatter values
TITLE=$(grep -m 1 "^title:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
DATE=$(grep -m 1 "^date:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
TAGS_LINE=$(grep -m 1 "^tags:" "$INPUT_FILE")
READING_TIME=$(grep -m 1 "^reading_time:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
AUTHOR_NAME=$(grep -m 1 "^author_name:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
AUTHOR_ROLE=$(grep -m 1 "^author_role:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
AUTHOR_BIO=$(grep -m 1 "^author_bio:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
META_DESCRIPTION=$(grep -m 1 "^description:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
META_KEYWORDS=$(grep -m 1 "^keywords:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
CANONICAL_URL=$(grep -m 1 "^canonical_url:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')
CATEGORY=$(grep -m 1 "^category:" "$INPUT_FILE" | cut -d':' -f2- | sed 's/^ *//;s/["]*//g')

# Set defaults if not found
TITLE=${TITLE:-"Untitled Post"}
DATE=${DATE:-"$(date +'%B %d, %Y')"}
READING_TIME=${READING_TIME:-"5 min read"}
AUTHOR_NAME=${AUTHOR_NAME:-"Siccsegv Team"}
AUTHOR_ROLE=${AUTHOR_ROLE:-"Security Researchers"}
AUTHOR_BIO=${AUTHOR_BIO:-"Our team of security researchers and penetration testers share insights from real-world engagements and cutting-edge research."}
META_DESCRIPTION=${META_DESCRIPTION:-"Technical insights from Siccsegv Blog"}
META_KEYWORDS=${META_KEYWORDS:-"cybersecurity, penetration testing, security research"}
CANONICAL_URL=${CANONICAL_URL:-"https://blog.siccsegv.com/posts/${BASENAME}.html"}
CATEGORY=${CATEGORY:-"Uncategorized"}

# Extract tags as array
if [[ -n "$TAGS_LINE" ]]; then
  TAGS_CONTENT=$(echo "$TAGS_LINE" | cut -d':' -f2- | sed 's/^ *//')
  # Remove brackets if present
  TAGS_CONTENT=$(echo "$TAGS_CONTENT" | sed 's/\[//;s/\]//')
  # Split by comma and clean up
  IFS=',' read -ra TAGS_ARRAY <<< "$TAGS_CONTENT"
  for i in "${!TAGS_ARRAY[@]}"; do
    TAGS_ARRAY[$i]=$(echo "${TAGS_ARRAY[$i]}" | sed 's/^ *//;s/ *$//;s/["]*//g')
  done
else
  TAGS_ARRAY=("Uncategorized")
fi

# Simple markdown to HTML conversion function
markdown_to_html() {
  local input="$1"
  
  # Escape HTML special chars first
  input=$(echo "$input" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#039;/g')
  
  # Convert headers
  input=$(echo "$input" | sed -E 's/^# (.+)$/<h1 class="post-heading">\1<\/h1>/')
  input=$(echo "$input" | sed -E 's/^## (.+)$/<h2>\1<\/h2>/')
  input=$(echo "$input" | sed -E 's/^### (.+)$/<h3>\1<\/h3>/')
  input=$(echo "$input" | sed -E 's/^#### (.+)$/<h4>\1<\/h4>/')
  input=$(echo "$input" | sed -E 's/^##### (.+)$/<h5>\1<\/h5>/')
  input=$(echo "$input" | sed -E 's/^###### (.+)$/<h6>\1<\/h6>/')
  
  # Convert bold and italic
  input=$(echo "$input" | sed -E 's/\*\*(.+)\*\*/<strong>\1<\/strong>/g')
  input=$(echo "$input" | sed -E 's/\*(.+)\*/<em>\1<\/em>/g')
  
  # Convert code blocks (basic)
  input=$(echo "$input" | sed -E 's/`(.+)`/<code>\1<\/code>/g')
  
  # Convert links
  input=$(echo "$input" | sed -E 's/\[([^\]]+)\]\(([^)]+)\)/<a href="\2" target="_blank" rel="noopener noreferrer">\1<\/a>/g')
  
  # Convert paragraphs (lines not starting with <)
  input=$(echo "$input" | sed ':a;N;$!ba;s/\n\([^<]\)/<p>\1/g')
  input=$(echo "$input" | sed 's/^/<p>/;s=$/<\/p>/')
  
  # Clean up empty paragraphs
  input=$(echo "$input" | sed 's/<p><\/p>//g')
  
  echo "$input"
}

# Get content after frontmatter (between --- lines)
CONTENT_RAW=$(awk '/^---$/ {getline; while (!/^---$/) {print; getline}}' "$INPUT_FILE")

# If no frontmatter delimiters found, use whole file as content
if [[ -z "$CONTENT_RAW" ]]; then
  CONTENT_RAW=$(sed '1d' "$INPUT_FILE")  # Remove first line if it's just ---
fi

# Convert markdown to HTML
CONTENT=$(markdown_to_html "$CONTENT_RAW")

# Get current year for footer
YEAR=$(date +%Y)

# Prepare tag strings
FIRST_TAG=${TAGS_ARRAY[0]}
TAGS_LIST=""
for tag in "${TAGS_ARRAY[@]}"; do
  if [[ -n "$tag" ]]; then
    TAGS_LIST="$TAGS_LIST<span class=\"tag\">$tag</span>"
  fi
done

# Create temporary file for template processing
TEMP_FILE=$(mktemp)
cp _templates/post.html "$TEMP_FILE"

# Replace placeholders using a delimiter that won't appear in our data (using |)
sed -i "s|{{TITLE}}|$TITLE|g" "$TEMP_FILE"
sed -i "s|{{DATE}}|$DATE|g" "$TEMP_FILE"
sed -i "s|{{READING_TIME}}|$READING_TIME|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_NAME}}|$AUTHOR_NAME|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_ROLE}}|$AUTHOR_ROLE|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_BIO}}|$AUTHOR_BIO|g" "$TEMP_FILE"
sed -i "s|{{META_DESCRIPTION}}|$META_DESCRIPTION|g" "$TEMP_FILE"
sed -i "s|{{META_KEYWORDS}}|$META_KEYWORDS|g" "$TEMP_FILE"
sed -i "s|{{CANONICAL_URL}}|$CANONICAL_URL|g" "$TEMP_FILE"
sed -i "s|{{YEAR}}|$YEAR|g" "$TEMP_FILE"
sed -i "s|{{CATEGORY}}|$CATEGORY|g" "$TEMP_FILE"
sed -i "s|{{CONTENT}}|$CONTENT|g" "$TEMP_FILE"
sed -i "s|{{FIRST_TAG}}|$FIRST_TAG|g" "$TEMP_FILE"
sed -i "s|{{TAGS_LIST}}|$TAGS_LIST|g" "$TEMP_FILE"

# Move temp file to final location
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "Generated: $OUTPUT_FILE"