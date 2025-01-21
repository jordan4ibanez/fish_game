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

	Ground.load("levels/4square.png");
	TextureHandler.loadTexture("textures/test.png");
	ModelHandler.setModelTexture("ground", "test.png");

	ModelHandler.loadModelFromFile("models/largemouth.glb");
	TextureHandler.loadTexture("models/largemouth.png");
	ModelHandler.setModelTexture("largemouth.glb", "largemouth.png");

	Camera* camera = new Camera();
	camera.position = Vector3(0, -4, 4);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	FontHandler.initialize();

	DisableCursor();
	// Window.maximize();

	float point = 0;
	Vector2 testPoint = Vector2(0, 0);
	bool up = true;

	// Begin stackoverflow.
	// https://stackoverflow.com/a/2049593
	auto sign = (Vector2 p1, Vector2 p2, Vector2 p3) {
		return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
	};

	auto pointInTriangle = (Vector2 point, Vector2 v1, Vector2 v2, Vector2 v3) {
		float d1 = sign(point, v1, v2);
		float d2 = sign(point, v2, v3);
		float d3 = sign(point, v3, v1);

		bool has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
		bool has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

		return !(has_neg && has_pos);
	};

	//https://stackoverflow.com/a/23709352
	auto normalCalculation = (Vector3 p1, Vector3 p2, Vector3 p3) {
		Vector3 a = Vector3Subtract(p2, p1);
		Vector3 b = Vector3Subtract(p3, p1);

		return Vector3(
			a.y * b.z - a.z * b.y,
			a.z * b.x - a.x * b.z,
			a.x * b.y - a.y * b.x);
	};
	// End stackoverflow.

	auto triCalculation = (Vector3 point) {

		int x = cast(int) floor(point.x);
		int y = cast(int) floor(point.y);

		Vector2[4] pData = [
			Vector2(x, y),
			Vector2(x, y + 1),
			Vector2(x + 1, y + 1),
			Vector2(x + 1, y),
		];

		const int inPoint = () {
			if (pointInTriangle(Vector2(point.x, point.z), pData[0], pData[1], pData[2])) {
				return 1;
			} else if (pointInTriangle(Vector2(point.x, point.z), pData[2], pData[3], pData[0])) {
				return 2;
			}
			throw new Error("In non-existent position.");
		}();

		float[4] heightData = [
			Ground.getHeight(x, y),
			Ground.getHeight(x, y + 1),
			Ground.getHeight(x + 1, y),
			Ground.getHeight(x + 1, y + 1)
		];

		if (inPoint == 1) {
			writeln("1");
			// normalCalculation(
			// 	Vector3()

			// );

		} else {
			writeln("2");
		}

	};

	while (Window.shouldStayOpen()) {

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		if (up) {
			point += 0.01;
			if (point >= 0.99) {
				point = 0.99;
				up = false;
			}
		} else {
			point -= 0.01;
			if (point <= 0.01) {
				point = 0.01;
				up = !up;
			}
		}
		testPoint = Vector2(point, 1.00 - point);

		// writeln("point: ", point);

		// foreach (i; 0 .. 13) {
		// UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);
		// }

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);

			BeginMode3D(*camera);
			{

				triCalculation(Vector3(testPoint.x, 0, testPoint.y));

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				DrawSphere(Vector3(testPoint.x, 0, testPoint.y), 0.05, Colors.RED);
				// DrawModel(*groundModel, Vector3(-1, 0, -1), 2, Colors.WHITE);

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
