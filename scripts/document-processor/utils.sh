# Moves file and verifies integrity before deletion
function move_and_verify() {
    local src="$1"
    local t_dir="$2"
    local t_name="$3"
    local t_path="$t_dir/$t_name"

    mkdir -p "$t_dir" || return 1
    
    # If the copy fails, stop here and return an error
    if ! cp -p "$src" "$t_path"; then
        echo "[$(date)] ERROR: Failed to copy $src to $t_path"
        return 1
    fi

    local src_hash
    local dest_hash
    
    src_hash=$(sha256sum "$src" | awk '{print $1}')
    dest_hash=$(sha256sum "$t_path" | awk '{print $1}')

    if [ "$src_hash" == "$dest_hash" ]; then
        rm "$src"
        echo "[$(date)] SUCCESS: Sorted $(basename "$src") -> $t_path"
        return 0
    else
        # Critical: Remove the corrupted/incomplete copy so we don't have bad data
        rm -f "$t_path"        echo "[$(date)] ERROR: Hash mismatch for $(basename "$src")! File left in DropZone."
        return 1
    fi
}

# Calculates the total and provides a breakdown.
function generate_summary() {
    local total
    
    total=0
    
    echo -e "\n--- Processing Summary ($(date)) ---"
    printf "%-15s | %-10s\n" "Category" "Count"
    echo "------------------------------------------"
    
    # Sort categories alphabetically for the report
    for cat in $(echo "${!stats[@]}" | tr ' ' '\n' | sort); do
        printf "%-15s | %-10s\n" "$cat" "${stats[$cat]}"
        ((total += stats[cat]))
    done
    
    echo "------------------------------------------"
    printf "%-15s | %-10s\n" "TOTAL" "$total"
    echo -e "--- End of Report ---\n"
}
