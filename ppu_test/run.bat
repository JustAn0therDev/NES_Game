@ECHO OFF

ca65 ppu_test.asm -o ppu_test.o
ld65 -C ..\nes.cfg ppu_test.o -o ppu_test
qfceux ppu_test
