module level.player;

import graphics.camera_handler;
import graphics.model_handler;
import input.keyboard;
import input.mouse;
import level.ground;
import level.lure;
import level.water;
import raylib;
import std.math.algebraic;
import std.math.trigonometry;
import std.random;
import std.stdio;
import utility.delta;
import utility.window;

enum PlayerState {
    // First person.
    Aiming,
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
    Vector3 poleTipRealtimePosition;

    PlayerState state = PlayerState.Aiming;
    int playerHandBoneIndex = -1;

    int animationFrame = 0;

    double frameTimer = 0;

    // Casting variables.
    bool firstCastFrame = true;
    double castTimer = 0.0;
    immutable int castFrameMax = 230;
    immutable int castFrameMiddle = 230 / 2;
    immutable double castingDistanceMin = 10;
    immutable double castingDistanceMax = 30;
    // This is how wide of a triangulation you can cast.
    immutable double maxAngle = (40 * DEG2RAD);

    double castTumblePitch = 0;
    double castTumbleYaw = 0;

    double castProgressDistance = 0;
    double castProgress = 0;

    double lineCreationProgress = 0;
    Vector3[] lineData;
    double lineFallRestTimer = 0;

    //! Note: these need to be reset when the player changes spots.
    double castingYaw = 0.0;
    double castingDistance = castingDistanceMin;

    //* BEGIN PUBLIC API.

    //!! NOTE:
    // Animation seems to be double the blender keyframes. So frame 30 is 60-ish. 

    bool inittrigger = true;

    public void update() {
        double delta = Delta.getDelta();

        updateFloating();
        doControls();
        doLogic(delta);
        doAnimation();
        doCameraPositioning();

        //? This is for debugging in freecam. So you don't have to fly across the map.
        // if (inittrigger) {
        //     CameraHandler.setPosition(position);
        //     inittrigger = false;
        // }
    }

    public void setPosition(float x, float y, float z) {
        position = Vector3(x, y, z);
    }

    public Vector3 getPosition() {
        return position;
    }

    public Vector3 getPoleTipPosition() {
        return poleTipRealtimePosition;
    }

