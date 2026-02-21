function generate_json_report() {
    local STATS_FILE="${HOME}/.achterhus/json/processing_report.json"

    local dir_path
    dir_path=$(dirname "$STATS_FILE")

    # Ensure directory exists
    mkdir -p "$dir_path"

    # Initialize file if missing or empty
    if [ ! -s "$STATS_FILE" ]; then
        echo "[]" > "$STATS_FILE"
    fi

    local timestamp
    timestamp=$(date -Iseconds)

    local total_files=0
    local jq_args=()

    # 1. Calculate Total and build JQ args
    for cat in "${!stats[@]}"; do
        local count="${stats[$cat]}"
        total_files=$((total_files + count))
        jq_args+=(--argjson "$cat" "$count")
    done

    # 2. Build the Category Object (only if total > 0 AND we have args)
    local cat_json="null"
    if [ "$total_files" -gt 0 ] && [ ${#jq_args[@]} -gt 0 ]; then
        cat_json=$(jq -n "${jq_args[@]}" '$ARGS.named')
    fi

    # 3. Atomic Append to the History File
    local tmp_file
    tmp_file=$(mktemp "$STATS_FILE.XXXXXX")

    # Note: Changed $total to $total_count to match the --argjson name
    jq --arg date "$timestamp" \
       --argjson total_count "$total_files" \
       --argjson categories "$cat_json" \
       '. += [{
           "timestamp": $date,
           "total_processed": $total_count
       } + (if $categories != null then { "breakdown": $categories } else {} end)]' \
       "$STATS_FILE" > "$tmp_file" && mv "$tmp_file" "$STATS_FILE"
}
