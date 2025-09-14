#!/bin/bash

# process duplicates.txt to create delete-duplicates.bash
output_file="delete-duplicates.bash"
echo "#!/bin/bash" > "$output_file"
echo "" >> "$output_file"

# init
prev_hash=""
files_in_group=()

process_group() {
    if [[ ${#files_in_group[@]} -le 1 ]]; then
        return
    fi

    # keep the original lines but commented out
    for whole_line in "${files_in_group[@]}"; do
        echo "# $whole_line" >> "$output_file"
    done

    # rm all files except the first one in the group
    echo -n "rm" >> "$output_file"
    for ((i=1; i<${#files_in_group[@]}; i++)); do
        filename=$(echo "${files_in_group[i]}" | cut -f3-)
        echo -n " \"$filename\"" >> "$output_file"
    done
    echo "" >> "$output_file"
}

while IFS= read -r line; do
    sha256hash=$(echo "$line" | cut -f2)

    if [[ "$sha256hash" != "$prev_hash" ]]; then
        process_group

        # reset
        files_in_group=()
        prev_hash="$sha256hash"
    fi

    files_in_group+=("$line")

# generate duplicates list
done < <(
    # tail -n +2 = skip the header
    tail -n +2 all-files.txt | \
    # convert to tab-separated values
    # $1 = size
    # $2 = sha256, $3 = path (with spaces)
    # substr($0,index($0,$3)) = get everything from $3 to end of line (full filename)
    awk '{ print $1 "\t" $2 "\t" substr($0,index($0,$3)) }' | \
    # sort by col 2 first (sha256)
    # then "version sort" col 3 (full filename)
    sort -t$'\t' -k2,2 -k3,3V
)

# output the last group
process_group

echo "generated $output_file"
