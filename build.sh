#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cache="$root/.build-cache"
fontawesome="$cache/fontawesome-6.7.2-4"
geist="$cache/geist-font"
tectonic="$cache/tectonic-0.17.0/tectonic"

mkdir -p "$cache" "$root/compiled"
cd "$root"

if [ ! -x "$tectonic" ]; then
  [ "$(uname -s)-$(uname -m)" = Darwin-arm64 ] || {
    echo "Unsupported platform: this script currently bundles Tectonic for macOS arm64." >&2
    exit 1
  }
  archive="$cache/tectonic-0.17.0.tar.gz"
  curl -LfsS https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.17.0/tectonic-0.17.0-aarch64-apple-darwin.tar.gz -o "$archive"
  printf '%s  %s\n' a3f1cac7c5678f01661a92212f58480ae3b0634115d880dbc59e2953ded45667 "$archive" | shasum -a 256 -c
  mkdir -p "$(dirname "$tectonic")"
  tar -xzf "$archive" -C "$(dirname "$tectonic")"
fi

if [ ! -d "$geist/Geist/otf" ]; then
  archive="$cache/geist-font-v1.7.2.zip"
  curl -LfsS https://github.com/vercel/geist-font/releases/download/v1.7.2/geist-font-v1.7.2.zip -o "$archive"
  printf '%s  %s\n' 7fc800d2ac6b92844895196e5041aca55d814c15db70c44f79b3b83ab82b04e2 "$archive" | shasum -a 256 -c
  tar -xf "$archive" -C "$cache"
fi

if [ ! -f "$fontawesome/.ready" ]; then
  archive="$cache/fontawesome-6.7.2-4.tar.gz"
  curl -LfsS https://github.com/braniii/fontawesome/archive/refs/tags/v6.7.2-4.tar.gz -o "$archive"
  printf '%s  %s\n' 529d73ba748acb8ef5b8b5d6444a69c22776a1da031cd22b8dd3b59508f03b2c "$archive" | shasum -a 256 -c
  tar -xzf "$archive" -C "$cache"

  for fd in tufontawesome6free.fd tufontawesome6brands.fd; do
    file="$fontawesome/fontawesome6/tex/$fd"
    sed "s|{FontAwesome|{.build-cache/fontawesome-6.7.2-4/fontawesome6/opentype/FontAwesome|g" "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
  done
  touch "$fontawesome/.ready"
fi

for source in latex/cv/cv.tex latex/resume/resume.tex latex/coverletter/coverletter.tex; do
  TECTONIC_CACHE_DIR="$cache/tectonic-cache" "$tectonic" -X compile "$root/$source" \
    --outdir "$root/compiled" \
    -Z search-path="$root" \
    -Z search-path="$fontawesome/fontawesome6/tex"
done
