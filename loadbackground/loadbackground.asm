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

;; Load attribute bytes
.proc LoopAttribute
	ldy #0
LoopAttribute:
	lda AttributeData, y        ; Load the A register with the memory location of AttributeData and the value in the Y register.
	sta PPU_DATA                ; Set the value in the A register to the memory location of PPU_DATA (where we want to load the attribute values.)
	iny                         ; Increment Y
	cpy #16                     ; Compare the value in the Y register to #16.
	bne LoopAttribute           ; If it's not equal, loop back to the LoopAttribute label.
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

	; Set PPU address to $23C0, and load the attributes of the background.

	bit PPU_STATUS        ; Read PPU_STATUS to reset the PPU_ADDR latch.
	ldx #$23              ; Store the value #$20 into the X register.
	stx PPU_ADDR          ; Load the hi-byte with the value from the X register.
	ldx #$C0              ; Store the value #$C0 into the X register.
	stx PPU_ADDR          ; Load the lo-byte with the value from the X register.
	jsr LoopAttribute     ; Jump to the subroutine that loads the background color data into the PPU.

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
.byte $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F ; Background palette
.byte $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17 ; Sprite palette

BackgroundData:
.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.byte $24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
.byte $24,$36,$37,$24,$24,$24,$24,$24,$39,$3a,$3b,$3c,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
.byte $35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6a,$24,$24,$24,$24
.byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

AttributeData:
.byte %00000000, %00000000, %10101010, %00000000, %11110000, %00000000, %00000000, %00000000
.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

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
