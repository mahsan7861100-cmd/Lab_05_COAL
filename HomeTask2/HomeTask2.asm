TITLE Lab 05 - Home Task 2 : Menu String              (HomeTask2.asm)

;--------------------------------------------------------------------
; Name         : Muhammad Ahsan
; Reg. No.     : FA24-BCS-059
; Subject      : COAL
; Submitted to : Sir Taimur Shahzad
; Lab 05       : Stage v (verify) - Home Activities
;
; Home Task 2  : Create the "Checking Account" menu by declaring a
;                single string, then display it with WriteString.
;--------------------------------------------------------------------

INCLUDE Irvine32.inc

.data
;---------- Home Task 2 : the whole menu is ONE string ----------
; A comma at the end of a line continues the same BYTE declaration,
; 0Dh,0Ah (CR, LF) moves to the next line and 0 ends the string.
menu BYTE "Checking Account",0Dh,0Ah,
          "1) Create a new account.",0Dh,0Ah,
          "2) Open an existing account",0Dh,0Ah,
          "3) Credit the account",0Dh,0Ah,
          "4) Debit the account",0Dh,0Ah,
          "5) Exit",0Dh,0Ah,0

;---------------------- strings for the output ----------------------
banner1 BYTE "Lab 05 - Home Task 2 : Menu declared as a string",0
banner2 BYTE "Muhammad Ahsan  |  FA24-BCS-059  |  COAL",0
dashes  BYTE "-------------------------------------------------",0
sSize   BYTE "SIZEOF menu = ",0
sBytes  BYTE " bytes (characters + CR/LF pairs + null terminator)",0

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
    call  Crlf

    ; ---- display the menu (one call, one string) ----
    mov   edx, OFFSET menu
    call  WriteString

    ; ---- size of the string in memory ----
    mov   edx, OFFSET dashes
    call  WriteString
    call  Crlf
    mov   edx, OFFSET sSize
    call  WriteString
    mov   eax, SIZEOF menu
    call  WriteDec
    mov   edx, OFFSET sBytes
    call  WriteString
    call  Crlf

    exit
main ENDP

END main
