module level.player;

import graphics.model_handler;
import level.ground;
import level.water;
import raylib;
import std.stdio;
import utility.delta;

static final const class Player {
static:
private:

    Vector3 position;
    Vector3 rotation;

    int playerHandBoneIndex = -1;

    //* BEGIN PUBLIC API.

    //!! NOTE:
    // Animation seems to be double the blender keyframes. So frame 30 is 60.

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
            if (personModel.bones[i].name[0 .. 6] == "Hand.R") {
                writeln("index ", i);
                playerHandBoneIndex = i;
                break;
            }
        }

    }

    public void updateFloating() {
        position.y = Water.getCollisionPoint(position.x, position.z);
        position.y -= 0.1;

        double delta = Delta.getDelta();

        rotation.y += delta;
    }

    public void draw() {
        ModelHandler.draw("boat.glb", position, rotation);

        Vector3 playerOnBoat = position;
        playerOnBoat.y += 0.6;
        ModelHandler.draw("person.glb", playerOnBoat, rotation);

        //? The song and dance you see below is to put the fishing pole in the player's hand.
        //? Thankfully modern x86_64 cpus do this trivialy, but it's a pain in the butt.

        Model* model = ModelHandler.getModelPointer("person.glb");

        AnimationContainer personAnimationContainer = ModelHandler.getAnimationContainer(
            "person.glb");
        ModelAnimation* animation = personAnimationContainer.animationData;

        Transform* transform = &animation.framePoses[0][playerHandBoneIndex];
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
    }

    //* BEGIN INTERNAL API.

}
