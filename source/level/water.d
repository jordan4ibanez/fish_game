module level.water;

import graphics.texture_handler;
import level.ground;
import std.stdio;
import std.typecons;

static final const class Water {
static:
private:

    // water is 0.25 unit quads.
    // Level size x * 4 and y * 4
    // Try to update with sin cos etc.

    float waterRoll = 0;

    // Water has 39 frames.
    immutable int minWaterTexture = 0;
    immutable int maxWaterTexture = 39;

    //* BEGIN PUBLIC API.

    public void load() {

        Tuple!(int, int) groundSize = Ground.getSize();

        foreach (i; minWaterTexture .. maxWaterTexture) {
            writeln(i);
        }
        // TextureHandler.loadTexture("textures/water/")

    }

    //* BEGIN INTERNAL API.

}
