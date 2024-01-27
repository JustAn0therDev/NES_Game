@ECHO OFF

ca65 exercise_3.asm -o exercise_3.o
ld65 -C ..\nes.cfg exercise_3.o -o exercise_3
qfceux exercise_3