module world.heightmap;

import gamut.image;
import gamut.types;
import std.stdio;
import std.string;

static final const class Heightmap {
static:

    void initialize() {

        Image image;

        loadImage("levels/4square.png", &image);

        checkImage(&image);

        for (int y = 0; y < image.height; y++) {

        }

    }

    //* BEGIN INTERNAL API.

private:

    void loadImage(string location, Image* image) {

        if (!endsWith(location, ".png")) {
            throw new Exception("[Heightmap]: Not .png");
        }

        string fileName = () {
            string[] data = split(location, "/");
            if (data.length <= 1) {
                throw new Exception("[Heightmap]: Do not put heightmaps in the root.");
            }
            return data[cast(long) data.length - 1];
        }();

        image.loadFromFile(location);

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
