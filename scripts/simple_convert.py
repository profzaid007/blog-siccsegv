#!/usr/bin/env python3

import sys
import os
import re
from datetime import date


def convert_markdown_to_html(markdown_text):
    """Simple markdown to HTML conversion"""
    # Escape HTML special characters
    html = (
        markdown_text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#039;")
    )

    # Convert headers
    html = re.sub(
        r"^# (.+)$", r'<h1 class="post-heading">\1</h1>', html, flags=re.MULTILINE
    )
    html = re.sub(r"^## (.+)$", r"<h2>\1</h2>", html, flags=re.MULTILINE)
    html = re.sub(r"^### (.+)$", r"<h3>\1</h3>", html, flags=re.MULTILINE)
    html = re.sub(r"^#### (.+)$", r"<h4>\1</h4>", html, flags=re.MULTILINE)
    html = re.sub(r"^##### (.+)$", r"<h5>\1</h5>", html, flags=re.MULTILINE)
    html = re.sub(r"^###### (.+)$", r"<h6>\1</h6>", html, flags=re.MULTILINE)

    # Convert bold and italic
    html = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", html)
    html = re.sub(r"\*(.+?)\*", r"<em>\1</em>", html)

    # Convert code blocks
    html = re.sub(r"`(.+?)`", r"<code>\1</code>", html)

    # Convert links
    html = re.sub(
        r"\[([^\]]+)\]\(([^)]+)\)",
        r'<a href="\2" target="_blank" rel="noopener noreferrer">\1</a>',
        html,
    )

    # Convert paragraphs (double newline)
    html = re.sub(r"\n\s*\n", "</p><p>", html)
    html = f"<p>{html}</p>"
    html = re.sub(r"<p></p>", "", html)

    return html


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 simple_convert.py <markdown-file>")
        sys.exit(1)

    input_file = sys.argv[1]

    if not os.path.exists(input_file):
        print(f"Error: File '{input_file}' not found")
        sys.exit(1)

    # Extract filename without extension and directory
    basename = os.path.basename(input_file)
    filename_without_ext = os.path.splitext(basename)[0]
    output_file = f"posts/{filename_without_ext}.html"

    # Read the markdown file
    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract title (first line starting with # )
    title_match = re.search(r"^# (.+)$", content, re.MULTILINE)
    title = title_match.group(1) if title_match else "Untitled Post"

    # Extract description (line starting with ## Description:)
    desc_match = re.search(r"^## Description: (.+)$", content, re.MULTILINE)
    description = (
        desc_match.group(1) if desc_match else "Technical insights from Siccsegv Blog"
    )

    # Extract category (line starting with ## Category:)
    cat_match = re.search(r"^## Category: (.+)$", content, re.MULTILINE)
    category = cat_match.group(1) if cat_match else "Uncategorized"

    # Set other defaults
    today = date.today()
    formatted_date = today.strftime("%B %d, %Y")
    reading_time = "5 min read"
    author_name = "Siccsegv Team"
    author_role = "Security Researchers"
    author_bio = "Our team of security researchers and penetration testers share insights from real-world engagements and cutting-edge research."
    meta_keywords = "cybersecurity, penetration testing, security research"
    canonical_url = f"https://blog.siccsegv.com/posts/{filename_without_ext}.html"
    year = today.year

    # Convert markdown to HTML (skip the first 3 lines for title, description, category)
    lines = content.split("\n")
    content_lines = []
    skip_lines = 0
    for line in lines:
        if skip_lines < 3:
            if (
                line.startswith("# ")
                or line.startswith("## Description:")
                or line.startswith("## Category:")
            ):
                skip_lines += 1
            continue
        content_lines.append(line)

    markdown_content = "\n".join(content_lines)
    html_content = convert_markdown_to_html(markdown_content)

    # Prepare tag strings
    first_tag = category
    tags_list = f'<span class="tag">{category}</span>' if category else ""

    # Read the template
    with open("_templates/post.html", "r", encoding="utf-8") as f:
        template = f.read()

    # Replace placeholders
    template = template.replace("{{TITLE}}", title)
    template = template.replace("{{DATE}}", formatted_date)
    template = template.replace("{{READING_TIME}}", reading_time)
    template = template.replace("{{AUTHOR_NAME}}", author_name)
    template = template.replace("{{AUTHOR_ROLE}}", author_role)
    template = template.replace("{{AUTHOR_BIO}}", author_bio)
    template = template.replace("{{META_DESCRIPTION}}", description)
    template = template.replace("{{META_KEYWORDS}}", meta_keywords)
    template = template.replace("{{CANONICAL_URL}}", canonical_url)
    template = template.replace("{{YEAR}}", str(year))
    template = template.replace("{{CATEGORY}}", category)
    template = template.replace("{{CONTENT}}", html_content)
    template = template.replace("{{FIRST_TAG}}", first_tag)
    template = template.replace("{{TAGS_LIST}}", tags_list)

    # Write the output file
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(template)

    print(f"Generated: {output_file}")


if __name__ == "__main__":
    main()
