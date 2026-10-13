TITLE Lab 05 - Home Task 3 : Arrays                   (HomeTask3.asm)

;--------------------------------------------------------------------
; Name         : Muhammad Ahsan
; Reg. No.     : FA24-BCS-059
; Subject      : COAL
; Submitted to : Sir Taimur Shahzad
; Lab 05       : Stage v (verify) - Home Activities
;
; Home Task 3  : Create the following arrays in assembly language
;                1) array of ten integers
;                2) array of 100 characters
;                3) array of 4 x 3 integers
;                4) array of 4 x 3 x 2 integers
;                The program shows TYPE / LENGTHOF / SIZEOF of every
;                array, fills the arrays and prints their contents.
;--------------------------------------------------------------------

INCLUDE Irvine32.inc

.data
;------------------ Home Task 3 : array declarations ------------------
intArray  DWORD 10 DUP(?)                    ; 1) ten integers
charArray BYTE  100 DUP(?)                   ; 2) 100 characters
array2D   DWORD 4 DUP(3 DUP(?))              ; 3) 4 x 3 integers
array3D   DWORD 4 DUP(3 DUP(2 DUP(?)))       ; 4) 4 x 3 x 2 integers

;---------------------- strings for the output ----------------------
banner1 BYTE "Lab 05 - Home Task 3 : Arrays in Assembly",0
banner2 BYTE "Muhammad Ahsan  |  FA24-BCS-059  |  COAL",0
dashes  BYTE "-------------------------------------------------------------------",0
header  BYTE "   Array      Declaration                     TYPE  LENGTHOF  SIZEOF",0
hdrLine BYTE "   ---------  ------------------------------  ----  --------  ------",0

dInt    BYTE "1) intArray   DWORD 10 DUP(?)                 ",0
dChar   BYTE "2) charArray  BYTE  100 DUP(?)                ",0
d2D     BYTE "3) array2D    DWORD 4 DUP(3 DUP(?))           ",0
d3D     BYTE "4) array3D    DWORD 4 DUP(3 DUP(2 DUP(?)))    ",0

tInt    BYTE "1) intArray : ten integers (filled with 10, 20, ... 100)",0
tChar   BYTE "2) charArray : 100 characters (4 rows x 25 characters)",0
t2D     BYTE "3) array2D : 4 rows x 3 columns (filled with 1 .. 12)",0
t3D     BYTE "4) array3D : 4 x 3 x 2 (filled with 1 .. 24)",0
n3D     BYTE "   each line is one 3 x 2 block, '|' separates its 3 rows",0
sRow    BYTE "   row ",0
sColon  BYTE " :",0
sBlock  BYTE "   [",0
sBlock2 BYTE "] :",0
sBar    BYTE "  |",0
sIndent BYTE "   ",0
sDump   BYTE "Memory of array2D (12 doublewords stored row after row):",0

.code
main PROC
    ; ---------------- title ----------------
    mov   edx, OFFSET banner1
    call  WriteString
    call  Crlf
    mov   edx, OFFSET banner2
    call  WriteString
    call  Crlf
    mov   edx, OFFSET dashes
    call  WriteString
    call  Crlf

    ; ------- TYPE, LENGTHOF and SIZEOF of every array -------
    mov   edx, OFFSET header
    call  WriteString
    call  Crlf
    mov   edx, OFFSET hdrLine
    call  WriteString
    call  Crlf

    mov   edx, OFFSET dInt
    mov   eax, TYPE intArray
    mov   ebx, LENGTHOF intArray
    mov   ecx, SIZEOF intArray
    call  ShowSizes

    mov   edx, OFFSET dChar
    mov   eax, TYPE charArray
    mov   ebx, LENGTHOF charArray
    mov   ecx, SIZEOF charArray
    call  ShowSizes

    mov   edx, OFFSET d2D
    mov   eax, TYPE array2D
    mov   ebx, LENGTHOF array2D
    mov   ecx, SIZEOF array2D
    call  ShowSizes

    mov   edx, OFFSET d3D
    mov   eax, TYPE array3D
    mov   ebx, LENGTHOF array3D
    mov   ecx, SIZEOF array3D
    call  ShowSizes

    ; ======== 1) intArray : store 10, 20, ... 100 and print ========
    mov   esi, OFFSET intArray
    mov   ecx, LENGTHOF intArray
    mov   eax, 10
F1: mov   [esi], eax
    add   eax, 10
    add   esi, TYPE intArray
    loop  F1

    call  Crlf
    mov   edx, OFFSET tInt
    call  WriteString
    call  Crlf
    mov   edx, OFFSET sIndent
    call  WriteString
    mov   esi, OFFSET intArray
    mov   ecx, LENGTHOF intArray
P1: mov   eax, [esi]
    push  ecx
    mov   ecx, 5                        ; field width
    call  WriteDecRight
    pop   ecx
    add   esi, TYPE intArray
    loop  P1
    call  Crlf

    ; ===== 2) charArray : 4 rows of 'A' .. 'Y' (25 characters each) =====
    mov   esi, OFFSET charArray
    mov   ecx, 4                        ; rows
