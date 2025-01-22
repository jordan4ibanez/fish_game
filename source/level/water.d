module level.water;

import graphics.model_handler;
import graphics.texture_handler;
import level.ground;
import raylib;
import std.conv;
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

    bool loaded = false;

    immutable float tileWidth = 0.25;

    int waterWidth = 0;
    int waterHeight = 0;

    float[][] waterData;

    //? Water frequently updates, so this is implemented in a special way.

    //* BEGIN PUBLIC API.

    public void load() {

        Tuple!(int, int) groundSize = Ground.getSize();

        if (loaded) {
            throw new Error("Clean up the water gpu memory or reuse it.");
        } else {
            foreach (i; minWaterTexture .. maxWaterTexture + 1) {
                TextureHandler.loadTexture("textures/water/water_" ~ to!string(i) ~ ".png");
            }
        }

        waterWidth = ((groundSize[0] + 1) * 4) - 1;
        waterHeight = ((groundSize[1] + 1) * 4) - 1;

        waterData = new float[][](waterWidth + 1, waterHeight + 1);

        resetWaterData();

        float[] vertices = loadVertices();
        float[] textureCoordinates = loadTextureCoordinates();

        ModelHandler.newModelFromMesh("water", vertices, textureCoordinates, true);

        ModelHandler.setModelTexture("water", "water_0.png");

        loaded = true;
    }

    //* BEGIN INTERNAL API.

    void resetWaterData() {

        foreach (x; 0 .. waterWidth + 1) {
            foreach (y; 0 .. waterHeight + 1) {
                waterData[x][y] = 0;
            }
        }
    }

    float[] loadVertices() {
        float[] vertices = new float[](0);

        // todo: updateVertices will reuse the pointer in place
        // todo: from the height data and reupload in place.

        foreach (x; 0 .. waterWidth) {
            foreach (y; 0 .. waterHeight) {

                immutable float sx = x * tileWidth;
                immutable float sy = y * tileWidth;

                const Vector3[4] vData = [
                    Vector3(sx, waterData[x][y], sy), // 0
                    Vector3(sx, waterData[x][y + 1], sy + tileWidth), // 1
                    Vector3(sx + tileWidth, waterData[x + 1][y + 1], sy + tileWidth), // 2
                    Vector3(sx + tileWidth, waterData[x + 1][y], sy) // 3
                ];
                writeln(waterData[x][y]);

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
            }
        }
        return vertices;
    }

    float[] loadTextureCoordinates() {
        float[] textureCoordinates = new float[](0);

        foreach (x; 0 .. waterWidth) {
            foreach (y; 0 .. waterHeight) {
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

        return textureCoordinates;
    }

}
