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

    void update(double delta) {
        move(delta);
    }

    bool up = true;
    double tick = 0;
    bool yup = true;
    double ytick = 0;

    void move(double delta) {
        // writeln("memory:", rotation);

        oldPosition = Vector3(position.x, position.y, position.z);

        tick += delta;

        if (tick > 50) {
            up = !up;
            tick = 0;
        }

        immutable double speed = 1.0;

        if (up) {
            position.x += delta * speed;
            position.y += delta * speed;
        } else {
            position.x -= delta * speed;
            position.y -= delta * speed;
        }

        ytick += delta;
        if (ytick > 100) {
            yup = !yup;
            ytick = 0;
        }
        if (yup) {
            position.z += delta * speed;
        } else {
            position.z -= delta * speed;
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

        // writeln("new:\n", position, "\nold:\n", oldPosition);

        rotation.y = yaw;
        rotation.x = pitch;
    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
