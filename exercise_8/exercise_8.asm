.segment "HEADER" ; Don’t forget to always add the iNES header to your ROM files
.org $7FF0
.byte $4E,$45,$53,$1A,$02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.segment "CODE" ; Define a segment called "CODE" for the PRG-ROM at $8000
.org $8000

Reset:
	ldy #10             ; Initialize the Y register with the decimal value 10

Loop:
	tya                 ; Transfer Y to A
	sta $80,Y           ; Store the value in A inside memory position $80+Y
    dey                 ; Decrement Y
	bne Loop            ; Branch back to "Loop" until we are done

	; NOTES(Ruan): I'm not sure if there is a better way to do this,
	; since I can't overflow the value to reach 0 again. This way, it only takes a 
	; single instruction before storing the value #0 in the memory position.
	; Any other way of changing the value in register A would take at least 2 instructions
	; (like "sec, sbc #1", for example)
	
	lda #0              ; Load the value 0 into register A
	sta $80             ; Store the value in A inside memory position $80

NMI: ; NMI handler
	rti ; doesn't do anything

IRQ: ; IRQ handler
	rti ; doesn't do anything
.segment "VECTORS" ; Add addresses with vectors at $FFFA
.org $FFFA
.word NMI   ; Put 2 bytes with the NMI address at memory position $FFFA
.word Reset ; Put 2 bytes with the break address at memory position $FFFC
.word IRQ   ; Put 2 bytes with the IRQ address at memory position $FFFE