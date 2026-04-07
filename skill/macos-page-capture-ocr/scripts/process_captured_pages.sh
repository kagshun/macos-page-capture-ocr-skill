#!/bin/zsh

set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  cat <<'EOF' >&2
Usage:
  ./process_captured_pages.sh <input-directory> <base-name> [languages] [output-directory]

Examples:
  ./process_captured_pages.sh ~/Desktop/PageCapture book-export
  ./process_captured_pages.sh ~/Desktop/PageCapture book-export ja-JP,en-US
  ./process_captured_pages.sh ~/Desktop/PageCapture book-export ja-JP,en-US ~/Desktop/Exports
EOF
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
input_dir="$1"
base_name="$2"
languages="${3:-ja-JP,en-US}"
output_dir="${4:-$input_dir/exports}"

mkdir -p "$output_dir"

pdf_output="$output_dir/$base_name.pdf"
txt_output="$output_dir/$base_name.txt"

swift "$script_dir/images_to_pdf.swift" "$input_dir" --output "$pdf_output"
swift "$script_dir/ocr_images.swift" "$input_dir" --output "$txt_output" --languages "$languages"

printf 'PDF: %s\n' "$pdf_output"
printf 'TXT: %s\n' "$txt_output"
