#!/bin/zsh

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
skill_root="$repo_root/skill/macos-page-capture-ocr"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

input_dir="$tmp_root/input"
output_dir="$tmp_root/output"
module_cache_dir="$tmp_root/module-cache"

mkdir -p "$input_dir" "$output_dir" "$module_cache_dir"

python3 "$repo_root/tests/generate_sample_images.py" "$input_dir" >/dev/null

SWIFT_MODULE_CACHE_PATH="$module_cache_dir" "$skill_root/scripts/process_captured_pages.sh" "$input_dir" "integration-test" "en-US" "$output_dir" >/dev/null

pdf_path="$output_dir/integration-test.pdf"
txt_path="$output_dir/integration-test.txt"

[[ -s "$pdf_path" ]]
[[ -s "$txt_path" ]]

grep -qi "page" "$txt_path"
grep -Eqi "alha|alpha|theta|beta" "$txt_path"

printf 'Integration test passed: %s %s\n' "$pdf_path" "$txt_path"
