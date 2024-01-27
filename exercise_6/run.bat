@ECHO OFF

ca65 exercise_6.asm -o exercise_6.o
ld65 -C ..\nes.cfg exercise_6.o -o exercise_6
qfceux exercise_6