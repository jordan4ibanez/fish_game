import core.stdc.tgmath;
import graphics.font_handler;
import graphics.model_handler;
import graphics.texture_handler;
import input.keyboard;
import level.fish_definitions;
import level.ground;
import level.level;
import level.water;
import raylib;
import std.conv;
import std.stdio;
import std.typecons;
import utility.window;

void main() {

	scope (exit) {
		// FontHandler.terminate();
		TextureHandler.terminate();
		ModelHandler.terminate();
		CloseWindow();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);

	// This is a hack to get the resolution.
	InitWindow(1, 1, "");
	int currentMonitor = GetCurrentMonitor();
	int monitorWidth = GetMonitorWidth(currentMonitor);
	int monitorHeight = GetMonitorHeight(currentMonitor);
	CloseWindow();

	InitWindow(monitorWidth / 2, monitorHeight / 2, "Fish Game");

	SetTargetFPS(60);

	// This is a very simple game. We don't want this optimized at all. Can make simpler geometry with it.
	rlDisableBackfaceCulling();

	Level.load("levels/map_lake/");

	ModelHandler.loadModelFromFile("models/largemouth.glb");
	TextureHandler.loadTexture("models/largemouth.png");
	ModelHandler.setModelTexture("largemouth.glb", "largemouth.png");

	Camera* camera = new Camera();
	camera.position = Vector3(0, 4, 4);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	FontHandler.initialize();

	Window.lockMouse();
	Window.maximize();

	LargeMouthBass blah2 = new LargeMouthBass();

	while (Window.shouldStayOpen()) {

		if (Keyboard.isPressed(KeyboardKey.KEY_F1)) {
			Window.toggleMaximize();
		}

		if (Keyboard.isPressed(KeyboardKey.KEY_F2)) {
			Window.toggleMouseLock();
		}

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		Level.update();

		// foreach (i; 0 .. 13) {
		// UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		// }

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);
			BeginMode3D(*camera);
			{

				// float yHeight = Ground.getHeight(testPoint.x, testPoint.y);

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(testPoint.x, 0, testPoint.y), 0.02, Colors.YELLOW);

				// DrawSphere(Vector3(testPoint.x, yHeight, testPoint.y), 0.02, Colors.RED);

				ModelHandler.draw("ground", Vector3(0, 0, 0));

				ModelHandler.draw("water", Vector3(0, 0, 0));

				// ModelHandler.draw(blah2.model, blah2.position);

			}
			EndMode3D();

			/*
			? This is the fake copyright info for this build. :P
			Vector2 windowSize = Window.getSize();
			Vector2 textSize = FontHandler.getTextSize("© METABASS GENERAL LURES INC.");

			FontHandler.drawShadowed("© METABASS GENERAL LURES INC.", 1, windowSize.y - (
					textSize.y * 2) + 10);
			FontHandler.drawShadowed("PROTOTYPE BUILD. DO NOT DISTRIBUTE.", 2, windowSize.y - textSize.y + 5);
			*/

			FontHandler.drawShadowed("FPS: " ~ to!string(GetFPS()), 0, -5);
		}
		EndDrawing();
	}

}
