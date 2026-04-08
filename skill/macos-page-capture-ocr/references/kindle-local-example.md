# Kindle Local Example

This file gives a concrete starting point when the target app is `Kindle` on macOS.

Use it as a local configuration example, not as the repository's default workflow.

## Recommended starting values

- `target = "Kindle"`
- `pages = 400`
- `startPage = 1`
- `pauseTime = 1.0`
- `filePrefix = "page"`
- `outputFolderPosix = "/Users/your-username/Desktop/KindlePageCapture"`

Meaning of the page counters:

- `startPage` is the starting filename index.
- `pages` is the inclusive ending filename index.
- neither setting makes the Kindle app jump to that page number automatically.

## Forward-page key

The important setting is not `左めくり` or `右めくり` as a label.
The important setting is which arrow key moves the Kindle window to the next page on your Mac.

- `pageDirection = 1` means send Left Arrow
- `pageDirection = 2` means send Right Arrow

If the wrong direction is chosen, the script usually becomes obvious immediately because pages do not advance as expected.

## Practical calibration order

When setting up Kindle locally, calibrate in this order:

1. Open the book in the Kindle app and make the reading area stable.
2. Press Left Arrow manually and check whether it moves forward.
3. Press Right Arrow manually and check whether it moves forward.
4. Set `pageDirection` to the key that actually moves forward.
5. Run a short 5-page capture test before any long run.

## Suggested first test

Set:

```applescript
set pages to 5
set target to "Kindle"
set pageDirection to 2
set pauseTime to 1.0
set outputFolderPosix to "/Users/your-username/Desktop/KindlePageCapture"
```

Then compile and run:

```bash
osacompile -o capture-kindle-local.scpt skill/macos-page-capture-ocr/scripts/capture_kindle_local_example.applescript
```

After that, export PDF and OCR text:

```bash
cd skill/macos-page-capture-ocr
./scripts/process_captured_pages.sh "$HOME/Desktop/KindlePageCapture" "kindle-test" "ja-JP,en-US"
```

## Important note

Keep this workflow limited to material you are authorized to process, and keep the extracted text for personal use only.
