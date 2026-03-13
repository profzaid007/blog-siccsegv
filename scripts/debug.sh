#!/bin/bash

INPUT_FILE="blogs/career_in_cybersecurity.md"

# Extract title (first line starting with # )
TITLE=$(grep -m 1 "^# " "$INPUT_FILE" | sed 's/^# //')
echo "TITLE: '$TITLE'"

# Extract description (line starting with ## Description:)
DESCRIPTION_LINE=$(grep -m 1 "^## Description:" "$INPUT_FILE")
DESCRIPTION=$(echo "$DESCRIPTION_LINE" | sed 's/^## Description: //')
echo "DESCRIPTION: '$DESCRIPTION'"

# Extract category (line starting with ## Category:)
CATEGORY_LINE=$(grep -m 1 "^## Category:" "$INPUT_FILE")
CATEGORY=$(echo "$CATEGORY_LINE" | sed 's/^## Category: //')
echo "CATEGORY: '$CATEGORY'"

# Get content (everything after the title, description, and category lines)
CONTENT_RAW=$(tail -n +4 "$INPUT_FILE")
echo "CONTENT_RAW first 100 chars: '${CONTENT_RAW:0:100}'"

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

# Convert markdown to HTML
CONTENT=$(markdown_to_html "$CONTENT_RAW")
echo "CONTENT first 100 chars: '${CONTENT:0:100}'"

# Prepare tag strings for the template
FIRST_TAG=${CATEGORY}  # Use category as the first tag for simplicity
TAGS_LIST=""
if [[ -n "$CATEGORY" ]]; then
  TAGS_LIST="<span class=\"tag\">$CATEGORY</span>"
fi
echo "FIRST_TAG: '$FIRST_TAG'"
echo "TAGS_LIST: '$TAGS_LIST'"

# Set other defaults
DATE=$(date +'%B %d, %Y')
READING_TIME="5 min read"
AUTHOR_NAME="Siccsegv Team"
AUTHOR_ROLE="Security Researchers"
AUTHOR_BIO="Our team of security researchers and penetration testers share insights from real-world engagements and cutting-edge research."
META_KEYWORDS="cybersecurity, penetration testing, security research"
CANONICAL_URL="https://blog.siccsegv.com/posts/$(basename "$INPUT_FILE" .md).html"
YEAR=$(date +%Y)

echo "DATE: '$DATE'"
echo "READING_TIME: '$READING_TIME'"
echo "AUTHOR_NAME: '$AUTHOR_NAME'"
echo "AUTHOR_ROLE: '$AUTHOR_ROLE'"
echo "CANONICAL_URL: '$CANONICAL_URL'"
echo "YEAR: '$YEAR'"

# Create temporary file for template processing
TEMP_FILE=$(mktemp)
cp _templates/post.html "$TEMP_FILE"

# Use sed to replace placeholders
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

echo "First few lines of processed template:"
head -15 "$TEMP_FILE"

# Move temp file to final location
OUTPUT_FILE="posts/$(basename "$INPUT_FILE" .md).html"
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "Generated: $OUTPUT_FILE"