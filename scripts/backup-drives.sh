#!/bin/bash

# Configuration
SOURCE="/mnt/storage/"
DEST="/mnt/backup/mirror/"

# Create destination if it doesn't exist
mkdir -p $DEST

echo "--- Backup Started: $(date) ---"

# rsync command: 
# -a (archive) 
# -v (verbose) 
# -h (human-readable) 
# -z (compress during transfer)
# -x (don't cross filesystem boundaries)
# --delete (remove files at destination that are gone from source)
# --exclude (exclude specific directories, in this case 'lost+found' and '.deleted/')
rsync -avhzx --delete --exclude='lost+found' --exclude='.deleted/' $SOURCE $DEST

echo "--- Backup Finished: $(date) ---"
