#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SDK="${AE_SDK_ROOT:?Set AE_SDK_ROOT to your licensed Adobe After Effects SDK}"
CXX="${MINGW_CXX:-x86_64-w64-mingw32-g++}"
WINDRES="${MINGW_WINDRES:-x86_64-w64-mingw32-windres}"
if [[ ! -d "$SDK/Headers" ]]; then echo "Missing AE SDK headers: $SDK/Headers" >&2; exit 2; fi
command -v "$CXX" >/dev/null || { echo "Missing $CXX" >&2; exit 2; }
command -v "$WINDRES" >/dev/null || { echo "Missing $WINDRES" >&2; exit 2; }
mkdir -p "$ROOT/build"
"$WINDRES" --target=pe-x86-64 "$ROOT/pipl/RB_ASCII.rc" -O coff -o "$ROOT/build/RB_ASCII-res.o"
"$CXX" -std=c++17 -O2 -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-asynchronous-unwind-tables \
  -D_WINDOWS -DWIN_ENV=1 -DRB_ASCII_UI_TRACE=0 -DRB_ASCII_HOST_TRACE=0 \
  -I"$SDK/Headers" -I"$SDK/Headers/SP" -I"$SDK" -I"$SDK/Util" -I"$ROOT/src" \
  -c "$ROOT/src/RB_ASCIIWin.cpp" -o "$ROOT/build/RB_ASCIIWin.o"
"$CXX" -std=c++17 -O2 -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-asynchronous-unwind-tables \
  -D_WINDOWS -DWIN_ENV=1 -DRB_ASCII_UI_TRACE=0 -DRB_ASCII_HOST_TRACE=0 \
  -I"$SDK/Headers" -I"$SDK/Headers/SP" -I"$SDK" -I"$SDK/Util" -I"$ROOT/src" \
  -shared -static -static-libgcc -static-libstdc++ -Wl,--no-insert-timestamp \
  -Wl,--subsystem,windows -Wl,--export-all-symbols \
  -o "$ROOT/build/RB_ASCII.aex" "$ROOT/build/RB_ASCIIWin.o" "$ROOT/build/RB_ASCII-res.o" -lgdi32 -luser32
python3 "$ROOT/patch_private_crt.py" "$ROOT/build/RB_ASCII.aex"
file "$ROOT/build/RB_ASCII.aex"
shasum -a 256 "$ROOT/build/RB_ASCII.aex"
