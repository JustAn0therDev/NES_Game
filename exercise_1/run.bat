@ECHO OFF

ca65 exercise_1.asm -o exercise_1.o
ld65 -C ..\nes.cfg exercise_1.o -o exercise_1
qfceux exercise_1