import core.stdc.tgmath;
import graphics.font_handler;
import graphics.model_handler;
import graphics.shader_handler;
import graphics.texture_handler;
import input.keyboard;
import level.fish_definitions;
import level.ground;
import level.level;
import level.water;
import raylib;
import std.conv;
import std.stdio;
import std.string;
import std.typecons;
import utility.window;

void main() {

	scope (exit) {
		// FontHandler.terminate();
		ShaderHandler.terminate();
		TextureHandler.terminate();
		ModelHandler.terminate();
		CloseWindow();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_ALL);

	SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);

	// This is a hack to get the resolution.
	InitWindow(1, 1, "");
	int currentMonitor = GetCurrentMonitor();
	int monitorWidth = GetMonitorWidth(currentMonitor);
	int monitorHeight = GetMonitorHeight(currentMonitor);
	CloseWindow();

	InitWindow(monitorWidth / 2, monitorHeight / 2, "Fish Game");

	switch (rlGetVersion()) {
	case rlGlVersion.RL_OPENGL_11, rlGlVersion.RL_OPENGL_21, rlGlVersion.RL_OPENGL_ES_20:
		// This will probably still crash on opengl es 3.0 but, we'll cross that bridge.
		throw new Error("The system is too old.");
	default:
	}

	ShaderHandler.newShader("water", "shaders/water.vert", "shaders/water.frag");
	ShaderHandler.newShader("ground", "shaders/ground.vert", "shaders/ground.frag");
	ShaderHandler.newShader("normal", "shaders/normal.vert", "shaders/normal.frag");

	SetTargetFPS(0);
	// SetWindowState(ConfigFlags.FLAG_VSYNC_HINT);

	// This is a very simple game. We don't want this optimized at all. Can make simpler geometry with it.
	rlDisableBackfaceCulling();

	ModelHandler.loadModelFromFile("models/largemouth.glb");
	TextureHandler.loadTexture("models/largemouth.png");
	ModelHandler.setModelTexture("largemouth.glb", "largemouth.png");
	ModelHandler.setModelShader("largemouth.glb", "normal");

	Camera* camera = new Camera();
	camera.position = Vector3(0, 4, 4);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	FontHandler.initialize();

	Level.load("levels/map_lake/");

	// Window.lockMouse();
	// Window.maximize();

	while (Window.shouldStayOpen()) {

		if (Keyboard.isPressed(KeyboardKey.KEY_F1)) {
			Window.toggleMaximize();
		}

		if (Keyboard.isPressed(KeyboardKey.KEY_F2)) {
			Window.toggleMouseLock();
		}

		if (Keyboard.isPressed(KeyboardKey.KEY_F3)) {
			Level.togglePause();
		}

		if (Window.isMouseLocked()) {
			UpdateCamera(camera, CameraMode.CAMERA_FREE);
		}

		Level.update();

		// foreach (i; 0 .. 13) {
		// UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		// }

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);
			BeginMode3D(*camera);
			{

				Level.draw();

				// float yHeight = Ground.getHeightAtPosition(testPoint.x, testPoint.y);

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(testPoint.x, 0, testPoint.y), 0.02, Colors.YELLOW);

				// DrawSphere(Vector3(testPoint.x, yHeight, testPoint.y), 0.02, Colors.RED);

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
