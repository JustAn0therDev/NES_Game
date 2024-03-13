.include "consts.inc"
.include "header.inc"
.include "reset.inc"
.include "utils.inc"

.segment "ZEROPAGE"
Frame: .res 1            ; Reserve 1 byte for the frame counter.
Clock60: .res 1          ; Reserve 1 byte for the clock counter (seconds counter).
BgPtr: .res 2            ; Reserve 2 bytes (16 bits) to store a pointer to the background address.
						 ; (we store first the lo-byte and then the hi-byte, due to endianess. This has absolutely nothing to do with the PPU registers.)

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
	lda (BgPtr), y 				; Load the A register with the value in the exact memory region where we keep the background data bytes.
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

	lda #0
	sta Frame
	sta Clock60
	
Main:
	PPU_SETADDR $3F00
	jsr LoopPalette       ; Jump to the subroutine that fills the color palette in the PPU

	; Set PPU address to $2000, and load the tiles of the background
	
	lda #<BackgroundData  ; Fetch the lo-byte of the BackgroundData address
	sta BgPtr
	lda #>BackgroundData  ; Fetch the hi-byte of the BackgroundData address
	sta BgPtr+1

	PPU_SETADDR $2000
	jsr LoopBackground    ; Jump to the subroutine that loads the background data into the PPU.

	; Set PPU address to $23C0, and load the attributes of the background.

	PPU_SETADDR $23C0
	jsr LoopAttribute     ; Jump to the subroutine that loads the background color data into the PPU.

EnablePPURendering:
	lda #%10010000        ; Enable NMI and set background to use the 2nd pattern table (at $1000)
	sta PPU_CTRL
	ldx #%00011110        ; Load the value #%00011110 into X.
	stx PPU_MASK          ; Load the value in X into the PPU_MASK register, allowing the background to be rendered.
	
LoopForever:
	jmp LoopForever       ; Force an infinite execution loop.

IncrementClockCounterAndResetFrameCount:
	inc Clock60           ; If this label got called, it means that one second has passed (60 frames, 60hz refresh rate for NTSC televisions)
	lda #0                ; Load the A register with 0
	sta Frame             ; It also means that the Frame counter has reached 60. Now we clean it and count again.
	
NMI:
	inc Frame                                          ; Increment the frame every time a V-blank happens
	lda Frame                                          ; Load the value of Frame inside the A register.
	cmp #60                                            ; Compare it to 60
	beq IncrementClockCounterAndResetFrameCount        ; If it equals 60, we can increment the clock counter and clear it.
    rti                                                ; Return, don't do anything

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
