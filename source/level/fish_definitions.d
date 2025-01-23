module level.fish_definitions;

import core.stdc.tgmath;
import level.ground;
import level.water;
import raylib;
import std.stdio;
import utility.uuid;

abstract class Fish {
    Vector3 oldPosition = Vector3(0, 0, 0);
    Vector3 position = Vector3(0, 0, 0);
    // Pitch and yaw.
    Vector3 rotation = Vector3(0, 0, 0);
    float scale = 1;
    ulong uuid = 0;
    float collisionDown = 0.2;
    float collisionUp = 0.2;

    float roat = 0;

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

    bool up = true;
    int tick = 0;
    bool yup = true;
    int ytick = 0;

    void move() {
        // writeln("memory:", rotation);

        oldPosition = Vector3(position.x, position.y, position.z);

        tick++;
        if (tick > 50) {
            up = !up;
            tick = 0;
        }

        if (up) {
            position.x += 0.01;
            position.y += 0.02;
        } else {
            position.x -= 0.01;
            position.y -= 0.02;
        }

        ytick++;
        if (ytick > 100) {
            yup = !yup;
            ytick = 0;
        }
        if (yup) {
            position.z += 0.02;
        } else {
            position.z -= 0.02;
        }

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

        smoothRotate();

    }

    void smoothRotate() {
        Vector2 normalized = Vector2Normalize(Vector2Subtract(Vector2(position.x, position
                .z), Vector2(oldPosition.x, oldPosition.z)));

        float yaw = atan2(normalized.x, normalized.y);

        float distance = Vector2Distance(Vector2(position.x, position
                .z), Vector2(oldPosition.x, oldPosition.z));

        Vector2 pitchNormalized = Vector2Normalize(Vector2Subtract(Vector2(distance, position.y), Vector2(0, oldPosition
                .y)));
        float pitch = asin(-pitchNormalized.y);

        writeln("new:\n", position, "\nold:\n", oldPosition);

        rotation.y = yaw;
        rotation.x = pitch;
    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
