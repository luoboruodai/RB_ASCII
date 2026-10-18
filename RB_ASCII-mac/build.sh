#!/bin/zsh
# Build a universal Apple Silicon + Intel After Effects effect plug-in.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SDK="${AE_SDK_ROOT:?Set AE_SDK_ROOT to your licensed Adobe After Effects SDK}"
if [[ ! -d "$SDK/Headers" ]]; then
  echo "Missing AE SDK headers: $SDK/Headers" >&2
  exit 2
fi

REZ_ROOT="${AE_REZ_ROOT:-$SDK/Headers}"
if [[ ! -f "$REZ_ROOT/AE_General.r" ]]; then
  echo "Set AE_REZ_ROOT to the SDK directory containing AE_General.r" >&2
  exit 2
fi

# Embed the UI helper from a single source of truth (also usable as a JSX file).
python3 - "$ROOT" <<'PYGEN'
import sys
from pathlib import Path
root=Path(sys.argv[1])
js=(root/'scripts/RB_ASCIIStyleLibrary.jsx').read_text()
assert ')CW_JS"' not in js
(root/'scripts/RB_ASCII Styles Manager.jsx').write_text(js+'\n$.global.CWStyleLibrary.showManager((typeof Panel!==\'undefined\' && this instanceof Panel)?this:null);\n')
(root/'src/StyleLibraryScript.inc').write_text('// Generated from scripts/RB_ASCIIStyleLibrary.jsx by build.sh.\nstatic const char kStyleLibraryScript[] = R"CW_JS('+js+')CW_JS";\n')
PYGEN

mkdir -p "$ROOT/build"
STAGE="$(mktemp -d "$ROOT/build/candidate.XXXXXX")"
OUT="$STAGE/RB_ASCII.plugin"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"

Rez -useDF -o "$OUT/Contents/Resources/RB_ASCII.rsrc" \
  -I "$ROOT/pipl" -I "$SDK/Headers" -I "$REZ_ROOT" \
  "$ROOT/pipl/RB_ASCIIPiPL.r"
cp "$ROOT/Info.plist" "$OUT/Contents/Info.plist"
cp "$ROOT/scripts/RB_ASCII Styles Manager.jsx" "$OUT/Contents/Resources/RB_ASCII Styles Manager.jsx"
printf 'eFKTFXTC' > "$OUT/Contents/PkgInfo"

for ARCH in arm64 x86_64; do
  MIN_OS=10.15
  [[ "$ARCH" == arm64 ]] && MIN_OS=11.0
  clang++ -std=c++17 -O2 -fobjc-arc -fvisibility=hidden -Wno-pragma-pack \
    -arch "$ARCH" -mmacosx-version-min="$MIN_OS" -DRB_ASCII_UI_TRACE="${RB_ASCII_UI_TRACE:-0}" -bundle \
    -I"$SDK/Headers" -I"$SDK/Headers/SP" -I"$SDK" -I"$SDK/Util" \
    -o "$STAGE/RB_ASCII.$ARCH" "$ROOT/src/RB_ASCII.mm" \
    -framework AppKit -framework CoreServices -framework Carbon -framework ApplicationServices
done
lipo -create "$STAGE/RB_ASCII.arm64" "$STAGE/RB_ASCII.x86_64" \
  -output "$OUT/Contents/MacOS/RB_ASCII"

lipo "$OUT/Contents/MacOS/RB_ASCII" -verify_arch arm64 x86_64
if command -v DeRez >/dev/null 2>&1; then
  DeRez -useDF "$OUT/Contents/Resources/RB_ASCII.rsrc" | grep -q '6D61 3634'
  DeRez -useDF "$OUT/Contents/Resources/RB_ASCII.rsrc" | grep -q '6D69 3634'
fi
codesign -s - --force "$OUT" >/dev/null
codesign --verify --deep --strict "$OUT"
file "$OUT/Contents/MacOS/RB_ASCII"
if [[ -d "$ROOT/build/RB_ASCII.plugin" ]]; then
  mv "$ROOT/build/RB_ASCII.plugin" "$STAGE/previous-RB_ASCII.plugin"
fi
mv "$OUT" "$ROOT/build/RB_ASCII.plugin"
echo "built: $ROOT/build/RB_ASCII.plugin"
echo "previous build and thin binaries retained in: $STAGE"
