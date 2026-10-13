#!/usr/bin/env bash
# Take a real screenshot of a home task running in a Win32 console window.
#
# The program is started from cmd.exe inside a Wine virtual desktop on a
# headless X server (Xvfb); the command is typed with xdotool and the
# finished console window is captured with ImageMagick's `import`.
#
# Usage: tools/screenshot_console.sh HomeTask1 <console-rows>
# Needs: WINEPREFIX (with HomeTaskN.exe copied to C:\COAL\Lab05), Xvfb,
#        xdotool, ImageMagick, python3 + Pillow
set -euo pipefail

task="$1"
rows="$2"
root="$(cd "$(dirname "$0")/.." && pwd)"
png="$root/$task/output/${task}_screenshot.png"
export DISPLAY="${DISPLAY:-:99}"

pgrep -x Xvfb >/dev/null || { Xvfb "$DISPLAY" -screen 0 1400x1400x24 >/dev/null 2>&1 & sleep 2; }
wineserver -k 2>/dev/null || true
sleep 1

# console window: 80 columns x <rows> rows
wine reg add 'HKCU\Console' /v WindowSize /t REG_DWORD /d "$(printf '0x%04x0050' "$rows")" /f >/dev/null 2>&1
wine reg add 'HKCU\Console' /v ScreenBufferSize /t REG_DWORD /d 0x012c0050 /f >/dev/null 2>&1

cd "$WINEPREFIX/drive_c/COAL/Lab05"
wine explorer /desktop=Lab05,1400x1400 wineconsole cmd >/dev/null 2>&1 &
for _ in $(seq 60); do
    xdotool search --name 'cmd.exe' >/dev/null 2>&1 && break
    sleep 1
done
sleep 3

xdotool type --delay 40 "cls"
xdotool key Return
sleep 1
xdotool type --delay 40 "$task.exe"
xdotool key Return
sleep 6

raw="$(mktemp --suffix=.png)"
import -window root "$raw"

# crop to the console window: everything that is not the desktop colour
python3 - "$raw" "$png" <<'EOF'
import sys
from PIL import Image, ImageChops
img = Image.open(sys.argv[1]).convert("RGB")
w, h = img.size
img = img.crop((0, 0, w, h - 30))                 # drop the Wine taskbar
bg = Image.new("RGB", img.size, img.getpixel((img.width - 1, img.height - 1)))
box = ImageChops.difference(img, bg).getbbox()
img.crop(box).save(sys.argv[2])
EOF
rm -f "$raw"
wineserver -k 2>/dev/null || true
echo "saved $png"
