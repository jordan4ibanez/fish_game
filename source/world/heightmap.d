module world.heightmap;

import std.stdio;
import gamut.image;
import gamut.types;

static final const class Heightmap
{
static:

    void initialize()
    {

        Image image;

        image.loadFromFile("levels/4square.png");

        if (image.isError())
        {
            throw new Exception(cast(string) image.errorMessage());
        }

        if (!image.isValid)
        {
            throw new Exception("[Heightmap]: Invalid image.");
        }

        if (!image.is16Bit())
        {
            throw new Exception("[Heightmap]: Not 16 bit.");
        }

        if (image.type() != PixelType.l16)
        {
            throw new Exception("[Heightmap]: Wrong endianness.");
        }

        

    }

}
