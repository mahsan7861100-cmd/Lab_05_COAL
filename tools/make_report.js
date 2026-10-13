// Builds Report/Lab05_COAL_Muhammad_Ahsan_FA24-BCS-059.docx from the
// sources, listings and screenshots in HomeTask1..HomeTask4.
// Usage: node tools/make_report.js
const fs = require("fs");
const path = require("path");
const {
  AlignmentType, BorderStyle, Document, Footer, Header, HeadingLevel, ImageRun,
  LevelFormat, PageBreak, PageNumber, Packer, Paragraph, ShadingType, Table,
  TableCell, TableRow, TextRun, WidthType, VerticalAlign,
} = require("docx");

const ROOT = path.resolve(__dirname, "..");
const OUT_DIR = path.join(ROOT, "Report");
const OUT = path.join(OUT_DIR, "Lab05_COAL_Muhammad_Ahsan_FA24-BCS-059.docx");

const STUDENT = "Muhammad Ahsan";
const REG = "FA24-BCS-059";
const TEACHER = "Sir Taimur Shahzad";
const SUBJECT = "COAL";

// A4, 1.8 cm margins
const PAGE_W = 11906, MARGIN = 1020, TEXT_W = PAGE_W - 2 * MARGIN;
const BODY_FONT = "Calibri";
const CODE_FONT = "Consolas";
const ACCENT = "1F4E79";

// ------------------------------------------------------------------ helpers
const read = (p) => fs.readFileSync(path.join(ROOT, p), "utf8").replace(/\r/g, "");

function para(text, opts = {}) {
  const runs = Array.isArray(text) ? text : [new TextRun({ text, ...(opts.run || {}) })];
  return new Paragraph({ children: runs, spacing: { after: 120, line: 276 }, ...opts.p });
}

// inline formatting: `code` and **bold**
function rich(text) {
  const runs = [];
  const re = /(`[^`]+`|\*\*[^*]+\*\*)/g;
  let last = 0, m;
  while ((m = re.exec(text))) {
    if (m.index > last) runs.push(new TextRun(text.slice(last, m.index)));
    const t = m[0];
    if (t.startsWith("`")) runs.push(new TextRun({ text: t.slice(1, -1), font: CODE_FONT, size: 20, color: "8B0000" }));
    else runs.push(new TextRun({ text: t.slice(2, -2), bold: true }));
    last = m.index + t.length;
  }
  if (last < text.length) runs.push(new TextRun(text.slice(last)));
  return runs;
}

const bullet = (text) => new Paragraph({
  children: rich(text), numbering: { reference: "bullets", level: 0 },
  spacing: { after: 80, line: 270 },
});

const h1 = (text, newPage = false) => new Paragraph({ heading: HeadingLevel.HEADING_1, pageBreakBefore: newPage, children: [new TextRun(text)] });
const h2 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });

// ------------------------------------------------- MASM syntax highlighting
const BLUE = new Set(("TITLE INCLUDE .DATA .CODE PROC ENDP END BYTE SBYTE WORD SWORD DWORD SDWORD " +
  "DUP OFFSET TYPE LENGTHOF SIZEOF PTR").split(" "));
const MACRO = new Set(["EXIT"]);

function highlight(line) {
  // split off the comment (a ';' that is not inside a string)
  let q = null, cut = -1;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (q) { if (c === q) q = null; }
    else if (c === '"' || c === "'") q = c;
    else if (c === ";") { cut = i; break; }
  }
  const code = cut >= 0 ? line.slice(0, cut) : line;
  const comment = cut >= 0 ? line.slice(cut) : "";
  const runs = [];
  const push = (text, color, extra = {}) => text && runs.push(new TextRun({ text, font: CODE_FONT, size: 16, color, ...extra }));

  if (/^\s*TITLE\b/i.test(code)) {
    const m = code.match(/^(\s*)(TITLE)(.*)$/i);
    push(m[1], "000000"); push(m[2], "0000FF"); push(m[3], "000000");
  } else {
    const tok = /("[^"]*"|'[^']*'|[.\w$@?]+|\s+|[^\s\w"'.$@?]+)/g;
    let m;
    while ((m = tok.exec(code))) {
      const t = m[0];
      if (t[0] === '"' || t[0] === "'") push(t, "A31515");
      else if (BLUE.has(t.toUpperCase())) push(t, "0000FF");
      else if (MACRO.has(t.toUpperCase())) push(t, "6F008A");
      else push(t, "000000");
    }
  }
  push(comment, "008000");
  if (!runs.length) push(" ", "000000");
  return runs;
}

