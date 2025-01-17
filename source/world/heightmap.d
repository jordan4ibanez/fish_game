module world.heightmap;

import dimage.base;
import dimage.png;
import std.container.array;
import std.file;
import std.stdio;
import std.string;
import std.typecons;

static final const class Heightmap {
static:
private:

    double[][] mapData;
    uint mapWidth = 0;
    uint mapHeight = 0;

    //* BEGIN PUBLIC API.

    public void initialize(string location) {

        // Image image;

        Tuple!(string, PNG) data = loadImage(location);

        string fileName = data[0];

        PNG texture = data[1];

        texture.flipVertical();

        mapData = new double[][](texture.width, texture.height);

        // Subtract 1 because these points are making quads.
        mapWidth = texture.width - 1;
        mapHeight = texture.height - 1;

        // This is the max value I can get with pure white in gimp.
        const F64_MAX_GIMP = 429_4963_018;

        foreach (x; 0 .. texture.width) {
            foreach (y; 0 .. texture.height) {
                // Use the base for the pure brightness data.
                uint rawValue = texture.readPixel(x, y).base;
                double rawFloating = cast(double) rawValue;
                double scaled = rawFloating / F64_MAX_GIMP;

                // Outputs data as a range in between [-0.5] to [0.5].
                double shifted = scaled - 0.5;

                uint flippedX = (texture.width - 1) - x;
                uint flippedY = (texture.height - 1) - y;

                mapData[x][y] = scaled; //shifted;
            }
        }

        foreach (x; 0 .. texture.width) {
            foreach (y; 0 .. texture.height) {
                write(x, " ", y);
                writef(" | %.10f\n", mapData[x][y]);
            }
        }

    }

    //* BEGIN INTERNAL API.

    Tuple!(string, PNG) loadImage(string location) {

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

        File source = File(location);

        PNG texture = PNG.load(source);

        if (texture.getBitdepth() != 16) {
            throw new Exception("[Heightmap]: Not 16 bit.");
        }

        return tuple(fileName, texture);
    }
}
