; This is the iNES header (contains a total of 16 bytes with the flags at $7FF0)

.segment "HEADER"
.org $7FF0
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
.org $8000                ; This is where the PRG-ROM starts in the cartridge.

; PPU Constants
PPU_MASK = $2001
PPU_ADDR = $2006
PPU_DATA = $2007

RESET:
	sei                   ; Disable all IRQ interrupts.
	cld                   ; Clears the decimal-mode (even though the NES's Ricoh 6502 does not have it.)
	ldx #$FF              ; Load the literal $FF hexadecimal value to the X register.
	txs                   ; Initialize the stack pointer at $01FF.

	lda #$0               ; A = 0
	inx                   ; X = 0 because it was already $FF before (when initializing the stack pointer) and it overflowed.
	
	lda #%00011110        ; Store the value 00011110 into the A register.
	sta PPU_MASK          ; Store the value in the A register into the PPU_MASK register located at $2001
	
	ldy #$00			  ; Store the value #$0000 into the Y register.

MemLoop:
	sta $0,x              ; Store the value of A (zero) into $0+X
	dex                   ; X--
	bne MemLoop           ; If X is not zero, we loop back to the MemLoop label.

PaintBlack:
	ldx #$3F              ; Store the value #$3F into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the hi-byte
	
	ldx #$00              ; Store the value #$00 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the lo-byte

	lda #$00              ; Load the value #$00 into the A register.
	sta PPU_DATA          ; Set the PPU_DATA with the value in the A register. In this case, the color black


PaintWhite:
	ldx #$3F              ; Store the value #$3F into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the hi-byte
	
	ldx #$00              ; Store the value #$00 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the lo-byte

	lda #$FF              ; Load the value #$00 into the A register.
	sta PPU_DATA          ; Set the PPU_DATA with the value in the A register. In this case, the color white

	jmp PaintBlack        ; Jump to the PaintBlack subroutine again, making it loop

NMI:
	rti ; Return, don't do anything

IRQ:
	rti ; Return, don't do anything

; The vectors are addresses that point to code whenever a specific signal is sent. 
; Basically a callback
.segment "VECTORS" 
.org $FFFA
; Address of the NMI handler
; Address of the RESET handler
; Address of the IRQ handler
.word NMI
.word RESET
.word IRQ

