@ECHO OFF

ca65 clearmem.asm -o clearmem.o
ld65 -C nes.cfg clearmem.o -o clearmem
fceux64 clearmem
