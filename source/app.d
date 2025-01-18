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
	ushort[] indices = new ushort[](0);

	int i = 0;

	const float scale = 0;

	foreach (x; 0 .. mapSize.width) {
		foreach (y; 0 .. mapSize.height) {

			// Raylib is still absolutely ancient with ushort as the indices so I have to convert this mess into raw vertex tris.

			const float heightTopLeft = Heightmap.getHeight(x, y + 1) * scale; // 0
			const float heightBottomLeft = Heightmap.getHeight(x, y) * scale; // 1
			const float heightBottomRight = Heightmap.getHeight(x + 1, y) * scale; // 2
			const float heightTopRight = Heightmap.getHeight(x + 1, y + 1) * scale; // 3

			vertices ~= [
				x, heightBottomLeft, y, // top left.
				x, heightTopLeft, y + 1, // bottom left.
				x + 1, heightTopRight, y + 1, // bottom right.
				x + 1, heightBottomRight, y, // top right.
			];

			textureCoordinates ~= [
				0.0, 0.0, // top left.
				0.0, 1.0, // bottom left
				1.0, 1.0, // bottom right.
				1.0, 0.0, // top right.
			];

			indices ~= [
				cast(ushort)(0 + i),
				cast(ushort)(1 + i),
				cast(ushort)(2 + i),
				cast(ushort)(2 + i),
				cast(ushort)(3 + i),
				cast(ushort)(0 + i)
			];

			i += 4;

			if (i > ushort.max) {
				throw new Error("Map is too big. This needs to be broken up.");
			}
		}
	}

	// Sand texture.
	Texture2D* sandTexture = new Texture2D();
	*sandTexture = LoadTexture("textures/sand.png");

	// Uploading the model.
	Mesh* groundMesh = new Mesh();
	groundMesh.vertexCount = cast(int) vertices.length / 3;
	groundMesh.triangleCount = cast(int) indices.length / 3;

	groundMesh.vertices = vertices.ptr;
	groundMesh.texcoords = textureCoordinates.ptr;
	groundMesh.indices = indices.ptr;

	writeln("AHHH ", indices.length);

	UploadMesh(groundMesh, false);

	Model* groundModel = new Model();
	*groundModel = LoadModelFromMesh(*groundMesh);

	groundModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = *sandTexture;

	//* End testing heightmap.

	Camera* camera = new Camera();
	const float scalarOut = 4;
	camera.position = Vector3(-1, 5, 6);
	camera.up = Vector3(0, 1, 0);
	camera.target = Vector3(0, 0, 0);
	camera.fovy = 45.0;
	camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

	while (!WindowShouldClose()) {

		UpdateCamera(camera, CameraMode.CAMERA_ORBITAL);

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
