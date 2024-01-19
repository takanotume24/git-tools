#!/bin/bash
set -euo pipefail

# Force UTF-8 Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
MAX_SIZE=1048576

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

  if [ ! -f "$filepath" ]; then
    echo "Error: File does not exist or is not accessible - $file"
    exit 1
  fi

  size=$(stat -c%s "$filepath")

  if ! [ "$size" -eq "$size" ] 2> /dev/null; then
    echo "Error: Could not retrieve file size - $file"
    exit 1
  fi

  if [ "$size" -gt $MAX_SIZE ]; then
    echo "Error: The size of $file exceeds 1MB."
    exit 1
  fi
done

echo "File size check passed"
exit 0
