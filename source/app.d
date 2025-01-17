import core.sys.posix.syslog;
import raylib;
import std;
import world.heightmap;

void main() {

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_ERROR);

	InitWindow(800, 600, "Hello, Raylib-D!");

	SetTargetFPS(60);

	//* Begin testing heightmap.

	Heightmap.initialize("levels/4square.png");

	//* End testing heightmap.

	while (WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, Colors.BLACK);
		EndDrawing();
	}
	CloseWindow();
}
