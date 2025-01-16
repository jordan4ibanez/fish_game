default:
	@dub run

install:
	dub upgrade
	dub run raylib-d:install