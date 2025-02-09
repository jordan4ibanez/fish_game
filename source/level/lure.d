module level.lure;

import graphics.model_handler;
import graphics.texture_handler;
import level.ground;
import level.player;
import level.water;
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
    double reelSpeed = 0;
    double lureFloatVelocity = 0;

    // If the lure hits something,I don't want to explode the player's ears.
    // So I set it to only be allowed to trigger the "thunk" noise every 0.25 seconds.
    double hitThingSoundTimer = 0;
    immutable double frequencySoundHitThings = 0.25;

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

        if (hitThingSoundTimer < 1) {
            hitThingSoundTimer += delta;
        }

        immutable double restingAngle = 0;
        immutable double targetAngle = DEG2RAD * 25;

        immutable double reelTargetSpeed = 1;
        immutable double reelAcceleration = 7;

        // Firstly, the lure needs to face the direction of the player's pole tip internally.
        Vector3 poleTipPosition = Player.getPoleTipPosition();
        double x = poleTipPosition.x - position.x;
        double z = poleTipPosition.z - position.z;
        double lureYaw = atan2(x, z);
        rotation.y = lureYaw;

        //? This is the prototype logic for the deep-c 110 and deep-c 220 lures.
        if (reeling) {
            double newAngle = lerp(rotationAnimated.x, targetAngle, delta * reelAcceleration);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotationAnimated.x = newAngle;

            reelSpeed += delta * reelAcceleration;

            if (reelSpeed >= reelTargetSpeed) {
                reelSpeed = reelTargetSpeed;
            }
        } else {
            double newAngle = lerp(rotationAnimated.x, restingAngle, delta * reelAcceleration);
            if (newAngle == float.nan) {
                newAngle = targetAngle;
            }
            rotationAnimated.x = newAngle;

            reelSpeed -= delta * reelAcceleration;

            if (reelSpeed <= 0) {
                reelSpeed = 0;
            }
        }

        // The steeper the lure gets the faster it swims.
        double swimSpeed = rotationAnimated.x / targetAngle;
        double swimSpeedMultiplier = 20;
        swimAnimation += delta * swimSpeedMultiplier * swimSpeed;
        if (swimAnimation >= PI * 2) {
            swimAnimation -= PI * 2;
        }
        double swimAngle = cos(swimAnimation) / 2.0;
        rotationAnimated.y = rotation.y + swimAngle;

        //? The lure uses a combination of animated rotation along with static rotation to not make the player motion sick.

        // The horizontal movement of the Deep-C 110 and Deep-C 220.
        Vector3 velocity = Vector3();
        double lureInternalYaw = rotation.y - (PI / 2);
        velocity.x = cos(lureInternalYaw);
        velocity.z = sin(-lureInternalYaw);

        // Lure dives down when reeled.
        if (reeling) {
            double diveAmount = (rotationAnimated.x / targetAngle);
            velocity.y -= diveAmount;
            lureFloatVelocity = 0;

        }

        double reelSpeedInTime = reelSpeed * delta;
        velocity = Vector3Multiply(velocity, Vector3(reelSpeedInTime, reelSpeedInTime, reelSpeedInTime));
        immutable double lureMaxFloatVelocity = 0.5;

        // Lure floats back up smoothly when not reeling.
        if (!reeling) {
            lureFloatVelocity += delta * 0.5;

            if (lureFloatVelocity >= lureMaxFloatVelocity) {
                lureFloatVelocity = lureMaxFloatVelocity;
            }
            double diveAmount = (1 - (rotationAnimated.x / targetAngle)) * lureFloatVelocity;
            velocity.y += diveAmount * delta;
        }

        // When you get within 5 units of the pole, you start to reel straight up towards the water.
        Vector2 lurePosition2d = Vector2(position.x, position.z);
        Vector2 poleTipPosition2d = Vector2(poleTipPosition.x, poleTipPosition.z);
        double distanceFromTip2d = Vector2Distance(lurePosition2d, poleTipPosition2d);
        if (reeling && distanceFromTip2d < 5) {

            // This calculation is not even remotely accurate but it works.
            double pitch = (poleTipPosition.y - position.y) / (distanceFromTip2d * 2);
            pitch = pitch * Vector2Length(Vector2(velocity.x, velocity.z));
            velocity.y = pitch;
        }

        position += velocity;

        // Do not let the lure fly (literally) out of the water.
        double waterHeighAtPosition = Water.getCollisionPoint(position.x, position.z);

        if (position.y >= waterHeighAtPosition) {
            position.y = waterHeighAtPosition;
            lureFloatVelocity = 0;
        }

        // Do not let the lure sink through the ground.
        double groundHeightAtPosition = Ground.getCollisionPoint(position.x, position.z);
        if (position.y <= groundHeightAtPosition) {
            // + 0.1 to simulate a "bounce"
            position.y = groundHeightAtPosition;

            if (hitThingSoundTimer > frequencySoundHitThings) {
                hitThingSoundTimer = 0;
                writeln("hit ground sound");
            }
            lureFloatVelocity = 0;
        }

        if (distanceFromTip2d < 0.5) {
            Player.triggerEmptyReelCompletion();
        }

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

    public bool isInWater() {
        return inWater;
    }

    public void setOutOfWater() {
        inWater = false;
    }

    //* BEGIN INTERNAL API.

}
