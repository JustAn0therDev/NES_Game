@ECHO OFF

ca65 exercise_9.asm -o exercise_9.o
ld65 -C ..\nes.cfg exercise_9.o -o exercise_9
qfceux exercise_9