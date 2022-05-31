Runner: Runner.gb
	rgbfix -v -p 0xFF Runner.gb
	make clean
	mv Runner.gb ../


Runner.gb: main.o player.o game.o procedures.o map.o logo.o projectiles.o enemy.o soundcontroller.o
	rgblink -o  Runner.gb procedures.o main.o player.o map.o game.o logo.o projectiles.o enemy.o soundcontroller.o
	
	
projectiles.o:
	rgbasm -L -o projectiles.o projectiles.asm
	
enemy.o:
	rgbasm -L -o enemy.o enemy.asm

	
map.o: map.asm
	rgbasm -L -o map.o map.asm
	
logo.o: logo.asm
	rgbasm -L -o logo.o logo.asm

procedures.o: procedures.asm
	rgbasm -L -o procedures.o procedures.asm

main.o: main.asm
	rgbasm -L -o main.o main.asm

player.o: player.asm
	rgbasm -L -o player.o player.asm

game.o: game.asm
	rgbasm -L -o game.o game.asm
	
soundcontroller.o:  soundcontroller.asm
	rgbasm -L -o soundcontroller.o soundcontroller.asm

clean:
	rm *.o