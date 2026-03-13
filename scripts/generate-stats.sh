#!/bin/bash

# Script to generate statistics for the categories page
# Usage: ./generate-stats.sh

set -euo pipefail

# Directory containing blog markdown files
BLOGS_DIR="blogs"
# Output file to update (the categories.html file)
OUTPUT_FILE="categories.html"
# The stats section is between <pre class="stats-output"> and </pre>

# Initialize variables
declare -A category_count
declare -A post_dates
total_posts=0
total_reading_time=0
min_reading_time=9999   # Start with a high number
max_reading_time=0

# Process each markdown file in the blogs directory
for file in "$BLOGS_DIR"/*.md; do
    # Skip if no files match the pattern
    [[ ! -f "$file" ]] && continue

    # Extract category (line starting with ## Category:)
    category_line=$(grep -m 1 "^## Category:" "$file" || true)
    category=$(echo "$category_line" | cut -d':' -f2- | xargs)  # xargs trims whitespace

    # Extract date (line starting with ## Date:)
    date_line=$(grep -m 1 "^## Date:" "$file" || true)
    date_str=$(echo "$date_line" | cut -d':' -f2- | xargs)

    # If date is not found in frontmatter, try to get it from the file's modification time
    if [[ -z "$date_str" ]]; then
        # Use the file's modification time in YYYY-MM-DD format
        date_str=$(date -r "$file" +%Y-%m-%d)
    fi

    # Extract reading time (line starting with ## Reading Time:)
    reading_time_line=$(grep -m 1 "^## Reading Time:" "$file" || true)
    # Extract just the number (e.g., "5 min read" -> 5)
    reading_time=$(echo "$reading_time_line" | cut -d':' -f2- | grep -o '[0-9]*' || echo "0")

    # If we couldn't extract a category, skip the file (or use a default)
    if [[ -z "$category" ]]; then
        category="Uncategorized"
    fi

    # Initialize the category count if not set
    if [[ -z ${category_count[$category]+x} ]]; then
        category_count[$category]=0
    fi
    ((category_count["$category"]++))
    post_dates["$file"]="$date_str"
    ((total_posts++))
    # Only add to total if we got a number
    if [[ "$reading_time" =~ ^[0-9]+$ ]]; then
        total_reading_time=$((total_reading_time + reading_time))
        # Update min and max
        if (( reading_time < min_reading_time )); then
            min_reading_time=$reading_time
        fi
        if (( reading_time > max_reading_time )); then
            max_reading_time=$reading_time
        fi
    fi
done

# If no posts were found, set defaults to avoid division by zero
if [[ $total_posts -eq 0 ]]; then
    total_posts=0
    total_categories=0
    most_active_category="None"
    most_active_count=0
    most_recent_title="No posts"
    formatted_date="N/A"
    avg_reading_time=0
    min_reading_time=0
    max_reading_time=0
else
    # Calculate total categories (unique categories)
    total_categories=${#category_count[@]}

    # Find the most active category
    most_active_category=""
    most_active_count=0
    for cat in "${!category_count[@]}"; do
        count=${category_count[$cat]}
        if (( count > most_active_count )); then
            most_active_count=$count
            most_active_category="$cat"
        fi
    done

    # Find the most recent post
    most_recent_date="1970-01-01"
    most_recent_file=""
    for file in "${!post_dates[@]}"; do
        if [[ "${post_dates[$file]}" > "$most_recent_date" ]]; then
            most_recent_date="${post_dates[$file]}"
            most_recent_file="$file"
        fi
    done

    # Extract the title from the most recent file (first line starting with # )
    most_recent_title=$(grep -m 1 "^# " "$most_recent_file" | sed 's/^# //' || echo "Untitled")
    # Format the date for display (e.g., Mar 13, 2026)
    formatted_date=$(date -d "$most_recent_date" +"%b %d, %Y")

    # Calculate average reading time (rounded down)
    avg_reading_time=$(( total_posts > 0 ? total_reading_time / total_posts : 0 ))
fi

# Format the reading time for display
if [[ $min_reading_time -eq $max_reading_time ]]; then
    reading_time_display="${min_reading_time} min"
else
    reading_time_display="${min_reading_time}-${max_reading_time} min"
fi

# Format the stats output to match the existing block
stats_output=$(cat << EOF
┌─────────────────────────────────────────────────────┐
│                  CONTENT OVERVIEW                    │
├─────────────────────────────────────────────────────┤
│  Total Categories:        $total_categories                         │
│  Total Articles:          $total_posts                         │
│  Most Active:             $most_active_category ($most_active_count)            │
│  Most Recent:             $most_recent_title                │
│                                                      │
│  Publishing Frequency:    Variable              │
│  Average Read Time:       $reading_time_display             │
│                                                      │
│  [*] All content peer-reviewed by security experts  │
└─────────────────────────────────────────────────────┘

$ _
EOF
)

# Update the stats section in the output file
# We'll replace the content between <pre class="stats-output"> and the next </pre>
# using sed with a range address.
sed -i "/<pre class=\"stats-output\">/,/<\/pre>/{
    /<pre class=\"stats-output\">/ {
        # Replace the entire block from the opening tag to the closing tag
        # with the new stats output, but keep the tags.
        c\\
<pre class=\"stats-output\">\\
$stats_output\\
</pre>
    }
}" "$OUTPUT_FILE"

echo "Statistics updated in $OUTPUT_FILE"