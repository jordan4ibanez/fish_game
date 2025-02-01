module level.lure;

import graphics.model_handler;
import graphics.texture_handler;
import raylib;
import std.stdio;
import utility.delta;

static final const class Lure {
static:
private:

    bool inWater = false;
    bool reeling = false;

    Vector3 position;
    Vector3 rotation;

    //* BEGIN PUBLIC API.

    public void loadLureData() {
        ModelHandler.loadModelFromFile("models/lures/deep_c_110.glb");
        TextureHandler.loadTexture("models/lures/deep_c_110.png");
        ModelHandler.setModelTexture("deep_c_110.glb", "deep_c_110.png");
        ModelHandler.setModelShader("deep_c_110.glb", "normal");
    }

    public void update() {
        if (!inWater) {
            return;
        }

        double delta = Delta.getDelta();

        immutable double restingAngle = 0;
        immutable double targetAngle = DEG2RAD * 25;

        if (reeling) {
            double newAngle = lerp(rotation.x, targetAngle, delta * 2.0);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotation.x = newAngle;
        } else {

            double newAngle = lerp(rotation.x, restingAngle, delta * 2.0);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotation.x = newAngle;

        }

        reeling = false;
    }

    public void reel() {
        reeling = true;
    }

    public void draw() {
        ModelHandler.draw("deep_c_110.glb", position, rotation);
    }

    public void setPosition(Vector3 newPosition) {
        position = newPosition;
    }

    public void setRotation(Vector3 newRotation) {
        rotation = newRotation;
    }

    public Vector3 getRotation() {
        return rotation;
    }

    public Vector3 getPosition() {
        return position;
    }

    public void setInWater() {
        inWater = true;
    }

    public void setOutOfWater() {
        inWater = false;
    }

    //* BEGIN INTERNAL API.

}
