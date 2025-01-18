module level.heightmap;

import gamut.image;
import gamut.types;
import raylib.raylib_types;
import std.stdio;
import std.string;
import std.typecons;

static final const class Heightmap {
static:
private:

    float[][] mapData;
    int mapWidth = 0;
    int mapHeight = 0;
    string currentMap = null;

    //* BEGIN PUBLIC API.

    public void load(string location) {

        Image image;

        const string fileName = loadImage(location, &image);

        checkImage(&image);

        // -1 because these pixels make quads.
        mapWidth = image.width - 1;
        mapHeight = image.height - 1;

        mapData = new float[][](image.width, image.height);

        for (int y = 0; y < image.height; y++) {

            ushort* scan = cast(ushort*) image.scanptr(y);

            for (int x = 0; x < image.width(); x++) {

                ushort rawPixelValue = scan[x];

                float floatingPixelValue = cast(float) rawPixelValue;

                float finalValue = floatingPixelValue / (cast(float) ushort.max);

                // int invertedY = (image.height - 1) - y;

                mapData[x][y] = finalValue;
            }
        }

        //? I just left this here in case I need more testing.
        // foreach (x; 0 .. image.width) {
        //     foreach (y; 0 .. image.height) {
        //         writeln(x, " ", y, " ", mapData[x][y]);
        //     }
        // }
    }

    public float getHeight(int x, int y) {
        return mapData[x][y];
    }

    public Tuple!(int, int) getSize() {
        return tuple(mapWidth, mapHeight);
    }

    //* BEGIN INTERNAL API.

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
