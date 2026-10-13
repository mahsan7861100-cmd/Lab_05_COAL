TITLE Lab 05 - Home Task 1 : Defining Data            (HomeTask1.asm)

;--------------------------------------------------------------------
; Name         : Muhammad Ahsan
; Reg. No.     : FA24-BCS-059
; Subject      : COAL
; Submitted to : Sir Taimur Shahzad
; Lab 05       : Stage v (verify) - Home Activities
;
; Home Task 1  : Define the given data in assembly language, then
;                display every variable in hexadecimal and decimal
;                and dump the memory that holds all of them.
;--------------------------------------------------------------------

INCLUDE Irvine32.inc

.data
;------------------ Home Task 1 : data definitions ------------------
Sort    BYTE   'y'                      ; ASCII of y = 79H
value   WORD   25159                    ; 25159D = 6247H
total   DWORD  542803535                ; 542803535D = 205A864FH
marks   DWORD  0, 0, 0, 0, 0, 0, 0, 0   ; array of eight doublewords
value1  BYTE   'A'                      ; character constant
value2  BYTE   0                        ; smallest unsigned byte
value3  BYTE   255                      ; largest unsigned byte
value4  SBYTE  -128                     ; smallest signed byte
value5  SBYTE  +127                     ; largest signed byte
value6  BYTE   ?                        ; uninitialized byte

DataSize = ($ - Sort)                   ; bytes used by the data above

;---------------------- strings for the output ----------------------
banner1 BYTE "Lab 05 - Home Task 1 : Defining Data in Assembly",0
banner2 BYTE "Muhammad Ahsan  |  FA24-BCS-059  |  COAL",0
dashes  BYTE "-------------------------------------------------",0
header  BYTE "Variable  Type    Hex          Decimal",0
hdrLine BYTE "--------  ------  -----------  ----------------",0

lSort   BYTE "Sort      BYTE    ",0
lValue  BYTE "value     WORD    ",0
lTotal  BYTE "total     DWORD   ",0
lMarks  BYTE "marks     DWORD   ",0
lValue1 BYTE "value1    BYTE    ",0
lValue2 BYTE "value2    BYTE    ",0
lValue3 BYTE "value3    BYTE    ",0
lValue4 BYTE "value4    SBYTE   ",0
lValue5 BYTE "value5    SBYTE   ",0
lValue6 BYTE "value6    BYTE    ",0

sOpen   BYTE "  ('",0
sClose  BYTE "')",0
sEach   BYTE "8 elements   ",0
sMarks1 BYTE "LENGTHOF = ",0
sMarks2 BYTE ", SIZEOF = ",0
sMarks3 BYTE " bytes",0
sUninit BYTE "  (uninitialized ?)",0
sDump   BYTE "Memory dump of all the variables above (",0
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

    ; ---- Sort  BYTE 'y' ----
    mov   edx, OFFSET lSort
    call  WriteString
    movzx eax, Sort
    mov   ebx, TYPE Sort
    call  ShowHex
    call  WriteDec                      ; 121
    mov   edx, OFFSET sOpen
    call  WriteString
    call  WriteChar                     ; y
    mov   edx, OFFSET sClose
    call  WriteString
    call  Crlf

    ; ---- value  WORD 25159 ----
    mov   edx, OFFSET lValue
    call  WriteString
    movzx eax, value
    mov   ebx, TYPE value
    call  ShowHex
    call  WriteDec
    call  Crlf

    ; ---- total  DWORD 542803535 ----
    mov   edx, OFFSET lTotal
    call  WriteString
    mov   eax, total
    mov   ebx, TYPE total
    call  ShowHex
    call  WriteDec
    call  Crlf

    ; ---- marks  DWORD 0,0,0,0,0,0,0,0 ----
    mov   edx, OFFSET lMarks
    call  WriteString
    mov   edx, OFFSET sEach
    call  WriteString
    mov   esi, OFFSET marks
    mov   ecx, LENGTHOF marks           ; 8 elements
L1: mov   eax, [esi]
    call  WriteDec
    mov   al, ' '
    call  WriteChar
    add   esi, TYPE marks
    loop  L1
    call  Crlf

    ; LENGTHOF and SIZEOF of marks
    mov   ecx, 31                       ; indent to the Decimal column
L2: mov   al, ' '
    call  WriteChar
    loop  L2
    mov   edx, OFFSET sMarks1
    call  WriteString
    mov   eax, LENGTHOF marks
    call  WriteDec
    mov   edx, OFFSET sMarks2
    call  WriteString
    mov   eax, SIZEOF marks
    call  WriteDec
    mov   edx, OFFSET sMarks3
    call  WriteString
    call  Crlf

    ; ---- value1  BYTE 'A' ----
    mov   edx, OFFSET lValue1
    call  WriteString
    movzx eax, value1
    mov   ebx, TYPE value1
    call  ShowHex
    call  WriteDec                      ; 65
    mov   edx, OFFSET sOpen
    call  WriteString
    call  WriteChar                     ; A
    mov   edx, OFFSET sClose
    call  WriteString
    call  Crlf

    ; ---- value2  BYTE 0 ----
    mov   edx, OFFSET lValue2
    call  WriteString
    movzx eax, value2
    mov   ebx, TYPE value2
    call  ShowHex
    call  WriteDec
    call  Crlf

    ; ---- value3  BYTE 255 ----
    mov   edx, OFFSET lValue3
    call  WriteString
    movzx eax, value3
    mov   ebx, TYPE value3
    call  ShowHex
    call  WriteDec
    call  Crlf

    ; ---- value4  SBYTE -128 (signed, so use MOVSX and WriteInt) ----
    mov   edx, OFFSET lValue4
    call  WriteString
    movsx eax, value4
    mov   ebx, TYPE value4
    call  ShowHex
    call  WriteInt
    call  Crlf

    ; ---- value5  SBYTE +127 ----
    mov   edx, OFFSET lValue5
    call  WriteString
    movsx eax, value5
    mov   ebx, TYPE value5
    call  ShowHex
    call  WriteInt
    call  Crlf

    ; ---- value6  BYTE ? ----
    mov   edx, OFFSET lValue6
    call  WriteString
    movzx eax, value6
    mov   ebx, TYPE value6
    call  ShowHex
    call  WriteDec
    mov   edx, OFFSET sUninit
    call  WriteString
    call  Crlf

    ; ---- memory dump of every byte defined above ----
    call  Crlf
    mov   edx, OFFSET sDump
    call  WriteString
    mov   eax, DataSize
    call  WriteDec
    mov   edx, OFFSET sDump2
    call  WriteString
    call  Crlf
    mov   esi, OFFSET Sort              ; starting address
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
    mov   ecx, 12                       ; spaces = 12 - 2 * size
    sub   ecx, ebx
    sub   ecx, ebx
    mov   al, ' '
SH1:call  WriteChar
    loop  SH1
    pop   ecx
    pop   eax
    ret
ShowHex ENDP

END main
