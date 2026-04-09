#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import struct
import sys
import zlib


GLYPHS = {
    "A": ["00100", "01010", "10001", "11111", "10001", "10001", "10001"],
    "B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    "E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    "G": ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
    "H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
    "L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    "N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    "O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    "P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    "W": ["10001", "10001", "10001", "10101", "10101", "10101", "01010"],
    " ": ["00000", "00000", "00000", "00000", "00000", "00000", "00000"],
}

PAGES = [
    ("page0001.png", "ALPHA PAGE ONE"),
    ("page0002.png", "BETA PAGE TWO"),
]


def write_chunk(handle, chunk_type: bytes, data: bytes) -> None:
    handle.write(struct.pack(">I", len(data)))
    handle.write(chunk_type)
    handle.write(data)
    crc = zlib.crc32(chunk_type)
    crc = zlib.crc32(data, crc)
    handle.write(struct.pack(">I", crc & 0xFFFFFFFF))


def encode_png(path: pathlib.Path, width: int, height: int, pixels: bytearray) -> None:
    raw = bytearray()
    stride = width * 3
    for row in range(height):
        raw.append(0)
        start = row * stride
        raw.extend(pixels[start : start + stride])

    with path.open("wb") as handle:
        handle.write(b"\x89PNG\r\n\x1a\n")
        write_chunk(handle, b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        write_chunk(handle, b"IDAT", zlib.compress(bytes(raw), level=9))
        write_chunk(handle, b"IEND", b"")


def draw_text(text: str, scale: int = 28, margin_x: int = 120, margin_y: int = 420) -> tuple[int, int, bytearray]:
    glyph_width = 5
    glyph_height = 7
    letter_gap = scale
    width = 1800
    height = 1200
    pixels = bytearray([255] * width * height * 3)

    cursor_x = margin_x
    cursor_y = margin_y

    for char in text:
        glyph = GLYPHS[char]
        for row_index, row_bits in enumerate(glyph):
            for col_index, bit in enumerate(row_bits):
                if bit != "1":
                    continue
                for dy in range(scale):
                    for dx in range(scale):
                        x = cursor_x + col_index * scale + dx
                        y = cursor_y + row_index * scale + dy
                        offset = (y * width + x) * 3
                        pixels[offset : offset + 3] = b"\x00\x00\x00"
        cursor_x += glyph_width * scale + letter_gap

    return width, height, pixels


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python3 tests/generate_sample_images.py <output-directory>", file=sys.stderr)
        return 1

    output_dir = pathlib.Path(sys.argv[1])
    output_dir.mkdir(parents=True, exist_ok=True)

    for file_name, text in PAGES:
        width, height, pixels = draw_text(text)
        encode_png(output_dir / file_name, width, height, pixels)

    print(output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
