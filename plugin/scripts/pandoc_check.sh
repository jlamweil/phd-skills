#!/usr/bin/env bash
# PostToolUse hook: auto-convert .md after edits to catch Pandoc errors early
# Reads tool result from stdin JSON, checks if the edited file is .md.
# If yes, runs pandoc conversion and reports any errors.
# Non-blocking: exit 0 always so the edit goes through regardless.

set -uo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the file path from the tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

if [ -z "$file_path" ]; then
    exit 0
fi

# Only process .md files
case "$file_path" in
    *.md) ;;
    *) exit 0 ;;
esac

# Skip files that are clearly not paper content (e.g., README, SKILL, CLAUDE)
basename_file=$(basename "$file_path")
case "$basename_file" in
    README.md|SKILL.md|CLAUDE.md|CHANGELOG.md|CONTRIBUTING.md) exit 0 ;;
esac

# Check if pandoc is available
if ! command -v pandoc &>/dev/null; then
    exit 0
fi

# Get the directory of the edited file
md_dir=$(dirname "$file_path")

# Look for a reference doc template
ref_doc=""
for template in "$md_dir"/reference.docx "$md_dir"/template.docx; do
    if [ -f "$template" ]; then
        ref_doc="--reference-doc=$template"
        break
    fi
done

# Look for bibliography file
bib_flag=""
for bib in "$md_dir"/*.bib; do
    if [ -f "$bib" ]; then
        bib_flag="--citeproc --bibliography=$bib"
        break
    fi
done

# Run pandoc conversion to a temp file with a short timeout
tmp_out=$(mktemp /tmp/pandoc_check_XXXXXX.docx)
output=$(cd "$md_dir" && timeout 30 pandoc "$file_path" -o "$tmp_out" $ref_doc $bib_flag 2>&1) || true
exit_code=$?
rm -f "$tmp_out"

# Check for errors in the output
if [ -n "$output" ]; then
    # Pandoc writes warnings/errors to stderr which we captured
    errors=$(echo "$output" | head -20)
    echo "{\"decision\": \"allow\", \"reason\": \"PANDOC CONVERSION WARNING after editing $basename_file:\\n$errors\\n\\nFix the Markdown/Pandoc issue before it compounds with further edits.\"}"
else
    exit 0
fi
