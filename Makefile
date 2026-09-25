default:
	@dub run

debug:
	@dub build --build=debug
	@gdb ./fish_game

install:
	dub upgrade
	dub run raylib-d:install

clean:
	dub clean