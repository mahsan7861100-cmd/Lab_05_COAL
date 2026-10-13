# Lab 05 (COAL): Stage v (Verify), Home Activities

| | |
|---|---|
| **Name** | Muhammad Ahsan |
| **Reg. No.** | FA24-BCS-059 |
| **Subject** | COAL |
| **Submitted to** | Sir Taimur Shahzad |

The report with the code and output of every task is in
[`Report/Lab05_COAL_Muhammad_Ahsan_FA24-BCS-059.pdf`](Report/Lab05_COAL_Muhammad_Ahsan_FA24-BCS-059.pdf)
(editable Word version: [`.docx`](Report/Lab05_COAL_Muhammad_Ahsan_FA24-BCS-059.docx)).

## Tasks

| Task | What it does | Source | Output |
|---|---|---|---|
| Home Task 1 | Defines `Sort`, `value`, `total`, `marks`, `value1` … `value6` and prints each one in hex and decimal, plus a memory dump | [`HomeTask1.asm`](HomeTask1/HomeTask1.asm) | [screenshot](HomeTask1/output/HomeTask1_screenshot.png) · [text](HomeTask1/output/HomeTask1_output.txt) |
| Home Task 2 | Declares the *Checking Account* menu as a single string and prints it | [`HomeTask2.asm`](HomeTask2/HomeTask2.asm) | [screenshot](HomeTask2/output/HomeTask2_screenshot.png) · [text](HomeTask2/output/HomeTask2_output.txt) |
| Home Task 3 | Declares an array of 10 integers, 100 characters, a 4×3 and a 4×3×2 integer array; prints TYPE / LENGTHOF / SIZEOF and the contents | [`HomeTask3.asm`](HomeTask3/HomeTask3.asm) | [screenshot](HomeTask3/output/HomeTask3_screenshot.png) · [text](HomeTask3/output/HomeTask3_output.txt) |
| Home Task 4 | Implements `char initial;` … `int number = -396;` in MASM and prints the values | [`HomeTask4.asm`](HomeTask4/HomeTask4.asm) | [screenshot](HomeTask4/output/HomeTask4_screenshot.png) · [text](HomeTask4/output/HomeTask4_output.txt) |

Each `output/` folder also contains the assembler listing (`.lst`, showing the
offset and bytes of every variable) and the build log.

## Running in Visual Studio

The programs are standard 32-bit MASM programs for Kip Irvine's **Irvine32**
library. Add one `.asm` file to the usual Irvine32 project (the one with
`Irvine32.inc` and `Irvine32.lib` set up), then press **Ctrl+F5**.

## How the outputs in this repo were produced

* **Assembler:** JWasm v2.21, a MASM-compatible assembler (same syntax as `ml.exe`)
* **Linker:** JWlink, linking with `Irvine32.lib`, `Kernel32.lib` and `User32.lib`
* **Run:** the resulting Win32 console `.exe` was run under Wine. The
  screenshots show the console window, and the text files are the same output
  captured as text.

The helper scripts are in [`tools/`](tools):
`build_and_run.sh` (assemble, link, run, save the listing and output),
`capture_console.py` (capture the console text), `screenshot_console.sh`
(console-window screenshot) and `make_report.js` (builds the Word report).
