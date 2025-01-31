module level.lure;

import graphics.model_handler;
import graphics.texture_handler;
import level.player;
import raylib;
import std.math.trigonometry;
import std.stdio;
import utility.delta;

static final const class Lure {
static:
private:

    bool inWater = false;
    bool reeling = false;

    Vector3 position;
    Vector3 rotation;
    // The actual rotation is stored in rotation.
    // The modified animation rotation is in rotation animated.
    Vector3 rotationAnimated;

    // Lure reeling behavioral logic.
    double swimAnimation = 0;

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

        //? This is the prototype logic for the deep-c 110 and deep-c 220 lures.
        if (reeling) {
            double newAngle = lerp(rotationAnimated.x, targetAngle, delta * 2.0);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotationAnimated.x = newAngle;
        } else {
            double newAngle = lerp(rotationAnimated.x, restingAngle, delta * 2.0);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotationAnimated.x = newAngle;
        }

        // The steeper the lure gets the faster it swims.
        double swimSpeed = rotationAnimated.x / targetAngle;

        swimAnimation += delta * 12 * swimSpeed;
        if (swimAnimation >= PI * 2) {
            swimAnimation -= PI * 2;
        }

        double swimAngle = cos(swimAnimation) / 2.0;

        rotationAnimated.y = rotation.y + swimAngle;

        reeling = false;
    }

    public void reel() {
        reeling = true;
    }

    public void draw() {
        ModelHandler.draw("deep_c_110.glb", position, rotationAnimated);
    }

    public void setPosition(Vector3 newPosition) {
        position = newPosition;
    }

    public void setRotation(Vector3 newRotation) {
        rotation = newRotation;
        rotationAnimated = newRotation;
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
