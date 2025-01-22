module level.fish_definitions;

import raylib;
import std.stdio;

abstract class Fish {
    Vector3 position = Vector3(0, 0, 0);
    // Pitch and yaw.
    Vector2 rotation = Vector2(0, 0);
    float scale = 1;
    ulong id = 0;

    string __model = "undefined";

    @property string model() {
        return this.__model;
    }

    void update() {
        writeln("updating");
    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
