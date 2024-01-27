@ECHO OFF

ca65 exercise_5.asm -o exercise_5.o
ld65 -C ..\nes.cfg exercise_5.o -o exercise_5
qfceux exercise_5