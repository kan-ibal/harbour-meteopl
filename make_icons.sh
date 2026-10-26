#!/bin/bash
file=harbour-meteopl
mkdir -p icons/hicolor/86x86/apps
cd icons/hicolor/86x86/apps
cp ../../../../$file.png $file.png
magick mogrify $file.png -resize 86x86 $file.png
cd ..
mkdir -p icons/hicolor/108x108/apps
cd icons/hicolor/108x108/apps
cp ../../../$file.png $file.png
magick convert $file.png -resize 108x108 $file.png
cd ..
mkdir -p icons/hicolor/128x128/apps
cd icons/hicolor/128x128/apps
cp ../../../../$file.png $file.png
magick convert $file.png -resize 128x128 $file.png
cd ..
mkdir -p icons/hicolor/172x172/apps
cd icons/hicolor/172x172/apps
cp ../../../../$file.png $file.png
magick convert $file.png -resize 172x172 $file.png
cd ..
mkdir -p icons/hicolor/256x256/apps
cd icons/hicolor/256x256/apps
cp ../../../../$file.png $file.png
magick convert $file.png -resize 256x256 $file.png
cd ..