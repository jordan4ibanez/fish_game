module level.fish_definitions;

import level.ground;
import level.water;
import raylib;
import std.stdio;
import utility.uuid;

abstract class Fish {
    Vector3 position = Vector3(0, 0, 0);
    // Pitch and yaw.
    Vector2 rotation = Vector2(0, 0);
    float scale = 1;
    ulong uuid = 0;

    string __model = "undefined";

    this() {
        this.uuid = UUID.next();
    }

    @property string model() {
        return this.__model;
    }

    void update() {
        writeln("updating");
        move();
    }

    void move() {
        writeln("moving");
        if (position.x < 1) {
            position.x = 1;
        } else if (position.x > Ground.getWidth() - 1.0) {
            position.x = Ground.getWidth() - 1.0;
        }

        if (position.z < 1) {
            position.z = 1;
        } else if (position.z > Ground.getHeight() - 1.0) {
            position.z = Ground.getHeight() - 1.0;
        }

        writeln(position);

    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