F2: push  ecx
    mov   al, 'A'
    mov   ecx, 25                       ; characters per row
F2c:mov   [esi], al
    inc   al
    inc   esi
    loop  F2c
    pop   ecx
    loop  F2

    call  Crlf
    mov   edx, OFFSET tChar
    call  WriteString
    call  Crlf
    mov   esi, OFFSET charArray
    mov   ecx, 4
P2: push  ecx
    mov   edx, OFFSET sIndent
    call  WriteString
    mov   ecx, 25
P2c:mov   al, [esi]
    call  WriteChar
    inc   esi
    loop  P2c
    call  Crlf
    pop   ecx
    loop  P2

    ; ===== 3) array2D : fill with 1 .. 12 and print as 4 x 3 =====
    mov   esi, OFFSET array2D
    mov   ecx, LENGTHOF array2D         ; 12 elements
    mov   eax, 1
F3: mov   [esi], eax
    inc   eax
    add   esi, TYPE array2D
    loop  F3

    call  Crlf
    mov   edx, OFFSET t2D
    call  WriteString
    call  Crlf
    mov   esi, OFFSET array2D
    mov   ebx, 0                        ; row number
    mov   ecx, 4                        ; 4 rows
P3: push  ecx
    mov   edx, OFFSET sRow
    call  WriteString
    mov   eax, ebx
    call  WriteDec
    mov   edx, OFFSET sColon
    call  WriteString
    mov   ecx, 3                        ; 3 columns
P3c:mov   eax, [esi]
    push  ecx
    mov   ecx, 5
    call  WriteDecRight
    pop   ecx
    add   esi, TYPE array2D
    loop  P3c
    call  Crlf
    inc   ebx
    pop   ecx
    loop  P3

    ; ===== 4) array3D : fill with 1 .. 24 and print as 4 x (3 x 2) =====
    mov   esi, OFFSET array3D
    mov   ecx, LENGTHOF array3D         ; 24 elements
    mov   eax, 1
F4: mov   [esi], eax
    inc   eax
    add   esi, TYPE array3D
    loop  F4

    call  Crlf
    mov   edx, OFFSET t3D
    call  WriteString
    call  Crlf
    mov   edx, OFFSET n3D
    call  WriteString
    call  Crlf
    mov   esi, OFFSET array3D
    mov   ebx, 0                        ; block number
    mov   ecx, 4                        ; 4 blocks
P4: push  ecx
    mov   edx, OFFSET sBlock
    call  WriteString
    mov   eax, ebx
    call  WriteDec
    mov   edx, OFFSET sBlock2
    call  WriteString
    mov   ecx, 3                        ; 3 rows in a block
P4r:push  ecx
    mov   ecx, 2                        ; 2 columns in a row
P4c:mov   eax, [esi]
    push  ecx
    mov   ecx, 4
    call  WriteDecRight
    pop   ecx
    add   esi, TYPE array3D
    loop  P4c
    pop   ecx
    cmp   ecx, 1                        ; no bar after the last row
    je    P4n
    mov   edx, OFFSET sBar
    call  WriteString
P4n:loop  P4r
    call  Crlf
    inc   ebx
    pop   ecx
    loop  P4

    ; ===== memory layout of array2D (row-major order) =====
    call  Crlf
    mov   edx, OFFSET sDump
    call  WriteString
    call  Crlf
    mov   esi, OFFSET array2D
    mov   ecx, LENGTHOF array2D
    mov   ebx, TYPE array2D
    call  DumpMem

    exit
main ENDP

;--------------------------------------------------------------------
ShowSizes PROC
;
; Prints one row of the TYPE / LENGTHOF / SIZEOF table.
; Receives: EDX = OFFSET of the row label, EAX = TYPE,
;           EBX = LENGTHOF, ECX = SIZEOF
; Returns:  nothing
;--------------------------------------------------------------------
    pushad
    call  WriteString                   ; label + declaration
    push  ecx
    mov   ecx, 4
    call  WriteDecRight                 ; TYPE
    mov   eax, ebx
    mov   ecx, 10
    call  WriteDecRight                 ; LENGTHOF
    pop   eax
    mov   ecx, 8
    call  WriteDecRight                 ; SIZEOF
    call  Crlf
    popad
    ret
ShowSizes ENDP

;--------------------------------------------------------------------
WriteDecRight PROC
;
; Writes the unsigned value in EAX right-aligned in a field that is
; ECX characters wide (leading spaces, then the digits).
; Receives: EAX = value, ECX = field width
; Returns:  nothing (all registers preserved)
;--------------------------------------------------------------------
    pushad
    mov   edi, ecx                      ; field width
    mov   ebx, eax                      ; keep the value
    mov   esi, 10
    mov   ecx, 0                        ; digit counter
WD1:mov   edx, 0
    div   esi                           ; EAX = EAX / 10
    inc   ecx
    cmp   eax, 0
    jne   WD1
    sub   edi, ecx                      ; spaces = width - digits
    jle   WD3
    mov   ecx, edi
    mov   al, ' '
WD2:call  WriteChar
    loop  WD2
WD3:mov   eax, ebx
    call  WriteDec
    popad
    ret
WriteDecRight ENDP

END main
