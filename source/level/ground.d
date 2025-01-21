module level.ground;

import gamut.image;
import gamut.types;
import graphics.model_handler;
import std.stdio;
import std.string;
import std.typecons;

static final const class Ground {
static:
private:

    float[][] mapData;
    int mapWidth = 0;
    int mapHeight = 0;
    string currentMap = null;

    //* BEGIN PUBLIC API.

    public void load(string location) {
        loadMapData(location);
        createGroundMesh();
    }

    public float getHeight(int x, int y) {
        return mapData[x][y];
    }

    public Tuple!(int, int) getSize() {
        return tuple(mapWidth, mapHeight);
    }

    //* BEGIN INTERNAL API.

    void createGroundMesh() {
        import raylib;

        float[] vertices = new float[](0);
        float[] textureCoordinates = new float[](0);

        foreach (x; 0 .. mapWidth) {
            foreach (y; 0 .. mapHeight) {

                // Raylib is still absolutely ancient with ushort as the indices so I have to convert this mess into raw vertex tris.

                const float[4] heightData = [
                    getHeight(x, y), // 0 - Top Left.
                    getHeight(x, y + 1), // 1 - Bottom Left.
                    getHeight(x + 1, y + 1), // 2 - Bottom Right.
                    getHeight(x + 1, y), // 3 - Top Right.
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

        ModelHandler.newModelFromMesh("ground", vertices, textureCoordinates);

        //todo: set the ground texture from a pallete thing.
    }

    void loadMapData(string location) {
        Image image;

        const string fileName = loadImage(location, &image);

        checkImage(&image);

        // -1 because these pixels make quads.
        mapWidth = image.width - 1;
        mapHeight = image.height - 1;

        mapData = new float[][](image.width, image.height);

        const float scale = 5;

        for (int y = 0; y < image.height; y++) {

            ushort* scan = cast(ushort*) image.scanptr(y);

            for (int x = 0; x < image.width(); x++) {

                ushort rawPixelValue = scan[x];

                float floatingPixelValue = cast(float) rawPixelValue;

                float finalValue = floatingPixelValue / (cast(float) ushort.max);

                // int invertedY = (image.height - 1) - y;

                mapData[x][y] = finalValue * scale;
            }
        }

        //? I just left this here in case I need more testing.
        // foreach (x; 0 .. image.width) {
        //     foreach (y; 0 .. image.height) {
        //         writeln(x, " ", y, " ", mapData[x][y]);
        //     }
        // }
    }

    string loadImage(string location, Image* image) {

        if (!endsWith(location, ".png")) {
            throw new Exception("[Heightmap]: Not .png");
        }

        const string fileName = () {
            string[] data = split(location, "/");
            if (data.length <= 1) {
                throw new Exception("[Heightmap]: Do not put heightmaps in the root.");
            }
            const string output = data[cast(long) data.length - 1];
            if (output.length <= 0) {
                throw new Exception("[Heightmap]: String became 0 length.");
            }
            return output;
        }();

        image.loadFromFile(location);

        return fileName;
    }

    void checkImage(Image* image) {
        if (image.isError()) {
            throw new Exception(cast(string) image.errorMessage());
        }

        if (!image.isValid) {
            throw new Exception("[Heightmap]: Invalid image.");
        }

        if (!image.is16Bit()) {
            throw new Exception("[Heightmap]: Not 16 bit.");
        }

        if (image.type() != PixelType.l16) {
            throw new Exception("[Heightmap]: Wrong endianness.");
        }
    }

}
