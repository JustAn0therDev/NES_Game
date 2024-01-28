@ECHO OFF

ca65 exercise_8.asm -o exercise_8.o
ld65 -C ..\nes.cfg exercise_8.o -o exercise_8
qfceux exercise_8