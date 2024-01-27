@ECHO OFF

ca65 exercise_4.asm -o exercise_4.o
ld65 -C ..\nes.cfg exercise_4.o -o exercise_4
qfceux exercise_4