;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRG-ROM code located at $8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "CODE"

RESET:
    sei                   ; Disable all IRQ interrupts.
    cld                   ; Clears the decimal-mode (even though the NES's Ricoh 6502 does not have it.)
    ldx #$FF              ; Load the literal $FF hexadecimal value to the X register.
    txs                   ; Initialize the stack pointer at $00FF.
	
	inx		              ; Overflow X so that -> X (255) + 1 -> X = 0
	stx PPU_CTRL          ; Disable NMI (PPU_CTRL)
	stx PPU_MASK          ; Disable rendering (PPU_MASK, masking background and sprites)
	stx $4010             ; Disable DMC IRQs
	
	lda #$40              ; Store the value $#40 into the Y register
	sta $4017             ; Store the value in the Y register into memory location $4017, disabling the APU frame IRQ.

Wait1stVBlank:
	bit PPU_STATUS        ; Make a bit check
	bpl Wait1stVBlank     ; Go back while the negative bit isn't 1 (two's complement)

	txa                   ; Transfer the value from X to A.
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

Wait2ndVBlank:            ; Wait for the second VBlank from the PPU
    bit PPU_STATUS        ; Perform a bit-wise check with the PPU_STATUS port
    bpl Wait2ndVBlank     ; Loop until bit-7 (sign bit) is 1 (inside VBlank)
	
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
.word RESET
.word IRQ
