#!/usr/bin/env bash
#
# Crops game card scans to the card template size and exports them as PNGs.
#
# Each source scan is an A4 page (JPG) with the card placed in the top-left
# corner. This crops every scan to the card size at the scan's DPI, from the
# top-left corner, then resizes the crop to the final 260x416px card template
# size, exporting the result as a PNG.
#
# The crop size is derived from the --dpi flag, scaled from a baseline of
# 260x426px at 150 DPI (i.e. a 1246x1752px A4 scan).
#
# Usage:
#   ./tools/crop-cards.sh --input <input-dir> --output <output-dir> [--dpi <dpi>]
#
# Example:
#   ./tools/crop-cards.sh --input ~/Downloads/input --output ~/Downloads/output --dpi 300

set -euo pipefail

usage() {
    echo "Usage: $0 --input <input-dir> --output <output-dir> [--dpi <dpi>]" >&2
    exit 1
}

input_dir=
output_dir=
dpi=

while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            input_dir=$2
            shift 2
            ;;
        --output)
            output_dir=$2
            shift 2
            ;;
        --dpi)
            dpi=$2
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z $input_dir || -z $output_dir ]]; then
    usage
fi

baseline_dpi=150
baseline_crop_width=260
baseline_crop_height=426
resize_width=260
resize_height=416

dpi=${dpi:-$baseline_dpi}

crop_width=$(awk -v w="$baseline_crop_width" -v dpi="$dpi" -v base="$baseline_dpi" 'BEGIN { printf "%.0f", w * dpi / base }')
crop_height=$(awk -v h="$baseline_crop_height" -v dpi="$dpi" -v base="$baseline_dpi" 'BEGIN { printf "%.0f", h * dpi / base }')

if ! command -v magick >/dev/null 2>&1; then
    echo "Could not find 'magick' on PATH. Install ImageMagick or open a new terminal so PATH picks it up." >&2
    exit 1
fi

if [[ ! -d $input_dir ]]; then
    echo "Input directory not found: $input_dir" >&2
    exit 1
fi

mkdir -p "$output_dir"

shopt -s nullglob
scans=("$input_dir"/*.jpg)
shopt -u nullglob

if [[ ${#scans[@]} -eq 0 ]]; then
    echo "Warning: No .jpg files found in $input_dir" >&2
    exit 0
fi

for scan in "${scans[@]}"; do
    filename=$(basename "$scan")
    output_path="$output_dir/${filename%.jpg}.png"

    if ! magick "$scan" \
        -crop "${crop_width}x${crop_height}+0+0" \
        +repage \
        -resize "${resize_width}x${resize_height}!" \
        "$output_path"; then
        echo "Warning: Failed to process $filename" >&2
        continue
    fi

    echo "$filename -> $output_path"
done
