#!/bin/sh

# スクリプトの言語設定をUTF-8に設定
export LANG=C.UTF-8

# 最大ファイルサイズを1MBとする
MAX_SIZE=1048576

# ステージされている新規追加または修正されたファイルをチェック
LC_ALL=C git diff --cached --name-only --diff-filter=AM | while read -r file; do
  # ファイルの絶対パスを取得
  filepath=$(git rev-parse --show-toplevel)/"$file"

  # ファイルサイズを取得
  size=$(stat -c%s "$filepath")

  # ファイルサイズが最大サイズを超えている場合
  if [ "$size" -gt $MAX_SIZE ]; then
    echo "$file のサイズが1MBを超えています。"
    exit 1
  fi
done

# すべてのチェックが通ればcommitを許可
echo "file size check is passed"
exit 0
