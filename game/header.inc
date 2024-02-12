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