import core.sys.posix.syslog;
import level.heightmap;
import raylib;
import std.stdio;
import std.typecons;

void main() {

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_ERROR);

	InitWindow(800, 600, "Hello, Raylib-D!");

	SetTargetFPS(60);

	//* Begin testing heightmap.

	Heightmap.load("levels/4square.png");

	Tuple!(int, "width", int, "height") mapSize = Heightmap.getSize();

	float[] vertices = new float[](0);
	float[] textureCoordinates = new float[](0);
	int[] indices = new int[](0);

	int i = 0;

	foreach (x; 0 .. mapSize.width) {
		foreach (y; 0 .. mapSize.height) {
			const float heightTopLeft = Heightmap.getHeight(x, y + 1);
			const float heightBottomLeft = Heightmap.getHeight(x, y);
			const float heightBottomRight = Heightmap.getHeight(x + 1, y);
			const float heightTopRight = Heightmap.getHeight(x + 1, y + 1);

			vertices ~= [
				x, heightTopLeft, y + 1, // top left.
				x, heightBottomLeft, y, // bottom left.
				x + 1, heightBottomRight, y, // bottom right.
				x + 1, heightTopRight, y + 1, // top right.
			];

			textureCoordinates ~= [
				0.0, 0.0, // top left.
				0.0, 1.0, // bottom left
				1.0, 1.0, // bottom right.
				1.0, 0.0, // top right.
			];

			indices ~= [
				0 + i,
				1 + i,
				2 + i,
				2 + i,
				3 + i,
				0 + i,
			];

			i += 4;

			if (i > ushort.max) {
				throw new Error("Map is too big. This needs to be broken up.");
			}
		}
	}

	//* End testing heightmap.

	while (WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, Colors.BLACK);
		EndDrawing();
	}
	CloseWindow();
}
