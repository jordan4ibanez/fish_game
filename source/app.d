import graphics.model_manager;
import graphics.texture_manager;
import level.ground;
import raylib;
import std.stdio;
import std.typecons;

void main() {

	scope (exit) {
		TextureManager.terminate();
		ModelManager.terminate();
		CloseWindow();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
	InitWindow(2000, 2000, "Hello, Raylib-D!");

	SetTargetFPS(60);

	Ground.load("levels/big_map_test.png");
	TextureManager.newTexture("textures/sand.png");

	ModelManager.setModelTexture("ground", "sand.png");

	Camera* camera = new Camera();
	const float scalarOut = 4;
	camera.position = Vector3(0, 50, 9);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	while (WindowShouldClose()) {

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);

			DrawText("Hello, World!", 0, 0, 28, Colors.BLACK);

			BeginMode3D(*camera);
			{

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(0, 0, 0), 1, Colors.BEIGE);
				// DrawModel(*groundModel, Vector3(-1, 0, -1), 2, Colors.WHITE);

			}
			EndMode3D();
		}
		EndDrawing();
	}

}
