import core.stdc.tgmath;
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

	Ground.load("levels/test_height_map.png");
	TextureHandler.loadTexture("textures/test.png");
	ModelHandler.setModelTexture("ground", "test.png");

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

	DisableCursor();
	Window.maximize();

	Vector2 testPoint = Vector2(0, 0);
	bool up = true;

	byte test = 0;

	while (Window.shouldStayOpen()) {

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		if (test == 0) {
			if (up) {
				testPoint.x += 0.01;
				if (testPoint.x >= 0.99) {
					testPoint.x = 0.99;
					up = false;
				}
			} else {
				testPoint.x -= 0.01;
				if (testPoint.x <= 0.01) {
					testPoint.x = 0.01;
					up = !up;
					test++;
				}
			}
			testPoint = Vector2(testPoint.x, 1.00 - testPoint.x);
		} else if (test == 1) {
			bool ignore = false;
			if (up) {
				testPoint.x += 0.01;
				if (testPoint.x >= 0.99) {
					testPoint.x = 0.99;
					up = false;
				}
			} else {
				testPoint.x -= 0.01;
				if (testPoint.x <= 0.01) {
					testPoint.x = 0.01;
					up = !up;
					test++;
					testPoint.x = 0;
					testPoint.y = 0;
					ignore = true;
				}
			}
			if (!ignore) {
				testPoint = Vector2(testPoint.x, 0.5);
			}
		} else if (test == 2) {
			bool ignore = false;
			if (up) {
				testPoint.y += 0.01;
				if (testPoint.y >= 0.99) {
					testPoint.y = 0.99;
					up = false;
				}
			} else {
				testPoint.y -= 0.01;
				if (testPoint.y <= 0.01) {
					testPoint.y = 0.01;
					up = !up;
					test++;
					ignore = true;
					testPoint.x = 0;
					testPoint.y = 0;
				}
			}
			if (!ignore) {
				testPoint = Vector2(0.5, testPoint.y);
			}
		} else if (test == 3) {
			if (up) {
				testPoint.x += 0.01;
				if (testPoint.x >= 0.99) {
					testPoint.x = 0.99;
					up = false;
				}
			} else {
				testPoint.x -= 0.01;
				if (testPoint.x <= 0.01) {
					testPoint.x = 0.0;
					up = !up;
					test = 0;
				}
			}
			testPoint = Vector2(testPoint.x, testPoint.x);
		}

		// writeln("point: ", point);

		// foreach (i; 0 .. 13) {
		// UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		// }

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);
			BeginMode3D(*camera);
			{

				float yHeight = heightCalculation(testPoint);

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				DrawSphere(Vector3(testPoint.x, 0, testPoint.y), 0.02, Colors.YELLOW);

				DrawSphere(Vector3(testPoint.x, yHeight, testPoint.y), 0.02, Colors.RED);

				ModelHandler.draw("ground", Vector3(0, 0, 0));

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
		}
		EndDrawing();
	}

}
