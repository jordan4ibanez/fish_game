import core.sys.posix.syslog;
import level.heightmap;
import raylib;
import std.stdio;
import std.typecons;

void main() {

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	InitWindow(2000, 2000, "Hello, Raylib-D!");

	SetTargetFPS(60);

	//* Begin testing heightmap.

	Heightmap.load("levels/big_map_test.png");

	Tuple!(int, "width", int, "height") mapSize = Heightmap.getSize();

	float[] vertices = new float[](0);
	float[] textureCoordinates = new float[](0);

	const float scale = 10;

	foreach (x; 0 .. mapSize.width) {
		foreach (y; 0 .. mapSize.height) {

			// Raylib is still absolutely ancient with ushort as the indices so I have to convert this mess into raw vertex tris.

			const float[4] heightData = [
				Heightmap.getHeight(x, y) * scale, // 1 - Top Left.
				Heightmap.getHeight(x, y + 1) * scale, // 0 - Bottom Left.
				Heightmap.getHeight(x + 1, y + 1) * scale, // 3 - Bottom Right.
				Heightmap.getHeight(x + 1, y) * scale, // 2 - Top Right.
			];

			const Vector3[4] vData = [
				Vector3(x, heightData[0], y), // 0
				Vector3(x, heightData[1], y + 1), // 1
				Vector3(x + 1, heightData[2], y + 1), // 2
				Vector3(x + 1, heightData[3], y) // 3
			];

			vertices ~= [
				// Tri 1.
				vData[0].x, vData[0].y, vData[0].z,
				vData[1].x, vData[1].y, vData[1].z,
				vData[2].x, vData[2].y, vData[2].z,
				// Tri 2.
				vData[2].x, vData[2].y, vData[2].z,
				vData[3].x, vData[3].y, vData[3].z,
				vData[0].x, vData[0].y, vData[0].z,
			];

			// Same with the texture coordinate data.

			// todo: make this read from a texture map.
			const Vector2[4] tData = [
				Vector2(0.0, 0.0), // 0 top left.
				Vector2(0.0, 1.0), // 1 bottom left
				Vector2(1.0, 1.0), // 2 bottom right.
				Vector2(1.0, 0.0), // 3 top right.
			];

			textureCoordinates ~= [
				// Tri 1.
				tData[0].x, tData[0].y,
				tData[1].x, tData[1].y,
				tData[2].x, tData[2].y,
				// Tri 2.
				tData[2].x, tData[2].y,
				tData[3].x, tData[3].y,
				tData[0].x, tData[0].y,
			];
		}
	}

	// Sand texture.
	Texture2D* sandTexture = new Texture2D();
	*sandTexture = LoadTexture("textures/sand.png");

	// Uploading the model.
	Mesh* groundMesh = new Mesh();
	groundMesh.vertexCount = cast(int) vertices.length / 3;
	groundMesh.triangleCount = groundMesh.vertexCount / 3;

	groundMesh.vertices = vertices.ptr;
	groundMesh.texcoords = textureCoordinates.ptr;

	UploadMesh(groundMesh, false);

	Model* groundModel = new Model();
	*groundModel = LoadModelFromMesh(*groundMesh);

	groundModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = *sandTexture;

	//* End testing heightmap.

	Camera* camera = new Camera();
	const float scalarOut = 4;
	camera.position = Vector3(0, 50, 9);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	while (!WindowShouldClose()) {

		UpdateCamera(camera, CameraMode.CAMERA_FREE);

		BeginDrawing();
		{

			ClearBackground(Colors.SKYBLUE);

			DrawText("Hello, World!", 0, 0, 28, Colors.BLACK);

			BeginMode3D(*camera);
			{

				// DrawPlane(Vector3(0, 0, 0), Vector2(1, 1), Colors.BLACK);
				// DrawSphere(Vector3(0, 0, 0), 1, Colors.BEIGE);
				DrawModel(*groundModel, Vector3(-1, 0, -1), 2, Colors.WHITE);

			}
			EndMode3D();
		}
		EndDrawing();
	}
	CloseWindow();
}
