@ECHO OFF

ca65 hellomario.asm -o hellomario.o
ld65 -C ..\nes.cfg hellomario.o -o hellomario.nes
qfceux hellomario.nes
