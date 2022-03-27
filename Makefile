main: main.gb
	rgbfix -v -p 0xFF main.gb
	make clean

main.gb: main.o player.o game.o procedures.o map.o 
	rgblink -o  main.gb procedures.o main.o player.o map.o game.o 
	
map.o: map.asm
	rgbasm -L -o map.o map.asm

procedures.o: procedures.asm
	rgbasm -L -o procedures.o procedures.asm

main.o: main.asm
	rgbasm -L -o main.o main.asm

player.o: player.asm
	rgbasm -L -o player.o player.asm

game.o: game.asm
	rgbasm -L -o game.o game.asm

clean:
	rm *.o