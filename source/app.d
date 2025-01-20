import graphics.model_handler;
import graphics.texture_handler;
import level.ground;
import raylib;
import std.stdio;
import std.typecons;

void main() {

	scope (exit) {
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

	Ground.load("levels/big_map_test.png");
	TextureHandler.loadTexture("textures/sand.png");
	ModelHandler.setModelTexture("ground", "sand.png");

	ModelHandler.loadModelFromFile("models/largemouth.glb");
	TextureHandler.loadTexture("models/largemouth.png");
	ModelHandler.setModelTexture("largemouth.glb", "largemouth.png");

	Camera* camera = new Camera();
	camera.position = Vector3(0, 2, 4);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	while (!WindowShouldClose()) {

		// UpdateCamera(camera, CameraMode.CAMERA_FREE);

		foreach (i; 0 .. 10) {
			UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		}

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);

			DrawText("Hello, World!", 0, 0, 28, Colors.BLACK);

			BeginMode3D(*camera);
			{

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(0, 0, 0), 1, Colors.BEIGE);
				// DrawModel(*groundModel, Vector3(-1, 0, -1), 2, Colors.WHITE);

				// ModelHandler.draw("ground", Vector3(0, 0, 0));

				ModelHandler.draw("largemouth.glb", Vector3(0, 0, 0));

			}
			EndMode3D();
		}
		EndDrawing();
	}

}
