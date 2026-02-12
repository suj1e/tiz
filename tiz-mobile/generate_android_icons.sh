#!/bin/bash

# Generate Android app icons from SVG
ICON_SVG="assets/icon.svg"
# Android adaptive icon
ICON_DIR_RES="android/app/src/main/res"
ICON_DIR_MIPMAP="$ICON_DIR_RES/mipmap-anydpi-v26"

CAIROSVG="/Users/sujie/Library/Python/3.14/bin/cairosvg"

# Function to generate icon
gen_icon() {
  local size=$1
  local output=$2
  $CAIROSVG "$ICON_SVG" -o "$output" --output-width $size --output-height $size
}

# Create directories if they don't exist
mkdir -p "$ICON_DIR_MIPMAP"

# Generate foreground for adaptive icon
gen_icon 108 "$ICON_DIR_MIPMAP/ic_launcher_foreground.png"

# Generate legacy icons
for dpi in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  case $dpi in
    mdpi)
      size=48
      mipmap="mipmap-mdpi"
      ;;
    hdpi)
      size=72
      mipmap="mipmap-hdpi"
      ;;
    xhdpi)
      size=96
      mipmap="mipmap-xhdpi"
      ;;
    xxhdpi)
      size=144
      mipmap="mipmap-xxhdpi"
      ;;
    xxxhdpi)
      size=192
      mipmap="mipmap-xxxhdpi"
      ;;
  esac

  mkdir -p "$ICON_DIR_RES/$mipmap"
  gen_icon $size "$ICON_DIR_RES/$mipmap/ic_launcher.png"
done

# Generate play store icon
gen_icon 512 "$ICON_DIR_RES/drawable-nodpi/ic_launcher_play_store.png"

echo "Android icons generated successfully!"
