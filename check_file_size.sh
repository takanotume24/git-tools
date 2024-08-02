#!/bin/bash
set -euo pipefail

# Force UTF-8 Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Default file size limit (1MB)
DEFAULT_SIZE_MB=1
DEFAULT_SIZE=$(( DEFAULT_SIZE_MB * 1024 * 1024 ))

# Convert size format (e.g., "10M", "1G", "512K") to bytes using numfmt
convert_size_to_bytes() {
  local size=${1}  # Convert to uppercase for numfmt compatibility
  numfmt --from=iec-i --to=none "$size"
}

# Check if size argument is provided
if [ $# -gt 0 ]; then
  MAX_SIZE=$(convert_size_to_bytes "$1")
else
  MAX_SIZE=$DEFAULT_SIZE
fi

# Retrieve list of staged files as an array
mapfile -t files < <(LC_ALL=en_US.UTF-8 git diff --cached --name-only --diff-filter=AM)

# Loop over each file
for file in "${files[@]}"; do
  filepath="$(git rev-parse --show-toplevel)/$file"

  # Check if the file is a submodule
  if git ls-files --stage "$file" | grep -q "^160000"; then
    echo "Skipping: $file is a submodule."
    continue
  fi

  if [ ! -L "$filepath" ] && [ ! -f "$filepath" ]; then
    echo "Error: File does not exist or is not accessible - $file"
    exit 1
  fi

  size=$(stat -c%s "$filepath")

  if ! [ "$size" -eq "$size" ] 2> /dev/null; then
    echo "Error: Could not retrieve file size - $file"
    exit 1
  fi

  if [ "$size" -gt "$MAX_SIZE" ]; then
    echo "Error: The size of $file (${size} bytes) exceeds the limit (${MAX_SIZE} bytes)."
    exit 1
  fi
done

echo "File size check passed"
exit 0
