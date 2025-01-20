import graphics.font_handler;
import graphics.model_handler;
import graphics.texture_handler;
import level.fish_definitions;
import level.ground;
import raylib;
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

	// LargeMouthBass blah2 = new LargeMouthBass();

	// writeln(blah2.model);

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

	Ground.load("levels/big_map_test.png");
	TextureHandler.loadTexture("textures/sand.png");
	ModelHandler.setModelTexture("ground", "sand.png");

	ModelHandler.loadModelFromFile("models/largemouth.glb");
	TextureHandler.loadTexture("models/largemouth.png");
	ModelHandler.setModelTexture("largemouth.glb", "largemouth.png");

	Camera* camera = new Camera();
	camera.position = Vector3(0, 20, 4);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	FontHandler.initialize();

	DisableCursor();

	while (Window.shouldStayOpen()) {

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		// foreach (i; 0 .. 13) {
		// 	UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		// }

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);

			/*
			? This is the fake copyright info for this build. :P
			Vector2 windowSize = Window.getSize();
			Vector2 textSize = FontHandler.getTextSize("© METABASS GENERAL LURES INC.");

			FontHandler.drawShadowed("© METABASS GENERAL LURES INC.", 1, windowSize.y - (
					textSize.y * 2) + 10);
			FontHandler.drawShadowed("PROTOTYPE BUILD. DO NOT DISTRIBUTE.", 2, windowSize.y - textSize.y + 5);
			*/

			BeginMode3D(*camera);
			{

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(0, 0, 0), 1, Colors.BEIGE);
				// DrawModel(*groundModel, Vector3(-1, 0, -1), 2, Colors.WHITE);

				ModelHandler.draw("ground", Vector3(0, 0, 0));

				// ModelHandler.draw(blah2.model, blah2.position);

			}
			EndMode3D();
		}
		EndDrawing();
	}

}
