#!/usr/bin/env python3
"""Run a Win32 console program under Wine inside a pseudo-terminal and
print the console text exactly as it would appear on screen.

Wine's console writes ANSI cursor-control sequences when attached to a
terminal, so the raw bytes are replayed through the pyte terminal emulator
(80 columns wide, like the default Windows console) and the final screen is
printed with trailing blanks removed.

Usage: capture_console.py <program.exe> [stdin-text]
"""
import os
import pty
import select
import subprocess
import sys

import pyte

COLS, ROWS = 80, 300


def run(exe, stdin_text=""):
    master, slave = pty.openpty()
    # tell the program the console is COLS x ROWS
    import fcntl, struct, termios
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", ROWS, COLS, 0, 0))
    env = dict(os.environ, WINEDEBUG="-all")
    proc = subprocess.Popen(["wine", exe], stdin=slave, stdout=slave,
                            stderr=subprocess.DEVNULL, env=env,
                            cwd=os.path.dirname(os.path.abspath(exe)))
    os.close(slave)
    if stdin_text:
        os.write(master, stdin_text.encode())
    raw = b""
    while True:
        r, _, _ = select.select([master], [], [], 0.2)
        if r:
            try:
                chunk = os.read(master, 65536)
            except OSError:
                break
            if not chunk:
                break
            raw += chunk
        elif proc.poll() is not None:
            break
    proc.wait()
    os.close(master)
    return raw, proc.returncode


def render(raw):
    screen = pyte.Screen(COLS, ROWS)
    stream = pyte.ByteStream(screen)
    stream.feed(raw)
    lines = [line.rstrip() for line in screen.display]
    while lines and not lines[-1]:
        lines.pop()
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    raw, rc = run(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "")
    sys.stdout.write(render(raw))
    sys.exit(rc)