function codeBlock(source, { numbers = true, plain = false, size = 16, keepTogether = false } = {}) {
  const lines = source.replace(/\s+$/, "").split("\n");
  const width = String(lines.length).length;
  return lines.map((line, i) => {
    const children = [];
    if (numbers) children.push(new TextRun({ text: String(i + 1).padStart(width, " ") + "  ", font: CODE_FONT, size, color: "9A9A9A" }));
    if (plain) children.push(new TextRun({ text: line || " ", font: CODE_FONT, size, color: "000000" }));
    else children.push(...highlight(line.replace(/\t/g, "    ")));
    const border = { style: BorderStyle.SINGLE, size: 4, color: "D0D7DE", space: 4 };
    return new Paragraph({
      children,
      spacing: { before: 0, after: 0, line: 228 },
      shading: { type: ShadingType.CLEAR, color: "auto", fill: "F6F8FA" },
      border: {
        left: border, right: border,
        ...(i === 0 ? { top: border } : {}),
        ...(i === lines.length - 1 ? { bottom: border } : {}),
      },
      indent: { left: 80, right: 80 },
      keepLines: true,
      keepNext: keepTogether && i < lines.length - 1,
    });
  });
}

function figure(file, caption, widthPx = 560) {
  const buf = fs.readFileSync(path.join(ROOT, file));
  const w = buf.readUInt32BE(16), h = buf.readUInt32BE(20);   // PNG IHDR
  const height = Math.round(h * widthPx / w);
  return [
    new Paragraph({
      alignment: AlignmentType.CENTER, keepNext: true, spacing: { before: 120, after: 60 },
      children: [new ImageRun({ type: "png", data: buf, transformation: { width: widthPx, height },
        altText: { title: caption, description: caption, name: path.basename(file) } })],
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER, spacing: { after: 200 },
      children: [new TextRun({ text: caption, italics: true, size: 18, color: "555555" })],
    }),
  ];
}

const cellBorder = { style: BorderStyle.SINGLE, size: 4, color: "BFBFBF" };
const cellBorders = { top: cellBorder, bottom: cellBorder, left: cellBorder, right: cellBorder };

function table(headers, rows, widths, { codeCols = [] } = {}) {
  const total = widths.reduce((a, b) => a + b, 0);
  const mk = (text, col, head) => new TableCell({
    borders: cellBorders,
    width: { size: widths[col], type: WidthType.DXA },
    verticalAlign: VerticalAlign.CENTER,
    shading: head ? { type: ShadingType.CLEAR, color: "auto", fill: "DCE6F1" } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: text.split("\n").map((line) => new Paragraph({
      children: [new TextRun({
        text: line, bold: head,
        font: !head && codeCols.includes(col) ? CODE_FONT : BODY_FONT,
        size: !head && codeCols.includes(col) ? 18 : 20,
      })],
    })),
  });
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: widths,
    rows: [
      new TableRow({ tableHeader: true, children: headers.map((t, i) => mk(t, i, true)) }),
      ...rows.map((r) => new TableRow({ cantSplit: true, children: r.map((t, i) => mk(t, i, false)) })),
    ],
  });
}

// data part of the assembler listing: from ".data" up to the output strings
function listingData(task) {
  const lst = read(`${task}/output/${task}.lst`).split("\n");
  const out = [];
  let on = false;
  for (const l of lst) {
    if (/^[0-9A-F]{8}\s+\.data/.test(l)) { on = true; continue; }
    if (!on) continue;
    if (/strings for the output/.test(l)) break;
    if (/^\s*;/.test(l.slice(32)) || !l.trim()) continue;          // comment-only / blank lines
    out.push(l.replace(/\s*;.*$/, "").replace(/\s+$/, ""));
  }
  return out.join("\n");
}

const spacer = () => new Paragraph({ children: [], spacing: { after: 60 } });

