module level.fish_definitions;

import core.stdc.tgmath;
import level.ground;
import level.water;
import raylib;
import std.conv;
import std.math.algebraic;
import std.stdio;
import utility.delta;
import utility.math_stuff;
import utility.uuid;

enum FishState {
    Idle,
    Looking,
    RandomTarget,
    Turning,
    Following,
    Fight
}

FishState randomState() {
    return [FishState.Idle, FishState.Looking, FishState.RandomTarget][giveRandomInt(0, 3)];
}

abstract class Fish {
    Vector3 oldPosition = Vector3(0, 0, 0);
    Vector3 position = Vector3(0, 0, 0);
    // Pitch and yaw.
    Vector3 rotation = Vector3(0, 0, 0);

    float scale = 1;
    ulong uuid = 0;
    float collisionVertical = 0.2;

    // Behavioral variables.
    FishState state = FishState.Looking;
    Vector3 lookTarget;
    double turnLerpProgress = 0;
    double behaviorTimer = 0;
    double lookAroundTimer = 0;
    bool retrigger = false;
    double movementSpeed = 0;

    string __model = "undefined";

    this() {
        uuid = UUID.next();

        behaviorTimer = giveRandomDouble(0.5, 4.0);

        Vector2 mapSize = Ground.getSizeFloating();
        position.x = mapSize.x / 2.0;
        position.z = mapSize.y / 2.0;
    }

    void resetStateData() {
        behaviorTimer = 0;
        lookAroundTimer = 0;
        turnLerpProgress = 0;
        retrigger = false;
    }

    void turnToTarget(double delta) {
        // Calculating yaw.
        Vector2 normalized = Vector2Normalize(Vector2Subtract(Vector2(lookTarget.x, lookTarget.z), Vector2(
                position.x, position.z)));
        float yaw = atan2(normalized.x, normalized.y);
        // Calculating pitch.
        float distance = Vector2Distance(Vector2(position.x, position.z), Vector2(lookTarget.x, lookTarget
                .z));
        Vector2 pitchNormalized = Vector2Normalize(Vector2Subtract(Vector2(distance, lookTarget.y), Vector2(0, position
                .y)));
        float pitch = asin(-pitchNormalized.y);

        Vector2 lerpedTurn = Vector2Lerp(Vector2(rotation.x, rotation.y), Vector2(pitch, yaw), turnLerpProgress);

        rotation.x = lerpedTurn.x;
        rotation.y = lerpedTurn.y;

        // writeln(turnLerpProgress);

        turnLerpProgress += delta / 1000;
    }

    void selectRandomTargetPosition() {
        Vector2 map2dRange = Ground.getSizeFloating();

        // Limit the range.
        map2dRange.x -= 1;
        map2dRange.y -= 1;

        float selectedX;
        float selectedZ;
        float minY;
        float maxY;

        // Reroll until the fish can fit in the spot.
        while (true) {
            selectedX = giveRandomFloat(1.0, map2dRange.x);
            selectedZ = giveRandomFloat(1.0, map2dRange.y);
            minY = Ground.getCollisionPoint(selectedX, selectedZ) + collisionVertical;
            maxY = Water.getCollisionPoint(selectedX, selectedZ) - collisionVertical;
            if (minY <= maxY) {
                break;
            }
        }

        //? Useful for debugging.
        // selectedX = giveRandomFloat(position.x - 3, position.x + 3);
        // selectedZ = giveRandomFloat(position.x - 3, position.x + 3);
        // minY = Ground.getCollisionPoint(selectedX, selectedZ) + collisionVertical;
        // maxY = Water.getCollisionPoint(selectedX, selectedZ) - collisionVertical;

        float selectedY = giveRandomFloat(minY, maxY);

        lookTarget = Vector3(selectedX, selectedY, selectedZ);

        writeln(lookTarget);

        turnLerpProgress = 0;

    }

    @property string model() {
        return this.__model;
    }

