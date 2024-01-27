@ECHO OFF

ca65 exercise_2.asm -o exercise_2.o
ld65 -C ..\nes.cfg exercise_2.o -o exercise_2
qfceux exercise_2