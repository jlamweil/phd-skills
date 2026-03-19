---
name: pandoc-setup
description: >
  Use when the user wants to set up or troubleshoot a Pandoc environment for
  converting Markdown to .docx, configure citeproc for bibliography processing,
  set up a reference.docx template, or debug conversion issues. Triggers on
  phrases like "setup pandoc", "markdown to docx", "pandoc setup",
  "docx conversion", "reference template", or "citeproc setup".
---

# Pandoc Environment Setup (Markdown → .docx)

You are helping a researcher set up a Pandoc-based writing workflow that converts Markdown to .docx. Do NOT hardcode paths — detect and configure what's actually needed.

## Step 1: Detect Current State

Before installing anything:

1. **Check Pandoc installation**:
   ```
   which pandoc && pandoc --version
   ```

2. **Check for existing paper files**:
   ```
   ls *.md           # Markdown source files
   ls *.bib          # Bibliography files
   ls reference.docx # Reference template (if any)
   ls template.docx  # Alternative template name
   ```

3. **Check citeproc availability**:
   ```
   pandoc --list-extensions | grep citeproc
   ```

## Step 2: Analyze the Project

Read the main `.md` file to determine requirements:

1. **YAML front matter**: check for existing metadata block (`title`, `author`, `bibliography`, `csl`)
2. **Citation style**: `[@key]` for Pandoc-style citations, check for `.csl` style file
3. **Math usage**: `$inline$` and `$$display$$` syntax
4. **Cross-references**: check for `{#fig:label}` / `@fig:label` patterns (pandoc-crossref)
5. **Required filters**: pandoc-crossref, pandoc-citeproc (built-in since Pandoc 2.11), etc.

## Step 3: Install Missing Components

Based on analysis, install only what's missing:

### On Ubuntu/Debian
```bash
# Pandoc (latest from GitHub releases for best .docx support)
sudo apt install pandoc

# Or for latest version:
# Download from https://github.com/jgm/pandoc/releases
```

### On macOS
```bash
brew install pandoc
```

### Optional filters
```bash
# Cross-references (figures, tables, equations)
pip install pandoc-crossref
# Or: cabal install pandoc-crossref
```

## Step 4: Configure Reference Template

The `reference.docx` controls all styling in the output document:

1. **Generate a default template**:
   ```bash
   pandoc -o reference.docx --print-default-data-file reference.docx
   ```

2. **Customize for venue**: open `reference.docx` in Word/LibreOffice, modify styles:
   - Heading 1, 2, 3 — match venue font/size requirements
   - Body Text — set font, size, spacing per venue guidelines
   - First Paragraph — if venue needs no-indent first paragraphs
   - Caption — for figure/table captions
   - Bibliography — for reference list formatting

3. **Common venue adaptations**:
   | Style property | Typical requirement |
   |---------------|-------------------|
   | Body font | Times New Roman 12pt |
   | Line spacing | Double-spaced for review, single for camera-ready |
   | Margins | 1 inch all sides |
   | Page size | US Letter or A4 depending on venue |

## Step 5: Configure Bibliography

Set up citeproc for citation processing:

1. **Verify .bib file exists** and is valid:
   ```bash
   # Check bib file parses
   pandoc --citeproc --bibliography=refs.bib -t plain /dev/null 2>&1 || echo "bib errors found"
   ```

2. **Choose citation style**: download `.csl` file from [Zotero Style Repository](https://www.zotero.org/styles)
   - IEEE: `ieee.csl`
   - APA: `apa.csl`
   - Chicago: `chicago-author-date.csl`
   - ACM: `acm-sig-proceedings.csl`

3. **Configure YAML front matter** in the `.md` file:
   ```yaml
   ---
   title: "Paper Title"
   author:
     - name: "Author Name"
       affiliation: "University"
   bibliography: refs.bib
   csl: ieee.csl
   ---
   ```

## Step 6: Build Command

Configure the full conversion pipeline:

### Basic conversion
```bash
pandoc paper.md -o paper.docx --reference-doc=reference.docx --citeproc --bibliography=refs.bib
```

### With cross-references
```bash
pandoc paper.md -o paper.docx \
  --reference-doc=reference.docx \
  --citeproc \
  --bibliography=refs.bib \
  --csl=ieee.csl \
  -F pandoc-crossref
```

### Common flags
- `--number-sections` — auto-number sections
- `--toc` — generate table of contents
- `--wrap=none` — prevent line wrapping in output
- `-M link-citations=true` — hyperlink citations to bibliography

## Step 7: Verify Setup

After configuration:

1. Run the full conversion command
2. Open the `.docx` file and check:
   - Title and author metadata appear correctly
   - Citations render as expected (e.g., `[1]` for IEEE, `(Author, 2024)` for APA)
   - Math expressions render (Word equation objects or images)
   - Figures and tables are included with captions
   - Bibliography appears at the end
3. Check for any Pandoc warnings in stderr

## Pandoc-Specific Conventions

### Math syntax
- Inline: `$E = mc^2$` (same as LaTeX)
- Display: `$$\int_0^\infty f(x) dx$$`
- Note: avoid `\begin{align}` — use `$$` blocks with `\aligned` inside

### Citations
- Single: `[@smith2024]`
- Multiple: `[@smith2024; @jones2023]`
- With page: `[@smith2024, p. 42]`
- Suppress author: `[-@smith2024]`
- In-text: `@smith2024 showed that...`

### Cross-references (with pandoc-crossref)
- Figure: `![Caption](image.png){#fig:label}` → reference as `@fig:label`
- Table: `{#tbl:label}` → `@tbl:label`
- Equation: `{#eq:label}` → `@eq:label`
- Section: `{#sec:label}` → `@sec:label`

## Output Format

Produce:
1. **Current state**: what's installed, what's missing
2. **Project requirements**: detected from .md files
3. **Installation commands**: only what's needed, OS-specific
4. **Build command**: the exact pipeline for this project
5. **Verification**: confirm successful conversion to .docx
