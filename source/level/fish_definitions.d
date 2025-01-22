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
    float collisionDown = 0.2;
    float collisionUp = 0.2;

    string __model = "undefined";

    this() {
        this.uuid = UUID.next();
    }

    @property string model() {
        return this.__model;
    }

    void update() {
        move();
    }

    void move() {
        position.x += 0.01;
        position.z += 0.02;

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

        

    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
