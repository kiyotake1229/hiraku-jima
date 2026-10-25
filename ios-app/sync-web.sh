#!/bin/bash
# 親フォルダのWebアプリ本体を www/ にコピーし、three.js をローカル同梱に書き換える
# （ネイティブアプリは CDN に頼らず完全オフラインで動かすため）
set -e
cd "$(dirname "$0")"
SRC=".."
DEST="www"
THREE_URL="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"
VENDOR="vendor/three.min.js"

rm -rf "$DEST"
mkdir -p "$DEST" vendor

# 同梱するファイルだけをコピー（node_modules や ios など開発物は除外）
for f in index.html manifest.json sw.js icon.svg icon-192.png icon-512.png apple-touch-icon.png; do
  if [ -f "$SRC/$f" ]; then cp "$SRC/$f" "$DEST/"; fi
done

# three.js r128: 初回だけ CDN から取得して vendor/ に保存（2回目以降はオフラインでも同期できる）
if [ ! -s "$VENDOR" ]; then
  echo "three.js を取得中: $THREE_URL"
  curl -fsSL "$THREE_URL" -o "$VENDOR"
fi
cp "$VENDOR" "$DEST/three.min.js"

# CDN の URL をローカル参照に書き換える（index.html の <script src> と sw.js のキャッシュ一覧）
sed -i '' "s#$THREE_URL#three.min.js#g" "$DEST/index.html"
sed -i '' "s#'$THREE_URL'#'./three.min.js'#g" "$DEST/sw.js"

if grep -q "cdnjs.cloudflare.com" "$DEST/index.html"; then
  echo "エラー: index.html に CDN 参照が残っています" >&2
  exit 1
fi

echo "Web資産を www/ にコピーしました（three.js はローカル同梱）:"
ls -1 "$DEST"
