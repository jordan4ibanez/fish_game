import core.sys.posix.syslog;
import level.heightmap;
import raylib;
import std;

void main() {

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_ERROR);

	InitWindow(800, 600, "Hello, Raylib-D!");

	SetTargetFPS(60);

	//* Begin testing heightmap.

	Heightmap.load("levels/4square.png");

	//* End testing heightmap.

	while (WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, Colors.BLACK);
		EndDrawing();
	}
	CloseWindow();
}
