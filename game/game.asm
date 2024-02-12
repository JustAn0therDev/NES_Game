.include "consts.inc"
.include "header.inc"
.include "reset.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

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
	
	ldx #$2A              ; Load the value #$2A into the X register.
	stx PPU_DATA          ; Load the value in X into PPU_DATA, setting the value at #$3F00 to 2A 
						  ; (first byte of the 16 bytes for the background color palette)
	
	ldx #%00011110        ; Load the value #%00011110 into X.
	stx PPU_MASK          ; Load the value in X into the PPU_MASK register, allowing the background to be rendered.

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
.word Reset
.word IRQ
