main: main.gb
	rgbfix -v -p 0xFF main.gb

main.gb: main.o player.o game.o
	rgblink -o  main.gb operations.o main.o player.o game.o 

operations.o: operations.asm
	rgbasm -L -o operations.o operations.asm

main.o: main.asm
	rgbasm -L -o main.o main.asm

player.o: player.asm
	rgbasm -L -o player.o player.asm

game.o: game.asm
	rgbasm -L -o game.o game.asm


clean:
	rm *.o