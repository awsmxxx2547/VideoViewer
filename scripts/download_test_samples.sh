#!/bin/bash

SAMPLES_DIR="tests/integration/test_samples/"
mkdir -p "$SAMPLES_DIR"

declare -A sample_videos=(
  ["sample1.mp4"]="https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4"
  ["sample2.mp4"]="https://sample-videos.com/video321/mp4/480/big_buck_bunny_480p_1mb.mp4"
  ["sample3.mp4"]="https://sample-videos.com/video321/mp4/360/big_buck_bunny_360p_1mb.mp4"
)

for filename in "${!sample_videos[@]}"; do
  if [ ! -f "$SAMPLES_DIR/$filename" ]; then
    echo "Downloading $filename..."
    wget -q "${sample_videos[$filename]}" -O "$SAMPLES_DIR/$filename"
  else
    echo "$filename already exists, skipping..."
  fi
done

echo "Test samples ready in $SAMPLES_DIR"

