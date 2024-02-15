@ECHO OFF

ca65 game.asm -o game.o
ld65 -C ..\nes.cfg game.o -o game
qfceux game
