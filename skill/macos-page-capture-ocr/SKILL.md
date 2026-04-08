---
name: macos-page-capture-ocr
description: Builds or modernizes macOS workflows that capture paginated on-screen content into ordered screenshots, then convert those images into a PDF and OCR text using AppleScript, Swift, Vision, and PDFKit. Use when recreating screenshot-to-text pipelines, improving reader-app capture flows, or packaging a Mac-only capture/OCR workflow for reuse.
---

# macOS Page Capture OCR

## Overview

Use this skill when the task is to reproduce, improve, or package a macOS workflow that:

1. pages through on-screen content in a desktop app,
2. captures each page as an ordered image,
3. converts the image set into a PDF, and
4. extracts OCR text into a `.txt` file.

This skill keeps the capture step in AppleScript, because GUI automation is easiest there, and moves OCR/PDF generation into small Swift scripts so the workflow is GitHub-friendly and does not depend on a private Shortcuts export.

## When To Use It

Use this skill when the user wants any of the following:

- recover or modernize an old AppleScript screenshot workflow on macOS,
- automate page capture from a paginated reader or viewer app,
- turn captured page images into a PDF and OCR text with built-in macOS tooling,
- publish a reusable Codex skill or GitHub repo for this workflow.

Do not frame the public skill as a DRM-bypass or redistribution tool. Keep the workflow generic and remind the user to use it only with content they are authorized to process.

## Core Workflow

### 1. Gather the minimum runtime inputs

Confirm or infer:

- target app name,
- total page count,
- which arrow key advances to the next page in that app,
- output folder,
- whether cropping or resizing is needed,
- OCR language hints.

If the user is porting an older script, preserve their original knobs where possible. This skill's AppleScript intentionally keeps the familiar fields:

- `pages`
- `target`
- `startPage`
- `pageDirection`
- `pauseTime`
- `cropWidth`
- `cropHeight`
- `resizeWidth`

Treat `pageDirection` as an explicit key mapping, not as a book-binding label:

- `1` means send the Left Arrow key
- `2` means send the Right Arrow key

Be explicit about `startPage`:

- it controls the starting output index in the filename sequence,
- it does not navigate the app to that page number,
- `pages` is the inclusive end index for the loop.

### 2. Prepare macOS permissions

Before running the capture script, make sure the host app has:

- Accessibility permission
- Screen Recording permission

If setup help is needed, read [references/macos-setup.md](references/macos-setup.md).

### 3. Configure or compile the capture script

Start from [scripts/capture_paginated_content.applescript](scripts/capture_paginated_content.applescript).

Preferred pattern:

- edit the config block at the top,
- keep output filenames zero-padded,
- use `key code 123` for left and `124` for right,
- use `screencapture -x` so the workflow stays quiet,
- create the output directory automatically,
- only crop or resize when the values are non-zero,
- do not send an extra page-turn after the final capture.

Compile to `.scpt` when the user wants a double-clickable artifact:

```bash
osacompile -o capture-pages.scpt scripts/capture_paginated_content.applescript
```

### 4. Post-process images with the bundled Swift tools

Prefer the Swift scripts in this skill over Shortcuts when the goal is reproducibility or GitHub publication.

- [scripts/images_to_pdf.swift](scripts/images_to_pdf.swift) builds a PDF from the captured images using `PDFKit`.
- [scripts/ocr_images.swift](scripts/ocr_images.swift) extracts text using `Vision`.
- [scripts/process_captured_pages.sh](scripts/process_captured_pages.sh) runs both in one step.

Typical usage:

```bash
./scripts/process_captured_pages.sh "/path/to/PageCapture" "book-export" "ja-JP,en-US"
```

### 5. Validate outputs

Always verify:

- filenames sort in page order,
- PDF page count matches the captured image count,
- OCR text is non-empty,
- page turn timing is stable with no skipped or duplicated pages.

If the capture is flaky, adjust `pauseTime` before changing anything else.

## Public Packaging Guidance

When packaging this for GitHub:

- use generic names such as "page capture" or "reader app" instead of platform-specific marketing language,
- document permissions and legal-use boundaries clearly,
- prefer source `.applescript` over opaque `.scpt` binaries,
- keep the repo self-contained with built-in macOS dependencies only,
- include a README at the repo root, not inside the skill folder.

## Files In This Skill

- [scripts/capture_paginated_content.applescript](scripts/capture_paginated_content.applescript): Generic page-turn + screenshot capture script derived from the recovered workflow.
- [scripts/images_to_pdf.swift](scripts/images_to_pdf.swift): Converts an image sequence into a PDF.
- [scripts/ocr_images.swift](scripts/ocr_images.swift): OCRs an image sequence into UTF-8 text.
- [scripts/process_captured_pages.sh](scripts/process_captured_pages.sh): Convenience wrapper to run PDF and OCR export together.
- [references/macos-setup.md](references/macos-setup.md): Permissions, calibration, and troubleshooting notes.

## Working Style

When applying this skill in a live task:

1. Keep the workflow generic in public-facing docs.
2. Use the user's concrete app name only in local configuration or private notes when needed.
3. Prefer built-in macOS frameworks over external package installs unless the user explicitly asks for a dependency-based solution.
4. If asked to recover an old `.scpt`, decompile it with `osadecompile` and port the useful settings into the source AppleScript in this skill.
