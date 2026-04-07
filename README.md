# macOS Page Capture OCR Skill

[![Validate](https://github.com/kagshun/macos-page-capture-ocr-skill/actions/workflows/validate.yml/badge.svg)](https://github.com/kagshun/macos-page-capture-ocr-skill/actions/workflows/validate.yml)

macOS 上で、ページ送りできるアプリの画面を連番スクリーンショットとして保存し、その画像群から PDF と OCR テキストを作るための Codex スキルです。

This repository packages a reusable macOS workflow for:

1. capturing paginated on-screen content into ordered screenshots,
2. turning the image set into a PDF, and
3. extracting OCR text into a `.txt` file.

It is designed to be:

- easy to reproduce on a Mac,
- publishable on GitHub,
- usable as a Codex skill,
- based only on built-in macOS technologies such as AppleScript, Vision, PDFKit, `screencapture`, and `sips`.

記事や個人ワークフローの再現だけでなく、「誰でも GitHub から読めて、再利用できる形」に寄せてあります。

## Why this version is better

The original workflow relied on:

- an AppleScript in Script Editor for page turning and screenshots,
- a Finder Quick Action in Shortcuts for OCR extraction.

That works, but it is harder to share because the Shortcuts piece is not easy to version, diff, or publish.

This repo keeps the proven AppleScript capture approach and replaces the OCR/PDF stages with small Swift scripts so the whole workflow is text-based and repository-friendly.

## Requirements

- macOS
- AppleScript / Script Editor
- Swift runtime included with macOS
- Accessibility and Screen Recording permissions for the app that runs the capture script

## Repository layout

```text
macos-page-capture-ocr-skill/
├── README.md
├── LICENSE
└── skill/
    └── macos-page-capture-ocr/
        ├── SKILL.md
        ├── agents/openai.yaml
        ├── references/macos-setup.md
        └── scripts/
            ├── capture_paginated_content.applescript
            ├── images_to_pdf.swift
            ├── ocr_images.swift
            └── process_captured_pages.sh
```

## Quick start

公開用の考え方はシンプルです。

- 画面操作は AppleScript
- PDF 化と OCR は Swift
- 手順説明は README と SKILL に集約
- Shortcuts のような GUI 資産に依存しない

### 1. Prepare permissions

If you plan to run the AppleScript from Script Editor, allow:

- `Script Editor` in `Accessibility`
- `Script Editor` in `Screen Recording`

See [skill/macos-page-capture-ocr/references/macos-setup.md](skill/macos-page-capture-ocr/references/macos-setup.md) for details.

### 2. Configure the capture script

Edit:

- [capture_paginated_content.applescript](skill/macos-page-capture-ocr/scripts/capture_paginated_content.applescript)

The main settings are:

- `pages`
- `target`
- `startPage`
- `pageDirection`
- `pauseTime`
- `cropWidth`
- `cropHeight`
- `resizeWidth`
- `outputFolderPosix`

For clarity:

- `pageDirection = 1` means the script sends Left Arrow to move forward
- `pageDirection = 2` means the script sends Right Arrow to move forward

That naming is deliberate, because labels like `左めくり` and `右めくり` are easy to confuse with the arrow key that actually advances the page.

Set `outputFolderPosix` to an absolute folder path such as:

```applescript
set outputFolderPosix to "/Users/your-username/Desktop/PageCapture"
```

Then either run it in Script Editor or compile it:

```bash
osacompile -o capture-pages.scpt skill/macos-page-capture-ocr/scripts/capture_paginated_content.applescript
```

### 3. Export PDF and OCR text

Run:

```bash
cd skill/macos-page-capture-ocr
./scripts/process_captured_pages.sh "$HOME/Desktop/PageCapture" "export-name" "ja-JP,en-US"
```

This creates:

- `.../exports/export-name.pdf`
- `.../exports/export-name.txt`

## Use as a Codex skill

Copy or symlink [skill/macos-page-capture-ocr](skill/macos-page-capture-ocr) into your local Codex skills directory.

Once installed, invoke it as:

```text
$macos-page-capture-ocr
```

## GitHub setup suggestions

If you want the repository page to look polished, these values work well in GitHub's `About` box.

- Description:
  `Capture paginated macOS app screens into ordered images, then export PDF and OCR text with built-in Apple technologies.`
- Topics:
  `macos`, `applescript`, `ocr`, `pdf`, `vision`, `pdfkit`, `automation`, `codex-skill`

## Legal and practical note

Keep usage limited to material you are authorized to process. This repository is intentionally packaged as a generic macOS page-capture and OCR workflow, not as a redistribution or DRM-circumvention tool.
