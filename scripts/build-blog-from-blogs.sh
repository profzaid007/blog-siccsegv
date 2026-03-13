#!/bin/bash

# Script to convert blog markdown files from blogs/ directory to HTML
# Usage: ./build-blog-from-blogs.sh blogs/blog-file.md

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <markdown-file>"
  echo "Example: $0 blogs/a_case_for_ctfs.md"
  exit 1
fi

INPUT_FILE="$1"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: File '$INPUT_FILE' not found"
  exit 1
fi

# Extract filename without extension and directory
BASENAME=$(basename "$INPUT_FILE" .md)
OUTPUT_FILE="posts/${BASENAME}.html"

# Extract title (first line starting with # )
TITLE=$(grep -m 1 "^# " "$INPUT_FILE" | sed 's/^# //')

# Extract description (line starting with ## Description:)
DESCRIPTION_LINE=$(grep -m 1 "^## Description:" "$INPUT_FILE")
DESCRIPTION=$(echo "$DESCRIPTION_LINE" | sed 's/^## Description: //')

# Extract category (line starting with ## Category:)
CATEGORY_LINE=$(grep -m 1 "^## Category:" "$INPUT_FILE")
CATEGORY=$(echo "$CATEGORY_LINE" | sed 's/^## Category: //')

# Set defaults if not found
TITLE=${TITLE:-"Untitled Post"}
DESCRIPTION=${DESCRIPTION:-"Technical insights from Siccsegv Blog"}
CATEGORY=${CATEGORY:-"Uncategorized"}

# Set other defaults
DATE=$(date +'%B %d, %Y')
READING_TIME="5 min read"
AUTHOR_NAME="Siccsegv Team"
AUTHOR_ROLE="Security Researchers"
AUTHOR_BIO="Our team of security researchers and penetration testers share insights from real-world engagements and cutting-edge research."
META_KEYWORDS="cybersecurity, penetration testing, security research"
CANONICAL_URL="https://blog.siccsegv.com/posts/${BASENAME}.html"
YEAR=$(date +%Y)

# Get content (everything after the title, description, and category lines)
# Skip the first 3 lines and any leading blank lines
CONTENT_RAW=$(tail -n +4 "$INPUT_FILE" | sed '/^$/q')

# If we removed too much, get everything after the first 3 lines
if [[ -z "$CONTENT_RAW" ]]; then
  CONTENT_RAW=$(tail -n +4 "$INPUT_FILE")
fi

# Very simple markdown to HTML conversion - just handle paragraphs for now
# This avoids complex regex that can break
convert_to_simple_html() {
  local input="$1"
  
  # Handle line breaks - convert double newlines to paragraph breaks
  # First, escape HTML special characters
  input=$(echo "$input" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#039;/g')
  
  # Convert paragraphs (separated by blank lines)
  input=$(echo "$input" | sed ':a;N;$!ba;s/\n\n\+/<\/p><p>/g')
  input=$(echo "$input" | sed 's/^/<p>/; s=$/<\/p>/')
  
  # Clean up empty paragraphs
  input=$(echo "$input" | sed 's/<p><\/p>//g')
  
  echo "$input"
}

# Convert content to HTML
CONTENT=$(convert_to_simple_html "$CONTENT_RAW")

# Prepare tag strings for the template
FIRST_TAG=${CATEGORY}  # Use category as the first tag for simplicity
TAGS_LIST=""
if [[ -n "$CATEGORY" ]]; then
  TAGS_LIST="<span class=\"tag\">$CATEGORY</span>"
fi

# Create temporary file for template processing
TEMP_FILE=$(mktemp)
cp _templates/post.html "$TEMP_FILE"

# Replace placeholders one by one using sed with different delimiters
sed -i "s|{{TITLE}}|$TITLE|g" "$TEMP_FILE"
sed -i "s|{{DATE}}|$DATE|g" "$TEMP_FILE"
sed -i "s|{{READING_TIME}}|$READING_TIME|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_NAME}}|$AUTHOR_NAME|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_ROLE}}|$AUTHOR_ROLE|g" "$TEMP_FILE"
sed -i "s|{{AUTHOR_BIO}}|$AUTHOR_BIO|g" "$TEMP_FILE"
sed -i "s|{{META_DESCRIPTION}}|$DESCRIPTION|g" "$TEMP_FILE"
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