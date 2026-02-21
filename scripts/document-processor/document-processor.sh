#!/bin/bash

# --- CONFIGURATION ---
DROPZONE="/mnt/storage/DropZone"

TARGET_BASE="/mnt/storage/documents"
export TARGET_BASE

# Enable associative arrays
declare -A stats
export stats

workdir="$(dirname "$0")"
source "$workdir/utils.sh"

processor_dir="$workdir/processor.d"
for proc in "$processor_dir"/*.sh; do
    [ -e "$proc" ] || continue
    # shellcheck source=./processor.d/comdirect.sh
    # shellcheck source=./processor.d/vodafone.sh
    source "$proc"
done

# --- MAIN LOOP ---
for dir in "$DROPZONE"/*/; do
[ -d "$dir" ] || continue
    category=$(basename "$dir")
    processor="process_${category}"
    
    # Initialize count for this category
    stats["$category"]=0

    if declare -f "$processor" > /dev/null; then
        for file in "$dir"/*.pdf; do
            [ -e "$file" ] || continue
            
            # Execute processor and increment count if successful
            if "$processor" "$file"; then
                ((stats["$category"]++))
            fi
        done
    else
        echo "[$(date)] WARNING: No processor found for $category."
    fi
done

generate_summary
