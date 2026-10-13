#!/usr/bin/env bash
# Assemble, link and run one home task, saving the listing file and the
# console output next to the source.
#
#   Assembler : JWasm  (MASM-compatible; same syntax as Visual Studio's ml.exe)
#   Linker    : JWlink (produces a Win32 PE console .exe)
#   Library   : Kip Irvine's Irvine32.lib / Kernel32.lib / User32.lib
#   Runtime   : Wine (runs the Win32 .exe on Linux)
#
# Usage: tools/build_and_run.sh HomeTask1
# Needs: JWASM_BIN, JWLINK_BIN and IRVINE environment variables (paths), wine, python3+pyte
set -euo pipefail

task="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/$task"
out="$dir/output"
mkdir -p "$out"

: "${JWASM_BIN:?set JWASM_BIN to the jwasm binary}"
: "${JWLINK_BIN:?set JWLINK_BIN to the jwlink binary}"
: "${IRVINE:?set IRVINE to the folder holding Irvine32.inc/.lib}"

build="$(mktemp -d)"
trap 'rm -rf "$build"' EXIT

# 1) assemble (COFF object + listing file)
"$JWASM_BIN" -nologo -coff -I"$IRVINE" -Fo"$build/$task.obj" -Fl"$out/$task.lst" \
    "$dir/$task.asm" | tee "$out/${task}_build.txt"

# 2) link with Irvine32
"$JWLINK_BIN" format windows pe runtime console file "$build/$task.obj" \
    libpath "$IRVINE" library Irvine32.lib,kernel32.lib,user32.lib \
    name "$build/$task.exe" op quiet | tee -a "$out/${task}_build.txt"
echo "Linked $task.exe ($(stat -c %s "$build/$task.exe") bytes)" | tee -a "$out/${task}_build.txt"
cp "$build/$task.exe" "$out/$task.exe"

# 3) run and capture the console text
python3 "$root/tools/capture_console.py" "$out/$task.exe" > "$out/${task}_output.txt"
cat "$out/${task}_output.txt"