// ---------------------------------------------------------------- content
function taskSection(n, title, statement, answerTable, extraFigures, listing, observations) {
  const task = `HomeTask${n}`;
  const parts = [];
  parts.push(h1(`Home Task ${n}: ${title}`, true));
  parts.push(h2("Task statement"));
  statement.forEach((s) => parts.push(new Paragraph({
    children: [new TextRun({ text: s, font: s.startsWith("  ") ? CODE_FONT : BODY_FONT, size: s.startsWith("  ") ? 19 : 22 })],
    spacing: { after: 40 }, indent: { left: 360 },
  })));
  parts.push(spacer());
  if (answerTable) { parts.push(h2("Declarations (answer)")); parts.push(answerTable); parts.push(spacer()); }

  parts.push(h2(`Source code: ${task}.asm`));
  parts.push(...codeBlock(read(`${task}/${task}.asm`)));
  parts.push(spacer());

  parts.push(h2("Output"));
  parts.push(para(rich(`Console window after running \`${task}.exe\`:`), { p: { keepNext: true } }));
  parts.push(...figure(`${task}/output/${task}_screenshot.png`, `Figure ${n}: Output of ${task}.exe`));
  (extraFigures || []).forEach((f) => parts.push(f));

  if (listing) {
    parts.push(h2("Assembler listing (data section)"));
    parts.push(para(rich("Offset of each variable (left) and the bytes the assembler stored for it. This listing is part of the build output (`" + task + ".lst`)."), { p: { keepNext: true } }));
    parts.push(...codeBlock(listing, { numbers: false, plain: true, keepTogether: true }));
    parts.push(spacer());
  }

  parts.push(h2("Observations"));
  observations.forEach((o) => parts.push(bullet(o)));
  return parts;
}

const t1 = taskSection(1, "Defining Data",
  ["Define the following data in Assembly:",
    "  Sort   BYTE  'y'          ; ASCII of y = 79H",
    "  value  WORD  25159        ; 25159D = 6247H",
    "  total  DWORD 542803535    ; 542803535D = 205A864FH",
    "  marks  DWORD 0, 0, 0, 0, 0, 0, 0, 0",
    "  value1 BYTE  'A'          ; character constant",
    "  value2 BYTE  0            ; smallest unsigned byte",
    "  value3 BYTE  255          ; largest unsigned byte",
    "  value4 SBYTE -128         ; smallest signed byte",
    "  value5 SBYTE +127         ; largest signed byte",
    "  value6 BYTE  ?            ; uninitialized byte"],
  table(["Variable", "Type", "Initializer", "Hex value", "Bytes in memory"],
    [["Sort", "BYTE", "'y'", "79h", "79"],
      ["value", "WORD", "25159", "6247h", "47 62"],
      ["total", "DWORD", "542803535", "205A864Fh", "4F 86 5A 20"],
      ["marks", "DWORD", "0, 0, 0, 0, 0, 0, 0, 0", "8 x 00000000h", "32 x 00"],
      ["value1", "BYTE", "'A'", "41h", "41"],
      ["value2", "BYTE", "0", "00h", "00"],
      ["value3", "BYTE", "255", "FFh", "FF"],
      ["value4", "SBYTE", "-128", "80h", "80"],
      ["value5", "SBYTE", "+127", "7Fh", "7F"],
      ["value6", "BYTE", "? (uninitialized)", "00h", "00"]],
    [1500, 1200, 2700, 2000, 2466], { codeCols: [0, 1, 2, 3, 4] }),
  null, listingData("HomeTask1"),
  ["`Sort` holds the character 'y', stored as its ASCII code **79h** (121 decimal).",
    "`value` = 25159 = **6247h** takes 2 bytes and is stored as `47 62`: x86 is little-endian, so the low-order byte comes first.",
    "`total` = 542803535 = **205A864Fh** takes 4 bytes and is stored as `4F 86 5A 20`.",
    "`marks` is a list of eight doublewords: LENGTHOF = 8 elements, SIZEOF = 32 bytes, all zero.",
    "`value2`/`value3` are the unsigned byte limits 0 (00h) and 255 (FFh); `value4`/`value5` are the signed byte limits -128 (80h in two's complement) and +127 (7Fh).",
    "`value6 BYTE ?` reserves one byte without giving it a value; in the `.data` segment it shows up as 00.",
    "All the variables together use **45 bytes** (`DataSize = ($ - Sort)` = 2Dh). MASM adds no padding, so `value` starts at offset 1 and `total` at offset 3."]);

const t2 = taskSection(2, "Menu Declared as a String",
  ["Create the following menu by declaring a string in Assembly Language.",
    "  Checking Account",
    "  1) Create a new account.",
    "  2) Open an existing account",
    "  3) Credit the account",
    "  4) Debit the account",
    "  5) Exit"],
  null, null, null,
  ["The whole menu is **one** variable, `menu`. A comma at the end of a line continues the same `BYTE` declaration onto the next line.",
    "`0Dh, 0Ah` (carriage return and line feed) after each line moves the cursor to the start of the next line, so a single `WriteString` call prints the complete menu.",
    "The final `0` is the null terminator that `WriteString` needs to know where the string ends.",
    "`SIZEOF menu` = **128 bytes**: 115 visible characters + 6 CR/LF pairs (12 bytes) + 1 null byte."]);

