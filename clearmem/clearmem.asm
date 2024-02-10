; This is the iNES header (contains a total of 16 bytes with the flags at $7FF0)

.segment "HEADER"
.byte $4E,$45,$53,$1A     ; 4 bytes with the characters 'N', 'E', 'S', '\n'.
.byte $02                 ; How many 16KB of PRG-ROM  we'll use (=32KB).
.byte $01                 ; How many 8KB of CHR-ROM we'll use (=8KB).
.byte %00000000           ; Horizontal mirroring, no battery, mapper 0.
.byte %00000000           ; Mapper 0, playchoice, NES 2.0.
.byte $00                 ; No PRG-RAM.
.byte $00                 ; 0 - NTSC, 1 - PAL. In this case, we're using the NTSC TV format.
.byte $00                 ; NO PRG-RAM. 
.byte $00,$00,$00,$00,$00 ; Unused padding to complete 16 bytes of the iNES header.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

RESET:
    sei                   ; Disable all IRQ interrupts.
    cld                   ; Clears the decimal-mode (even though the NES's Ricoh 6502 does not have it.)
    ldx #$FF              ; Load the literal $FF hexadecimal value to the X register.
    txs                   ; Initialize the stack pointer at $01FF.

    lda #$0               ; A = 0
    inx                   ; X = 0 because it was already $FF before (when initializing the stack pointer) and it overflowed.

ClearRAM:
    sta $0000,x           ; Store the value of A (zero) into $0000 + x (x can go from $0 to $FF)
    sta $0100,x           ; Store the value of A (zero) into $0100 + x (x can go from $0 to $FF)
    sta $0200,x           ; Store the value of A (zero) into $0200 + x (x can go from $0 to $FF)
    sta $0300,x           ; Store the value of A (zero) into $0300 + x (x can go from $0 to $FF)
    sta $0400,x           ; Store the value of A (zero) into $0400 + x (x can go from $0 to $FF)
    sta $0500,x           ; Store the value of A (zero) into $0500 + x (x can go from $0 to $FF)
    sta $0600,x           ; Store the value of A (zero) into $0600 + x (x can go from $0 to $FF)
    sta $0700,x           ; Store the value of A (zero) into $0700 + x (x can go from $0 to $FF)
    inx                   ; X--
    bne ClearRAM          ; If X is not zero, we loop back to the ClearRAM label.

NMI:
    rti ; Return, don't do anything

IRQ:
    rti ; Return, don't do anything

; The vectors are addresses that point to code whenever a specific signal is sent. 
; Basically a callback
.segment "VECTORS" 
; Address of the NMI handler
; Address of the RESET handler
; Address of the IRQ handler
.word NMI
.word RESET
.word IRQ
