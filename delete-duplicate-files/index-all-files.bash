#!/usr/bin/env bash

# first argument or current process_directory by default
process_dir="${1:-.}"

output_file="all-files.txt"
echo "size sha256 file-and-path" > "$output_file"

echo "building file list with hashes into $output_file..."
echo "counting the total number of files..."

num_total_files=$(find "$process_dir" -type f | wc -l)

# print0 - put a null character after each filename to handle spaces/newlines
# empty IFS (Internal Field Separator) = do not separate on spaces, newlines or tabs
# -r = do not allow backslashes to escape characters
# -d '' = read until null character
# output into $filepath
find "$process_dir" -type f -print0 | while IFS= read -r -d '' filepath; do

    # -c = custom format
    # %s = file size in bytes
    filesize=$(stat -c%s "$filepath")

    # output to $hash and discard filename with _
    read -r hash _ < <(sha256sum "$filepath")
    
    printf "%s %s %s\n" "$filesize" "$hash" "$filepath" >> "$output_file"

    count_so_far=$((count_so_far + 1))
    if (( count_so_far % 20 == 0 || count_so_far == num_total_files )); then
        printf "\rfiles processed: %d / %d" "$count_so_far" "$num_total_files"
    fi
done

echo
echo "all files and their data were written to $output_file"