    public void triggerEmptyReelCompletion() {
        state = PlayerState.Aiming;
        castTimer = 0;
        // This instantly triggers a frame update.
        frameTimer = (1 / 60) + 0.001;
        animationFrame = 0;
        firstCastFrame = true;
        Lure.setOutOfWater();
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
                // writeln("index ", i);
                playerHandBoneIndex = i;
                break;
            }
        }
    }

    public void updateFloating() {
        position.y = Water.getCollisionPoint(position.x, position.z);
        position.y -= 0.1;

        // rotation.y += Delta.getDelta();
    }

    public void draw() {
        ModelHandler.draw("boat.glb", position, rotation);

        Vector3 playerOnBoat = position;
        playerOnBoat.y += 0.6;

        ModelHandler.playAnimation("person.glb", 0, animationFrame);

        // Make the player turn with the casting angle if they're in an interaction state.
        // Also, do not render the player if aiming. (first person mode)
        if (!state == PlayerState.Aiming) {
            switch (state) {
            case PlayerState.Casting, PlayerState.CastingArc, PlayerState.Water: {
                    Vector3 combinedRotation = rotation;
                    combinedRotation.y -= castingYaw;
                    ModelHandler.draw("person.glb", playerOnBoat, combinedRotation);
                }
                break;
            default: {
                    ModelHandler.draw("person.glb", playerOnBoat, rotation);
                }
            }
        }

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

        // If the player is in an interactive state, we want the animation components to rotate with their
        // aiming yaw. So we shall do that.
        switch (state) {
        case PlayerState.Aiming, PlayerState.Casting, PlayerState.CastingArc, PlayerState.Water: {
                matrixTransform = MatrixMultiply(matrixTransform, MatrixRotateY(
                        rotation.y - castingYaw));
            }
            break;
        default: {
                matrixTransform = MatrixMultiply(matrixTransform, MatrixRotateY(rotation.y));
            }
        }

        // Transform the socket using the transform of the character (angle and translate)
        matrixTransform = MatrixMultiply(matrixTransform, model.transform);

        Vector3 translationSpace;
        Quaternion quaternionRotation;
        Vector3 scaleSpace;
        MatrixDecompose(matrixTransform, &translationSpace, &quaternionRotation, &scaleSpace);

        Vector3 rotationSpace = QuaternionToEuler(quaternionRotation);

        translationSpace = Vector3Add(translationSpace, playerOnBoat);

        ModelHandler.draw("fishing_rod.glb", translationSpace, rotationSpace);

        //? The lure gets kind of complicated lol.

        Vector3 lureTranslation = translationSpace;

        immutable float poleSize = 1.635;
        Vector3 directionOfPole = Vector3Multiply(Vector3Normalize(Vector3(matrixTransform.m8, matrixTransform.m9,
                matrixTransform.m10)), Vector3(poleSize, poleSize, poleSize));

        // todo: fix these variable names, this is a mess.
        // todo: this is supposed to be the pole tip position.
        lureTranslation = Vector3Add(lureTranslation, directionOfPole);
        poleTipRealtimePosition = lureTranslation;

        // This is a trick to simulate the lure swinging during a cast.
        Vector2 poleTipPosition = Vector2(lureTranslation.x, lureTranslation.z);
        float poleTipDeltaDistance = Vector2Distance(poleTipPosition, oldPoleTipPosition);

        // Only draw the target when aiming.
        if (state == PlayerState.Aiming) {
            DrawSphere(getCastTarget(), 0.1, Colors.RED);
        }

        switch (state) {
        case PlayerState.Aiming, PlayerState.Menu: {
                lureTranslation.y -= 0.1;
                Lure.setPosition(lureTranslation);
                Lure.setRotation(Vector3(0, rotation.y + -castingYaw, 0));
            }
            break;
        case PlayerState.Casting: {

                // If this is the first cast tick, save and abort.
                if (firstCastFrame) {
                    oldPoleTipPosition = Vector2(lureTranslation.x, lureTranslation.z);
                    firstCastFrame = false;
                    break;
                }

                if (poleTipDeltaDistance > 0) {

                    Vector2 poleTipSwingDirection = Vector2Normalize(Vector2Subtract(oldPoleTipPosition,
                            poleTipPosition));

                    float dx = oldPoleTipPosition.x - poleTipPosition.x;
                    float dy = oldPoleTipPosition.y - poleTipPosition.y;
                    float yaw = (-atan2(dy, dx)) - (PI / 2);

                    oldPoleTipPosition = Vector2(lureTranslation.x, lureTranslation.z);

                    lureTranslation.y -= 0.1;

                    float swingX = poleTipSwingDirection.x * poleTipDeltaDistance;
                    float swingZ = poleTipSwingDirection.y * poleTipDeltaDistance;

                    lureTranslation.x += swingX;
                    lureTranslation.z += swingZ;

                    Lure.setPosition(lureTranslation);

                    Lure.setRotation(Vector3(0, yaw, 0));
                }
            }
            break;
        case PlayerState.CastingArc: {

                double currentProgressModified = (castProgress * PI);
                double arcHeight = (sin(currentProgressModified));

                if (abs(arcHeight) < 0.001) {
                    arcHeight = 0;
                }

                arcHeight -= Lerp(0.1, 0.0, castProgress);

                Vector3 progress = Vector3Lerp(lureTranslation, getCastTarget(), castProgress);
                progress.y += arcHeight;

                Lure.setPosition(progress);

                // Draw the line.

                if (lineData.length > 0) {
                    DrawLine3D(lureTranslation, lineData[0], Colors.BLACK);
                    foreach (i; 0 .. (lineData.length) - 1) {
                        Vector3 current = lineData[i];
                        Vector3 next = lineData[i + 1];

                        DrawLine3D(current, next, Colors.BLACK);
                    }
                    DrawLine3D(lineData[(lineData.length) - 1], progress, Colors.BLACK);
                } else {
                    DrawLine3D(lureTranslation, progress, Colors.BLACK);
                }

                // DrawSphere(progress, 0.1, Colors.ORANGE);
            }
            break;
        case PlayerState.Water: {
                DrawLine3D(lureTranslation, Lure.getPosition(), Colors.BLACK);
            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    //* BEGIN INTERNAL API.

    void doLogic(double delta) {
        switch (state) {
        case PlayerState.Aiming: {

            }
            break;
        case PlayerState.Casting: {
                if (animationFrame == castFrameMax) {
                    state = PlayerState.CastingArc;
                    castProgress = 0;

                    auto rnd = Random(unpredictableSeed());
                    castTumblePitch = uniform(0.1, 10.0, rnd);
                    castTumbleYaw = uniform(0.1, 10.0, rnd);

                    lineCreationProgress = 0;
                    lineData = new Vector3[](0);
                    lineCreationProgress = 0;
                }
            }
            break;
        case PlayerState.CastingArc: {

                immutable float waterLevel = Water.getWaterLevel();

                // immutable double max = cast(double)(cast(int) lineData.length);

                // Try to interpolate to a line that's falling onto the water.
                foreach (i, ref v; lineData) {
                    // todo: test out messing with the max to make a cool looking falling line.
                    double current = cast(double) i + 1;
                    double application = current * 0.1;

                    v.y -= delta * application;
                    if (v.y <= waterLevel) {
                        v.y = waterLevel;
                    }
                }

                if (castProgressDistance >= castingDistance) {
                    castProgressDistance = castingDistance;
                    lineFallRestTimer += delta;

                    // I worked hard on these line physics so you get to watch them. >:)
                    if (lineFallRestTimer >= 1.5) {
                        state = PlayerState.Water;
                        // todo: don't delete the line data.
                        lineData = null;

                        // When the state changes into the water state, we do some "magic" to snap everything into place.

                        Vector3 lurePosition = Lure.getPosition();
                        double x = position.x - lurePosition.x;
                        double z = position.z - lurePosition.z;
                        double lureYaw = atan2(x, z);
                        Lure.setRotation(Vector3(0, lureYaw, 0));

                        Lure.setInWater();
                    }
                } else {

                    double increase = delta * 12.0;
                    castProgressDistance += increase;
                    lineCreationProgress += increase;

                    if (lineCreationProgress >= 1.0) {
                        lineData ~= Lure.getPosition();
                        lineCreationProgress = 0;
                    }

                    Vector3 currentRotation = Lure.getRotation();

                    currentRotation.y += Delta.getDelta() * castTumbleYaw;
                    currentRotation.x += Delta.getDelta() * castTumblePitch;

                    Lure.setRotation(currentRotation);

                    lineFallRestTimer = 0;
                }

                castProgress = castProgressDistance / castingDistance;
            }
            break;
        case PlayerState.Menu: {

            }
            break;
        case PlayerState.Water: {
                if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    Lure.reel();
                }
            }
            break;
        default: {
                throw new Error("Oops");
            }
        }
    }

    void doAnimation() {
        switch (state) {
        case PlayerState.Aiming: {

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
        case PlayerState.Aiming: {

                Vector2 mouseDelta = Mouse.getDelta();

                // Begin forwards/backwards lure aiming control.

                double oldCastingDistance = castingDistance;

                castingDistance -= mouseDelta.y / 100.0;

                // Keep the distance within range.
                if (castingDistance < castingDistanceMin) {
                    castingDistance = castingDistanceMin;
                } else if (castingDistance > castingDistanceMax) {
                    castingDistance = castingDistanceMax;
                }

                // Don't let it go into the shore.
                if (lureCollidesWithShore()) {
                    castingDistance = oldCastingDistance;
                }

                // writeln(castingDistance);

                // Begin side/side radial lure aiming control.

                double oldCastingYaw = castingYaw;

                castingYaw += mouseDelta.x / 1500.0;

                if (castingYaw < -maxAngle) {
                    castingYaw = -maxAngle;
                } else if (castingYaw > maxAngle) {
                    castingYaw = maxAngle;
                }

                // Don't let it go into the shore.
                if (lureCollidesWithShore()) {
                    // First, try to bump the distance back.
                    // This hardcode also creates a jolty effect.
                    castingDistance -= 0.7;

                    castingYaw = oldCastingYaw;

                    if (lureCollidesWithShore()) {
                        // Welp that failed, move everything back.  
                        castingYaw = oldCastingYaw;
                        castingDistance += 0.7;
                    }
                }

                if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                    state = PlayerState.Casting;
                    castTimer = 0;
                    castProgressDistance = 0;
                }
            }
            break;
        case PlayerState.Casting: {

                // This is a weird player animation/state reset thing.
                // if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                //     state = PlayerState.Aiming;
                //     castTimer = 0;
                //     // This instantly triggers a frame update.
                //     frameTimer = (1 / 60) + 0.001;
                //     animationFrame = 0;
                //     firstCastFrame = true;
                //     break;
                // }

                castTimer += delta;

            }
            break;
        case PlayerState.CastingArc: {

                // if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                //     state = PlayerState.Aiming;
                //     castTimer = 0;
                //     // This instantly triggers a frame update.
                //     frameTimer = (1 / 60) + 0.001;
                //     animationFrame = 0;
                //     firstCastFrame = true;
                //     break;
                // }

            }
            break;
        case PlayerState.Menu: {

            }
            break;
        case PlayerState.Water: {
                if (Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    Lure.reel();
                }
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

    void doCameraPositioning() {
        switch (state) {
        case PlayerState.Aiming: {
                immutable float waterLevel = Water.getWaterLevel();
                Vector3 newCameraPosition = Vector3();
                newCameraPosition.x = position.x;
                // This is at the level of the player's chest but it looks better.
                newCameraPosition.y = waterLevel + 1.6;
                newCameraPosition.z = position.z;

                CameraHandler.setPosition(newCameraPosition);

                //! Debugging.
                // Vector3 target = getCastTarget();
                // target.x -= 0.5;
                // target.y += 0.5;
                // target.z -= 0.5;

                // CameraHandler.setPosition(target);

                CameraHandler.setTarget(getCastTarget());

            }
            break;
        case PlayerState.Casting, PlayerState.CastingArc: {
                immutable float shift = 2.6;
                immutable float distance = 2;
                immutable float waterLevel = Water.getWaterLevel();

                float rotated = (rotation.y + (PI / shift)) + castingYaw;
                float x = cos(rotated) * distance;
                float z = sin(rotated) * distance;

                Vector3 newCameraPosition = Vector3();
                newCameraPosition.x = position.x + x;
                newCameraPosition.y = waterLevel + 1.6;
                newCameraPosition.z = position.z + z;

                CameraHandler.setPosition(newCameraPosition);

                rotated -= PI / 1.25;

                x = cos(rotated) * distance;
                z = sin(rotated) * distance;

                Vector3 newTargetPosition = Vector3();
                newTargetPosition.x = position.x + x;
                newTargetPosition.y = waterLevel + 1.6;
                newTargetPosition.z = position.z + z;

                CameraHandler.setTarget(newTargetPosition);
            }
            break;
        case PlayerState.Menu: {
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
            }
            break;
        case PlayerState.Water: {
                // todo: fish focus thing.
                Vector3 lurePosition = Lure.getPosition();
                CameraHandler.setTarget(lurePosition);

                lurePosition.x -= 1;
                lurePosition.y += 1;
                lurePosition.z -= 1;

                CameraHandler.setPosition(lurePosition);

            }
            break;
        default: {
                throw new Error("Oops");
            }
        }

        if (state == PlayerState.Menu) {

        } else if (state == PlayerState.Casting) {

        }
    }

    // This will compose the imaginary yaw and distance into the real world position.
    Vector3 getCastTarget() {
        Vector3 castTarget;

        double totalYaw = (rotation.y + castingYaw) - (PI / 2);

        castTarget.x = (cos(totalYaw) * castingDistance) + position.x;
        castTarget.z = (sin(totalYaw) * castingDistance) + position.z;

        castTarget.y = Water.getCollisionPoint(castTarget.x, castTarget.z);

        return castTarget;
    }

    bool lureCollidesWithShore() {

        double totalYaw = (rotation.y + castingYaw) - (PI / 2);

        float x = (cos(totalYaw) * castingDistance) + position.x;
        float z = (sin(totalYaw) * castingDistance) + position.z;

        float waterHeight = Water.getCollisionPoint(x, z);
        float groundHeight = Ground.getCollisionPoint(x, z);

        return (waterHeight - groundHeight) < 0.3;
    }

}
