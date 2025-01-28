module level.player;

import graphics.camera_handler;
import graphics.model_handler;
import input.keyboard;
import level.ground;
import level.lure;
import level.water;
import raylib;
import std.math.algebraic;
import std.math.trigonometry;
import std.stdio;
import utility.delta;
import utility.window;

enum PlayerState {
    // First person.
    Browsing,
    // To the right. This one also includes the lure flying through the air in CastingArc.
    Casting,
    CastingArc,
    // Further back to the left.
    Menu,
    // Underwater lure cam.
    Water
}

static final const class Player {
static:
private:

    Vector3 position;
    Vector3 rotation;
    Vector2 oldPoleTipPosition;

    PlayerState state = PlayerState.Menu;
    int playerHandBoneIndex = -1;

    int animationFrame = 0;

    double frameTimer = 0;

    // Casting variables.
    double castTimer = 0.0;
    immutable int castFrameMax = 230;
    immutable int castFrameMiddle = 230 / 2;

    //* BEGIN PUBLIC API.

    //!! NOTE:
    // Animation seems to be double the blender keyframes. So frame 30 is 60-ish. 

    bool inittrigger = true;

    public void update() {
        double delta = Delta.getDelta();
        updateFloating();
        doControls();
        doLogic();
        doAnimation();

        if (inittrigger) {
            CameraHandler.setPosition(position);
            inittrigger = false;
        }

        if (Window.isMouseLocked()) {
            CameraHandler.doFreeCam();
        }

    }

    public void setPosition(float x, float y, float z) {
        position = Vector3(x, y, z);
    }

    public void setDefaultPosition() {
        Vector2 groundSize = Ground.getSizeFloating();
        position.x = groundSize.x / 2.0;
        position.z = groundSize.y / 2.0;
        ModelHandler.playAnimation("person.glb", 0, 0);
        rotation.y = PI / 2;

        Model* personModel = ModelHandler.getModelPointer("person.glb");

        foreach (i; 0 .. personModel.boneCount) {
            if (personModel.bones[i].name[0 .. 9] == "MiddleI.R") {
                writeln("index ", i);
                playerHandBoneIndex = i;
                break;
            }
        }
    }

    public void updateFloating() {
        position.y = Water.getCollisionPoint(position.x, position.z);
        position.y -= 0.1;

        // rotation.y += delta;
    }

    public void draw() {
        ModelHandler.draw("boat.glb", position, rotation);

        Vector3 playerOnBoat = position;
        playerOnBoat.y += 0.6;

        ModelHandler.playAnimation("person.glb", 0, animationFrame);

        ModelHandler.draw("person.glb", playerOnBoat, rotation);

        //? The song and dance you see below is to put the fishing pole in the player's hand.
        //? Thankfully modern x86_64 cpus do this trivialy, but it's a pain in the butt.

        Model* model = ModelHandler.getModelPointer("person.glb");

        AnimationContainer personAnimationContainer = ModelHandler.getAnimationContainer(
            "person.glb");
        ModelAnimation* animation = personAnimationContainer.animationData;

        Transform* transform = &animation.framePoses[animationFrame][playerHandBoneIndex];
        Quaternion inRotation = model.bindPose[playerHandBoneIndex].rotation;
        Quaternion outRotation = transform.rotation;

        // Calculate socket rotation (angle between bone in initial pose and same bone in current animation frame)
        Quaternion matrixRotate = QuaternionMultiply(outRotation, QuaternionInvert(inRotation));

        Matrix matrixTransform = QuaternionToMatrix(matrixRotate);

        // Translate socket to its position in the current animation
        matrixTransform = MatrixMultiply(matrixTransform, MatrixTranslate(transform.translation.x, transform
                .translation.y, transform.translation.z));

        matrixTransform = MatrixMultiply(matrixTransform, MatrixRotateY(rotation.y));

        // Transform the socket using the transform of the character (angle and translate)
        matrixTransform = MatrixMultiply(matrixTransform, model.transform);

        Vector3 translationSpace;
        Quaternion quaternionRotation;
        Vector3 scaleSpace;
        MatrixDecompose(matrixTransform, &translationSpace, &quaternionRotation, &scaleSpace);

        Vector3 rotationSpace = QuaternionToEuler(quaternionRotation);

        translationSpace = Vector3Add(translationSpace, playerOnBoat);

        ModelHandler.draw("fishing_rod.glb", translationSpace, rotationSpace);

        // Draw mesh at socket position with socket angle rotation
        // DrawMesh(equipModel[i].meshes[0], equipModel[i].materials[1], matrixTransform);

        //? The lure gets kind of complicated lol.

        Vector3 lureTranslation = translationSpace;

        immutable float poleSize = 1.635;
        Vector3 directionOfPole = Vector3Multiply(Vector3Normalize(Vector3(matrixTransform.m8, matrixTransform.m9,
                matrixTransform.m10)), Vector3(poleSize, poleSize, poleSize));

        lureTranslation = Vector3Add(lureTranslation, directionOfPole);

        // This is a trick to simulate the lure swinging during a cast.
        Vector2 poleTipPosition = Vector2(lureTranslation.x, lureTranslation.z);
        float poleTipDeltaDistance = Vector2Distance(poleTipPosition, oldPoleTipPosition);

        switch (state) {
        case PlayerState.Browsing, PlayerState.Menu: {
                lureTranslation.y -= 0.1;
                Lure.setPosition(lureTranslation);
            }
            break;
        case PlayerState.Casting: {
                if (poleTipDeltaDistance > 0) {

                    Vector2 poleTipSwingDirection = Vector2Normalize(Vector2Subtract(oldPoleTipPosition,
                            poleTipPosition));

                    oldPoleTipPosition = Vector2(lureTranslation.x, lureTranslation.z);

                    lureTranslation.y -= 0.1;

                    float swingX = poleTipSwingDirection.x * poleTipDeltaDistance;
                    float swingZ = poleTipSwingDirection.y * poleTipDeltaDistance;

                    lureTranslation.x += swingX;
                    lureTranslation.z += swingZ;

                    Lure.setPosition(lureTranslation);
                }
            }
            break;
        case PlayerState.CastingArc: {

            }
            break;
        case PlayerState.Water: {

            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    //* BEGIN INTERNAL API.

    void doLogic() {
        switch (state) {
        case PlayerState.Browsing: {

            }
            break;
        case PlayerState.Casting: {
                if (animationFrame == castFrameMax) {

                }
            }
            break;
        case PlayerState.CastingArc: {

            }
            break;
        case PlayerState.Menu: {

            }
            break;
        case PlayerState.Water: {

            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    void doAnimation() {
        switch (state) {
        case PlayerState.Browsing: {

            }
            break;
        case PlayerState.Casting: {
                doCastAnimation();

            }
            break;
        case PlayerState.CastingArc: {

                break;
            }
            break;
        case PlayerState.Menu: {

            }
            break;
        case PlayerState.Water: {

            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    void doControls() {

        double delta = Delta.getDelta();

        switch (state) {
        case PlayerState.Browsing: {

            }
            break;
        case PlayerState.Casting: {

                // This is a weird player animation/state reset thing.
                if (Keyboard.isPressed(KeyboardKey.KEY_SPACE)) {
                    state = PlayerState.Menu;
                    castTimer = 0;
                    frameTimer = (1 / 60) + 0.001;
                    animationFrame = 0;
                    doCastAnimation();
                    break;
                }

                castTimer += delta;

            }
            break;
        case PlayerState.CastingArc: {

            }
            break;
        case PlayerState.Menu: {
                // fixme: this is temporary debugging.
                if (Keyboard.isPressed(KeyboardKey.KEY_SPACE)) {
                    state = PlayerState.Casting;
                    castTimer = 0;
                }

            }
            break;
        case PlayerState.Water: {

            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    void doCastAnimation() {
        double delta = Delta.getDelta();
        frameTimer += delta;
        if (frameTimer < 1 / 60) {
            return;
        }

        if (animationFrame < castFrameMiddle) {
            animationFrame += 2;
        } else {
            animationFrame += 6;
        }
        if (animationFrame > castFrameMax) {
            animationFrame = castFrameMax;
        }
    }

    void cameraPositioning() {

        // todo: this should probably be a switch lol.

        // 2.6 for casting and also invert the - +

        if (state == PlayerState.Menu) {

            immutable float shiftFront = 5;
            immutable float shiftBack = 1.05;
            immutable float distance = 8;
            immutable float waterLevel = Water.getWaterLevel();

            float rotated = (-rotation.y) - (PI / shiftFront);
            float x = cos(rotated) * distance;
            float z = sin(rotated) * distance;

            Vector3 newCameraPosition = Vector3();
            newCameraPosition.x = position.x + x;
            newCameraPosition.y = waterLevel + 2;
            newCameraPosition.z = position.z + z;

            CameraHandler.setPosition(newCameraPosition);

            rotated = (-rotation.y) + (PI / shiftBack);

            x = cos(rotated) * distance;
            z = sin(rotated) * distance;

            Vector3 newTargetPosition = Vector3();
            newTargetPosition.x = position.x + x;
            newTargetPosition.y = waterLevel + 2;
            newTargetPosition.z = position.z + z;

            CameraHandler.setTarget(newTargetPosition);
        } else if (state == PlayerState.Casting) {

            immutable float shift = 2.6;
            immutable float distance = 3;
            immutable float waterLevel = Water.getWaterLevel();

            float rotated = rotation.y + (PI / shift);
            float x = cos(rotated) * distance;
            float z = sin(rotated) * distance;

            Vector3 newCameraPosition = Vector3();
            newCameraPosition.x = position.x + x;
            newCameraPosition.y = waterLevel + 2;
            newCameraPosition.z = position.z + z;

            CameraHandler.setPosition(newCameraPosition);

            rotated = rotation.y - (PI / shift);

            x = cos(rotated) * distance;
            z = sin(rotated) * distance;

            Vector3 newTargetPosition = Vector3();
            newTargetPosition.x = position.x + x;
            newTargetPosition.y = waterLevel + 2;
            newTargetPosition.z = position.z + z;

            CameraHandler.setTarget(newTargetPosition);

        }

    }

}
