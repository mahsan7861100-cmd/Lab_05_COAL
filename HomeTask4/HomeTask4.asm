TITLE Lab 05 - Home Task 4 : C++ Declarations in MASM  (HomeTask4.asm)

;--------------------------------------------------------------------
; Name         : Muhammad Ahsan
; Reg. No.     : FA24-BCS-059
; Subject      : COAL
; Submitted to : Sir Taimur Shahzad
; Lab 05       : Stage v (verify) - Home Activities
;
; Home Task 4  : Implement the given C/C++ declarations in assembly
;                language. A char is 1 byte (BYTE) and an int is a
;                32-bit signed integer (SDWORD).
;--------------------------------------------------------------------

INCLUDE Irvine32.inc

.data
;----------------- Home Task 4 : the declarations -----------------
initial BYTE   ?            ; 1) char initial;
grade   BYTE   'B'          ; 2) char grade = 'B';
x       BYTE   'P'          ; 3) char x = 'P', y = 'Q';
y       BYTE   'Q'          ;    (two separate char variables)
amount  SDWORD ?            ; 4) int amount;
count   SDWORD 0            ; 5) int count = 0;
number  SDWORD -396         ; 6) int number = -396;

DataSize = ($ - initial)    ; bytes used by the declarations above

;---------------------- strings for the output ----------------------
banner1 BYTE "Lab 05 - Home Task 4 : C++ declarations in Assembly",0
banner2 BYTE "Muhammad Ahsan  |  FA24-BCS-059  |  COAL",0
dashes  BYTE "------------------------------------------------------------------------------",0
header  BYTE "   C++ declaration         Assembly             Hex        Value",0
hdrLine BYTE "   ----------------------  -------------------  ---------  -----------------",0

lInit   BYTE "1) char initial;           initial BYTE   ?     ",0
lGrade  BYTE "2) char grade = 'B';       grade   BYTE   'B'   ",0
lX      BYTE "3) char x = 'P', y = 'Q';  x       BYTE   'P'   ",0
lY      BYTE "                           y       BYTE   'Q'   ",0
lAmount BYTE "4) int amount;             amount  SDWORD ?     ",0
lCount  BYTE "5) int count = 0;          count   SDWORD 0     ",0
lNumber BYTE "6) int number = -396;      number  SDWORD -396  ",0

sOpen   BYTE "'",0
sAscii  BYTE "'  (ASCII ",0
sClose  BYTE ")",0
sUninit BYTE "  (uninitialized)",0
sDump   BYTE "Memory dump of the declarations (",0
sDump2  BYTE " bytes, little-endian):",0

.code
main PROC
    ; ---- title ----
    mov   edx, OFFSET banner1
    call  WriteString
    call  Crlf
    mov   edx, OFFSET banner2
    call  WriteString
    call  Crlf
    mov   edx, OFFSET dashes
    call  WriteString
    call  Crlf
    mov   edx, OFFSET header
    call  WriteString
    call  Crlf
    mov   edx, OFFSET hdrLine
    call  WriteString
    call  Crlf

    ; ---- 1) char initial; ----
    mov   edx, OFFSET lInit
    call  WriteString
    movzx eax, initial
    mov   ebx, TYPE initial
    call  ShowHex
    call  WriteDec
    mov   edx, OFFSET sUninit
    call  WriteString
    call  Crlf

    ; ---- 2) char grade = 'B'; ----
    mov   edx, OFFSET lGrade
    call  WriteString
    movzx eax, grade
    mov   ebx, TYPE grade
    call  ShowHex
    call  ShowChar
    call  Crlf

    ; ---- 3) char x = 'P', y = 'Q'; ----
    mov   edx, OFFSET lX
    call  WriteString
    movzx eax, x
    mov   ebx, TYPE x
    call  ShowHex
    call  ShowChar
    call  Crlf

    mov   edx, OFFSET lY
    call  WriteString
    movzx eax, y
    mov   ebx, TYPE y
    call  ShowHex
    call  ShowChar
    call  Crlf

    ; ---- 4) int amount; ----
    mov   edx, OFFSET lAmount
    call  WriteString
    mov   eax, amount
    mov   ebx, TYPE amount
    call  ShowHex
    call  WriteInt
    mov   edx, OFFSET sUninit
    call  WriteString
    call  Crlf

    ; ---- 5) int count = 0; ----
    mov   edx, OFFSET lCount
    call  WriteString
    mov   eax, count
    mov   ebx, TYPE count
    call  ShowHex
    call  WriteInt
    call  Crlf

    ; ---- 6) int number = -396; ----
    mov   edx, OFFSET lNumber
    call  WriteString
    mov   eax, number
    mov   ebx, TYPE number
    call  ShowHex
    call  WriteInt                      ; -396
    call  Crlf

    ; ---- memory dump of all the declarations ----
    call  Crlf
    mov   edx, OFFSET sDump
    call  WriteString
    mov   eax, DataSize
    call  WriteDec
    mov   edx, OFFSET sDump2
    call  WriteString
    call  Crlf
    mov   esi, OFFSET initial           ; starting address
    mov   ecx, DataSize                 ; number of units
    mov   ebx, TYPE BYTE                ; unit size = 1 byte
    call  DumpMem

    exit
main ENDP

;--------------------------------------------------------------------
ShowHex PROC
;
; Writes EAX in hexadecimal using EBX bytes (1, 2 or 4), adds the
; suffix 'h' and pads with spaces so that the next column always
; starts at the same position.
; Receives: EAX = value, EBX = size of the value in bytes
; Returns:  nothing (EAX, EBX and ECX are preserved)
;--------------------------------------------------------------------
    push  eax
    push  ecx
    call  WriteHexB                     ; 2, 4 or 8 hex digits
    mov   al, 'h'
    call  WriteChar
    mov   ecx, 10                       ; spaces = 10 - 2 * size
    sub   ecx, ebx
    sub   ecx, ebx
    mov   al, ' '
SH1:call  WriteChar
    loop  SH1
    pop   ecx
    pop   eax
    ret
ShowHex ENDP

;--------------------------------------------------------------------
ShowChar PROC
;
; Writes the character in AL as  'C'  (ASCII nn)
; Receives: EAX = character code (0..255)
; Returns:  nothing
;--------------------------------------------------------------------
    push  edx
    push  eax
    mov   edx, OFFSET sOpen
    call  WriteString
    call  WriteChar                     ; the character itself
    mov   edx, OFFSET sAscii
    call  WriteString
    call  WriteDec                      ; its ASCII code
    mov   edx, OFFSET sClose
    call  WriteString
    pop   eax
    pop   edx
    ret
ShowChar ENDP

END main
