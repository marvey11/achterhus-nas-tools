#!/bin/bash

# --- CONFIGURATION ---
DROPZONE="/mnt/storage/DropZone"
TARGET_BASE="/mnt/storage/documents"
# LOG="/var/log/achterhus/document-sorter.log"

# --- HELPER FUNCTION ---
# Moves file and verifies integrity before deletion
move_and_verify() {
    local src="$1"
    local t_dir="$2"
    local t_name="$3"
    local t_path="$t_dir/$t_name"

    mkdir -p "$t_dir"
    
    local src_hash=$(sha256sum "$src" | awk '{print $1}')
    cp -p "$src" "$t_path"
    local dest_hash=$(sha256sum "$t_path" | awk '{print $1}')

    if [ "$src_hash" == "$dest_hash" ]; then
        rm "$src"
        echo "[$(date)] SUCCESS: Sorted $(basename "$src") -> $t_path"
    else
        echo "[$(date)] ERROR: Hash mismatch for $(basename "$src")! File left in DropZone."
    fi
}

# --- MAIN LOOP ---
for dir in "$DROPZONE"/*/; do
    [ -d "$dir" ] || continue
    category=$(basename "$dir")

    case "$category" in
        vodafone)
            for file in "$dir"/*.pdf; do
                [ -e "$file" ] || continue
                filename=$(basename "$file")
                # Pattern: YYYY-MM-DD_Rechnung_Kundennr_119518058.pdf
                if [[ $filename =~ ^([0-9]{4})-[0-9]{2}-[0-9]{2}_Rechnung.* ]]; then
                    year="${BASH_REMATCH[1]}"
                    move_and_verify "$file" "$TARGET_BASE/telecom/vodafone.com/$year" "$filename"
                fi
            done
            ;;

        comdirect)
            for file in "$dir"/*.pdf; do
                [ -e "$file" ] || continue
                filename=$(basename "$file")

                # 1. Monthly Financial Reports
                if [[ $filename =~ Finanzreport_Nr\._([0-9]{2})_per_([0-9]{2})\.([0-9]{2})\.([0-9]{4})_.*\.pdf$ ]]; then
                    report_nr="${BASH_REMATCH[1]}"
                    day="${BASH_REMATCH[2]}"
                    month="${BASH_REMATCH[3]}"
                    year="${BASH_REMATCH[4]}"
                    new_name="${year}-${month}-${day}_Finanzreport_Nr_${report_nr}.pdf"
                    move_and_verify "$file" "$TARGET_BASE/finances/comdirect/statements/$year" "$new_name"

                # 2. Securities Documents (Improved to handle 'WKN_' prefix and missing underscores)
                # Group 1: Type | Group 2: optional 'WKN_' | Group 3: WKN | Group 4: Day | Group 5: Month | Group 6: Year
                elif [[ $filename =~ ^([^_]+)_((.*)_)?(WKN_)?([A-Z0-9]{6})_?\(.*\)_vom_([0-9]{2})\.([0-9]{2})\.([0-9]{4})_.*\.pdf$ ]]; then
                    doc_type="${BASH_REMATCH[1]}"
                    wkn="${BASH_REMATCH[3]}"  # Shifted to 3 because (WKN_)? is now 2
                    day="${BASH_REMATCH[4]}"
                    month="${BASH_REMATCH[5]}"
                    year="${BASH_REMATCH[6]}"
                    
                    new_name="${year}-${month}-${day}_${filename}"
                    move_and_verify "$file" "$TARGET_BASE/finances/comdirect/securities/$year/$wkn" "$new_name"
                else
                    echo "[$(date)] INFO: Unmatched document in comdirect: $filename"
                fi
            done
            ;;

        *)
            echo "[$(date)] WARNING: No rules for directory $category. Skipping..."
            ;;
    esac
done
