#!/bin/bash

# Generate iOS app icons from SVG
ICON_SVG="assets/icon.svg"
ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
CAIROSVG="/Users/sujie/Library/Python/3.14/bin/cairosvg"

# Function to generate icon
gen_icon() {
  local size=$1
  local output=$2
  $CAIROSVG "$ICON_SVG" -o "$output" --output-width $size --output-height $size
}

# Generate all required sizes
gen_icon 40 "$ICON_DIR/Icon-App-20x20@2x.png"
gen_icon 60 "$ICON_DIR/Icon-App-20x20@3x.png"
gen_icon 29 "$ICON_DIR/Icon-App-29x29@1x.png"
gen_icon 58 "$ICON_DIR/Icon-App-29x29@2x.png"
gen_icon 87 "$ICON_DIR/Icon-App-29x29@3x.png"
gen_icon 80 "$ICON_DIR/Icon-App-40x40@2x.png"
gen_icon 120 "$ICON_DIR/Icon-App-40x40@3x.png"
gen_icon 60 "$ICON_DIR/Icon-App-60x60@2x.png"
gen_icon 180 "$ICON_DIR/Icon-App-60x60@3x.png"
gen_icon 20 "$ICON_DIR/Icon-App-20x20@1x.png"
gen_icon 40 "$ICON_DIR/Icon-App-20x20@2x.png"
gen_icon 29 "$ICON_DIR/Icon-App-29x29@1x.png"
gen_icon 58 "$ICON_DIR/Icon-App-29x29@2x.png"
gen_icon 40 "$ICON_DIR/Icon-App-40x40@1x.png"
gen_icon 80 "$ICON_DIR/Icon-App-40x40@2x.png"
gen_icon 76 "$ICON_DIR/Icon-App-76x76@1x.png"
gen_icon 152 "$ICON_DIR/Icon-App-76x76@2x.png"
gen_icon 167 "$ICON_DIR/Icon-App-83.5x83.5@2x.png"
gen_icon 1024 "$ICON_DIR/Icon-App-1024x1024@1x.png"

echo "All iOS icons generated successfully!"
ls -la "$ICON_DIR"/*.png