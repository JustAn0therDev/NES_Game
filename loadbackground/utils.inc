.macro PPU_SETADDR addr
	bit PPU_STATUS       ; Set PPU_STATUS to reset the latch in the PPU_ADDR.
	lda #>addr           ; Load the hi-byte into the A register.
	sta PPU_ADDR         ; Load the hi-byte inside the A register into the PPU_ADDR.
	lda #<addr           ; Load the lo-byte into the A register.
	sta PPU_ADDR         ; Load the lo-byte inside the A register into the PPU_ADDR.
.endmacro

.macro PPU_SETDATA val
	lda val              ; Load the value from "value" into the A register.
	sta PPU_DATA         ; Load the value from A into PPU_DATA.
.endmacro