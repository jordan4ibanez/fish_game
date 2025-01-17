module world.heightmap;

import gamut.image;
import gamut.types;
import std.stdio;
import std.string;

static final const class Heightmap {
static:

    void initialize() {

        Image image;

        const string fileName = loadImage("levels/4square.png", &image);

        checkImage(&image);

        for (int y = 0; y < image.height; y++) {
            ushort* scan = cast(ushort*) image.scanptr(y);

            for (int x = 0; x < image.width(); x++) {

                ushort rawPixelValue = scan[(ushort.sizeof * 8) * x];
                float floatingPixelValue = cast(float) rawPixelValue;

                float finalValue = floatingPixelValue / (cast(float) ushort.max);
                writeln(finalValue);
            }
        }

    }

    //* BEGIN INTERNAL API.

private:

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