    void update(double delta) {

        turnToTarget(delta);

        switch (state) {
        case FishState.Idle: {
                idle(delta);
                break;
            }
        case FishState.Looking: {
                looking(delta);
                break;
            }
        case FishState.RandomTarget: {
                randomTarget(delta);
                break;
            }
        case FishState.Turning: {
                turning(delta);
                break;
            }
        case FishState.Following: {
                following(delta);
                break;
            }
        case FishState.Fight: {
                fight(delta);
                break;
            }
        default: {
                throw new Error("I don't know how this got to here.");
            }
        }
    }

    // bool up = true;
    // double tick = 0;
    // bool yup = true;
    // double ytick = 0;

    // void move() {
    //     // writeln("memory:", rotation);

    //     immutable double delta = Delta.getDelta();

    //     oldPosition = Vector3(position.x, position.y, position.z);

    //     tick += delta;

    //     if (tick > 3) {
    //         up = !up;
    //         tick = 0;
    //     }

    //     immutable double speed = 1.0;

    //     if (up) {
    //         position.x += delta * speed;
    //         position.y += delta * speed;
    //     } else {
    //         position.x -= delta * speed;
    //         position.y -= delta * speed;
    //     }

    //     ytick += delta;
    //     if (ytick > 4) {
    //         yup = !yup;
    //         ytick = 0;
    //     }
    //     if (yup) {
    //         position.z += delta * speed;
    //     } else {
    //         position.z -= delta * speed;
    //     }

    //     if (position.x < 1) {
    //         position.x = 1;
    //     } else if (position.x > Ground.getWidth() - 1.0) {
    //         position.x = Ground.getWidth() - 1.0;
    //     }

    //     if (position.z < 1) {
    //         position.z = 1;
    //     } else if (position.z > Ground.getHeight() - 1.0) {
    //         position.z = Ground.getHeight() - 1.0;
    //     }

    //     smoothRotate();

    // }

    // void smoothRotate() {
    //     Vector2 normalized = Vector2Normalize(Vector2Subtract(Vector2(position.x, position
    //             .z), Vector2(oldPosition.x, oldPosition.z)));

    //     // If the fish didn't move, stop.
    //     if (abs(Vector2Length(normalized)) <= 0.000001) {
    //         return;
    //     }

    //     float yaw = atan2(normalized.x, normalized.y);

    //     float distance = Vector2Distance(Vector2(position.x, position
    //             .z), Vector2(oldPosition.x, oldPosition.z));

    //     Vector2 pitchNormalized = Vector2Normalize(Vector2Subtract(Vector2(distance, position.y), Vector2(0, oldPosition
    //             .y)));
    //     float pitch = asin(-pitchNormalized.y);

    //     // writeln("new:\n", position, "\nold:\n", oldPosition);

    //     rotation.y = yaw;
    //     rotation.x = pitch;
    // }

    void idle(double delta) {
        // todo: idle animation.

        writeln("this: ", behaviorTimer);

        behaviorTimer -= delta;

        if (behaviorTimer <= 0.0) {
            state = randomState();
            resetStateData();
        }
    }

    void looking(double delta) {
        // todo: tail turning animation.

        if (lookAroundTimer <= 0) {
            if (retrigger) {
                writeln("RETRIGGER.");
                if (giveRandomDouble(0.0, 1.0) > 0.5) {
                    resetStateData();
                    state = randomState();
                }
            } else {
                lookAroundTimer = giveRandomDouble(1.0, 2.0);
                retrigger = true;
                selectRandomTargetPosition();
            }
        }

        // writeln("LOOKING! " ~ to!string(lookAroundTimer));

        lookAroundTimer -= delta;

        // if (behaviorTimer <= 0.0) {
        //     state = randomState();
        //     writeln(state);
        // }
    }

    void randomTarget(double delta) {
        if (behaviorTimer <= 0.0) {
            state = randomState();
            writeln(state);
        }
    }

    void turning(double delta) {

    }

    void following(double delta) {

    }

    void fight(double delta) {

    }
}

class LargeMouthBass : Fish {
    this() {
        this.__model = "largemouth.glb";
    }
}
