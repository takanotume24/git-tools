#!/bin/bash
set -euo pipefail

# UTF-8エンコーディングを強制
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
MAX_SIZE=1048576

# ステージされているファイルのリストを配列として取得
mapfile -t files < <(LC_ALL=en_US.UTF-8 git diff --cached --name-only --diff-filter=AM)

# 各ファイルに対してループ
for file in "${files[@]}"; do
  filepath="$(git rev-parse --show-toplevel)/$file"

  if [ ! -f "$filepath" ]; then
    echo "エラー: ファイルが存在しないか、アクセスできません - $file"
    exit 1
  fi

  size=$(stat -c%s "$filepath")

  if ! [ "$size" -eq "$size" ] 2> /dev/null; then
    echo "エラー: ファイルサイズが取得できませんでした - $file"
    exit 1
  fi

  if [ "$size" -gt $MAX_SIZE ]; then
    echo "エラー: $file のサイズが1MBを超えています。"
    exit 1
  fi
done

echo "file size check is passed"
exit 0
