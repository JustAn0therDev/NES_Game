.include "consts.inc"
.include "header.inc"
.include "reset.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

.proc LoopPalette
	ldy #0
LoopPalette:
	lda PaletteData, y    ; Load the A register with the value in the exact memory region where we keep the color palette bytes.
	sta PPU_DATA          ; Load the PPU_DATA register with the value that is inside the A register.
	iny                   ; Increment Y
	cpy #32               ; Compare it to 32, it being the last byte we want to access before reaching the end of the color palette.
	bne LoopPalette       ; If not equal, loop back to the LoopPalette label.
	
	rts
.endproc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset handler (called when the NES resets or powers on)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset:
	INIT_NES

Main:
	ldx #$3F              ; Store the value #$3F into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the hi-byte
	
	ldx #$00              ; Store the value #$00 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the lo-byte
	
	jsr LoopPalette       ; Jump to the subroutine that fills the color palette in the PPU
		
	ldx #%00011110        ; Load the value #%00011110 into X.
	stx PPU_MASK          ; Load the value in X into the PPU_MASK register, allowing the background to be rendered.
NMI:
    rti ; Return, don't do anything

IRQ:
    rti ; Return, don't do anything

PaletteData:
.byte $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A ; Background
.byte $0F, $10, $00, $26, $0F, $10, $00, $26, $0F, $10, $00, $26, $0F, $10, $00, $26 ; Sprite

; The vectors are addresses that point to code whenever a specific signal is sent. 
; Basically a callback
.segment "VECTORS" 
; Address of the NMI handler
; Address of the RESET handler
; Address of the IRQ handler
.word NMI
.word Reset
.word IRQ
