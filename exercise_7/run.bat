@ECHO OFF

ca65 exercise_7.asm -o exercise_7.o
ld65 -C ..\nes.cfg exercise_7.o -o exercise_7
qfceux exercise_7