const t3 = taskSection(3, "Arrays",
  ["Create the following arrays in Assembly Language.",
    "  1) Array of ten integers.",
    "  2) Array of 100 characters.",
    "  3) Arrays of 4x3 integers",
    "  4) Array of 4x3x2 integers."],
  table(["#", "Array", "Declaration", "Elements", "Bytes"],
    [["1", "intArray", "DWORD 10 DUP(?)", "10", "40"],
      ["2", "charArray", "BYTE 100 DUP(?)", "100", "100"],
      ["3", "array2D", "DWORD 4 DUP(3 DUP(?))", "4 x 3 = 12", "48"],
      ["4", "array3D", "DWORD 4 DUP(3 DUP(2 DUP(?)))", "4 x 3 x 2 = 24", "96"]],
    [500, 1500, 3900, 2000, 1966], { codeCols: [1, 2] }),
  null, listingData("HomeTask3"),
  ["An integer is a 32-bit `DWORD` (TYPE = 4 bytes) and a character is a `BYTE` (TYPE = 1 byte).",
    "`DUP` repeats an initializer. Nesting it (`4 DUP(3 DUP(?))`) makes the 4 x 3 and 4 x 3 x 2 dimensions visible in the declaration, and `LENGTHOF` counts every element (12 and 24).",
    "Memory is one-dimensional, so multi-dimensional arrays are stored row by row (row-major order). Element [i][j] of the 4 x 3 array is at byte offset (i x 3 + j) x 4; element [i][j][k] of the 4 x 3 x 2 array is at ((i x 3 + j) x 2 + k) x 4. The memory dump of `array2D` (1, 2, 3, ... 12) shows this order.",
    "The listing shows the arrays placed one after another: intArray at 0, charArray at 28h (40), array2D at 8Ch (140) and array3D at BCh (188), which matches their SIZEOF values 40, 100, 48 and 96.",
    "The arrays are declared with `?` (no initial values). The program fills them at run time (10 ... 100, 'A' ... 'Y', 1 ... 12 and 1 ... 24) only so that their contents can be displayed."]);

const t4 = taskSection(4, "C++ Declarations in Assembly",
  ["Implement each of the following declarations in assembly language:",
    "  1) char initial;",
    "  2) char grade = 'B';",
    "  3) char x = 'P', y = 'Q';",
    "  4) int amount;",
    "  5) int count = 0;",
    "  6) int number = -396;"],
  table(["#", "C++ declaration", "Assembly (MASM)", "Size", "Bytes in memory"],
    [["1", "char initial;", "initial BYTE ?", "1 byte", "00"],
      ["2", "char grade = 'B';", "grade BYTE 'B'", "1 byte", "42"],
      ["3", "char x = 'P', y = 'Q';", "x BYTE 'P'\ny BYTE 'Q'", "1 + 1 bytes", "50 51"],
      ["4", "int amount;", "amount SDWORD ?", "4 bytes", "00 00 00 00"],
      ["5", "int count = 0;", "count SDWORD 0", "4 bytes", "00 00 00 00"],
      ["6", "int number = -396;", "number SDWORD -396", "4 bytes", "74 FE FF FF"]],
    [500, 2700, 2600, 1500, 2566], { codeCols: [1, 2, 4] }),
  null, listingData("HomeTask4"),
  ["A C++ `char` is one byte, so it becomes `BYTE`. A C++ `int` is a 32-bit signed integer in Visual C++, so it becomes `SDWORD`.",
    "A declaration with no initial value (`char initial;`, `int amount;`) uses `?` in MASM. It reserves the space without a value, and in the `.data` segment it shows up as 0.",
    "`char x = 'P', y = 'Q';` declares two variables, so it needs two labels: `x` (50h) and `y` (51h).",
    "-396 in 32-bit two's complement is **FFFFFE74h**, stored little-endian as `74 FE FF FF`; `WriteInt` prints it back as -396.",
    "All the declarations together use 16 bytes (`DataSize` = 10h)."]);

