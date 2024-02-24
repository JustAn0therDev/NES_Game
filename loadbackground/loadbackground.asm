.include "consts.inc"
.include "header.inc"
.include "reset.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

;; Load color palette
.proc LoopPalette
	ldy #0
LoopPalette:
	lda PaletteData, y    ; Load the A register with the value in the exact memory region where we keep the color palette bytes.
	sta PPU_DATA          ; Load the PPU_DATA register with the value that is inside the A register.
	iny                   ; Increment Y
	cpy #32               ; Compare it to 32, it being past the last byte we want to access before reaching the end of the color palette.
	bne LoopPalette       ; If not equal, loop back to the LoopPalette label.
	rts
.endproc

;; Load background tiles
.proc LoopBackground
	ldy #0
LoopBackground:
	lda BackgroundData, y       ; Load the A register with the value in the exact memory region where we keep the background data bytes.
	sta PPU_DATA                ; Load the PPU_DATA register with the value that is inside the A register.
	iny                         ; Increment Y
	cpy #$FF                    ; Compare it to $FF, it being past the last byte we want to access before reaching the end of the background.
	bne LoopBackground          ; If not equal, loop back to the LoopBackground label.
	rts
.endproc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset handler (called when the NES resets or powers on)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset:
	INIT_NES

Main:
	bit PPU_STATUS        ; Read PPU_STATUS to reset the PPU_ADDR latch.
	ldx #$3F              ; Store the value #$3F into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the hi-byte
	ldx #$00              ; Store the value #$00 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the lo-byte
	jsr LoopPalette       ; Jump to the subroutine that fills the color palette in the PPU

	; Set PPU address to $2000, and load the tiles of the background

	bit PPU_STATUS        ; Read PPU_STATUS to reset the PPU_ADDR latch.
	ldx #$20              ; Store the value #$20 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the hi-byte
	ldx #$00              ; Store the value #$00 into the X register.
	stx PPU_ADDR          ; Load the value in X into PPU_ADDR register, setting the lo-byte
	jsr LoopBackground    ; Jump to the subroutine that loads the background data into the PPU.

EnablePPURendering:
	lda #%10010000        ; Enable NMI and set background to use the 2nd pattern table (at $1000)
	sta PPU_CTRL
	ldx #%00011110        ; Load the value #%00011110 into X.
	stx PPU_MASK          ; Load the value in X into the PPU_MASK register, allowing the background to be rendered.

LoopForever:
	jmp LoopForever       ; Force an infinite execution loop.
NMI:
    rti ; Return, don't do anything

IRQ:
    rti ; Return, don't do anything

PaletteData:
.byte $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A, $0F, $2A, $0C, $3A ; Background
.byte $0F, $10, $00, $26, $0F, $10, $00, $26, $0F, $10, $00, $26, $0F, $10, $00, $26 ; Sprite

BackgroundData:
.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.byte $24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
.byte $24,$36,$37,$24,$24,$24,$24,$24,$39,$3a,$3b,$3c,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
.byte $35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6a,$24,$24,$24,$24
.byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; Here we add the CHR-ROM data, included from an external .CHR file.
.segment "CHARS"
.incbin "mario.chr"

; The vectors are addresses that point to code whenever a specific signal is sent. 
; Basically a callback
.segment "VECTORS" 
; Address of the NMI handler
; Address of the RESET handler
; Address of the IRQ handler
.word NMI
.word Reset
.word IRQ
