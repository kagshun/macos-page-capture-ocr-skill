# macOS Setup And Calibration

## Required Permissions

Before the capture script can control another app and take screenshots, allow the host app you are using to run the script.

If you run from Script Editor:

- `System Settings` -> `Privacy & Security` -> `Accessibility`
- `System Settings` -> `Privacy & Security` -> `Screen Recording`
- enable `Script Editor`

If you run from another launcher, terminal wrapper, or automation app, grant the same permissions to that app instead.

## Capture Calibration

### Target app

Set `target` to the visible macOS app that owns the page-turn shortcut.

Examples:

- `Preview`
- `Books`
- `Kindle`
- another reader or slide app

### Direction

Use:

- `pageDirection = 1` to send Left Arrow
- `pageDirection = 2` to send Right Arrow

This setting means "which key moves forward in the current app". It is intentionally separate from labels such as "left-opening" or "right-opening" books, because those terms are easy to misread.

If the app does not respond, verify the app is focused and test the arrow key manually first.

### Timing

Start with `pauseTime = 1.0`.

Increase it when:

- pages animate before settling,
- images are duplicated,
- the next page is skipped.

### Crop and resize

Keep these at `0` unless the raw capture includes unwanted margins.

- `cropWidth`
- `cropHeight`
- `resizeWidth`

The script applies `sips -c <height> <width>` only when both crop values are non-zero.

## Post-Processing

After capture, prefer the bundled shell wrapper:

```bash
./scripts/process_captured_pages.sh "/path/to/PageCapture" "export-name" "ja-JP,en-US"
```

This creates:

- `<output-directory>/export-name.pdf`
- `<output-directory>/export-name.txt`

## Troubleshooting

### OCR output is empty or poor

- confirm the images are readable outside the script,
- add or change OCR languages,
- crop tighter around the text area,
- increase page rendering delay before capture.

### Output order is wrong

The scripts sort with `localizedStandardCompare`, so zero-padded names such as `page0001.png` are important.

### The app stops responding mid-run

- disable notifications and hot corners,
- keep the reader app frontmost,
- avoid touching the keyboard or trackpad during capture.