// ------------------------------------------------------------- cover page
const coverRows = [
  ["Submitted by", STUDENT],
  ["Registration No.", REG],
  ["Submitted to", TEACHER],
  ["Subject", SUBJECT],
  ["Lab", "Lab 05: Stage v (Verify), Home Activities"],
];
const cover = [
  new Paragraph({ spacing: { before: 2200, after: 200 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "LAB 05", bold: true, size: 64, color: ACCENT })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 120 },
    children: [new TextRun({ text: "Stage v (Verify): Home Activities", size: 32, color: "404040" })] }),
  new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 900 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: ACCENT, space: 12 } },
    children: [new TextRun({ text: "Defining Data, Strings and Arrays in Assembly Language (MASM)", size: 26, italics: true, color: "404040" })] }),
  new Table({
    width: { size: 7000, type: WidthType.DXA }, columnWidths: [2500, 4500], alignment: AlignmentType.CENTER,
    rows: coverRows.map(([k, v]) => new TableRow({ children: [
      new TableCell({ width: { size: 2500, type: WidthType.DXA }, borders: cellBorders,
        shading: { type: ShadingType.CLEAR, color: "auto", fill: "DCE6F1" },
        margins: { top: 100, bottom: 100, left: 160, right: 160 },
        children: [new Paragraph({ children: [new TextRun({ text: k, bold: true, size: 24 })] })] }),
      new TableCell({ width: { size: 4500, type: WidthType.DXA }, borders: cellBorders,
        margins: { top: 100, bottom: 100, left: 160, right: 160 },
        children: [new Paragraph({ children: [new TextRun({ text: v, size: 24 })] })] }),
    ] })),
  }),
  new Paragraph({ children: [new PageBreak()] }),
];

// ---------------------------------------------------------- introduction
const intro = [
  h1("Contents and Setup"),
  para(rich("Each home task is a complete 32-bit MASM program that uses Kip Irvine's **Irvine32** library (the setup used in the lab with Visual Studio). Every program declares the data the task asks for and then prints it, so the output can be checked against the declarations.")),
  table(["Task", "Topic", "Program"],
    [["Home Task 1", "Defining data (BYTE, WORD, DWORD, SBYTE, ?)", "HomeTask1.asm"],
      ["Home Task 2", "A multi-line menu declared as one string", "HomeTask2.asm"],
      ["Home Task 3", "1-D, 2-D and 3-D arrays with DUP", "HomeTask3.asm"],
      ["Home Task 4", "C++ char / int declarations in MASM", "HomeTask4.asm"]],
    [1800, 5500, 2566], { codeCols: [2] }),
  spacer(),
  h2("How the programs were built and run"),
  bullet("Assembler: JWasm v2.21, a MASM-compatible assembler that accepts the same source as Visual Studio's `ml.exe`."),
  bullet("Linker: JWlink, linking each program with `Irvine32.lib`, `Kernel32.lib` and `User32.lib` into a 32-bit Windows console program (`.exe`)."),
  bullet("Run: each `.exe` was started from `cmd.exe` in a Win32 console window (using Wine), and the screenshots show that window."),
  bullet("The same `.asm` files build in Visual Studio with the usual Irvine32 project: add the file to the project and press Ctrl+F5."),
];

// ------------------------------------------------------------- document
const doc = new Document({
  creator: STUDENT,
  title: `Lab 05 - COAL - ${STUDENT} (${REG})`,
  description: "Lab 05 Stage v (Verify) home activities in MASM assembly language",
  styles: {
    default: { document: { run: { font: BODY_FONT, size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, color: ACCENT, font: BODY_FONT },
        paragraph: { spacing: { before: 120, after: 160 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: ACCENT, space: 4 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 25, bold: true, color: "2E75B6", font: BODY_FONT },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 1, keepNext: true } },
    ],
  },
  numbering: {
    config: [{ reference: "bullets", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•",
      alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 270 } } } }] }],
  },
  sections: [{
    properties: {
      page: { size: { width: PAGE_W, height: 16838 }, margin: { top: 1020, bottom: 1020, left: MARGIN, right: MARGIN } },
      titlePage: true,
    },
    headers: {
      default: new Header({ children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "BFBFBF", space: 4 } },
        children: [new TextRun({ text: `Lab 05 | ${SUBJECT} | ${STUDENT} (${REG})`, size: 18, color: "7F7F7F" })],
      })] }),
      first: new Header({ children: [new Paragraph({ children: [] })] }),
    },
    footers: {
      default: new Footer({ children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "Page ", size: 18, color: "7F7F7F" }),
          new TextRun({ children: [PageNumber.CURRENT], size: 18, color: "7F7F7F" }),
          new TextRun({ text: " of ", size: 18, color: "7F7F7F" }),
          new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 18, color: "7F7F7F" })],
      })] }),
      first: new Footer({ children: [new Paragraph({ children: [] })] }),
    },
    children: [...cover, ...intro, ...t1, ...t2, ...t3, ...t4],
  }],
});

fs.mkdirSync(OUT_DIR, { recursive: true });
Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync(OUT, buf);
  console.log("wrote", OUT);
});
