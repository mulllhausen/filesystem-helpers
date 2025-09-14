#!/usr/bin/env bash

# first argument or current directory by default
DIR="${1:-.}"

OUT_ALL="all-files.txt"
echo "size sha256 path" > "$OUT_ALL"

echo "building file list with hashes into $OUT_ALL..."
echo "counting the total number of files..."

NUM_TOTAL_FILES=$(find "$DIR" -type f | wc -l)

# print0 - put a null character after each filename to handle spaces/newlines
# empty IFS (Internal Field Separator) = do not separate on spaces, newlines or tabs
# -r = do not allow backslashes to escape characters
# -d '' = read until null character
# output into $filepath
find "$DIR" -type f -print0 | while IFS= read -r -d '' filepath; do

    # -c = custom format
    # %s = file size in bytes
    filesize=$(stat -c%s "$filepath")

    # output to $hash and discard filename with _
    read -r hash _ < <(sha256sum "$filepath")
    
    printf "%s %s %s\n" "$filesize" "$hash" "$filepath" >> "$OUT_ALL"

    count=$((count + 1))
    if (( count % 20 == 0 || count == NUM_TOTAL_FILES )); then
        printf "\rfiles processed: %d / %d" "$count" "$NUM_TOTAL_FILES"
    fi
done

echo "\nall files and their data written to $OUT_ALL"
