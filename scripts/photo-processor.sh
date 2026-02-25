#! /bin/bash

# Configuration
PHOTO_INBOX="${HOME}/photo-inbox"
TARGET_BASE="/mnt/storage/photo"

# Create the source folder if it doesn't exist
mkdir -p "${PHOTO_INBOX}"

echo "--- Photo Processing Started: $(date) ---"

# exiftool magic:
# -P: preserve file modification date
# -d "%Y": extract only the Year
# '-Directory<${DateTimeOriginal}': Set target dir based on that year
# -ext jpg: only process JPEGs (add -ext png etc. if needed)
exiftool -P -ext jpg -r -d "${TARGET_BASE}/%Y" \
    '-Directory<${DateTimeOriginal}' \
    "${PHOTO_INBOX}"

echo "--- Photo Processing Finished: $(date) ---"
