module graphics.camera_handler;

import raylib;

static final const class CameraHandler {
static:
public:

    Camera* camera = null;

    void initialize() {
        camera = new Camera();
        camera.position = Vector3(0, 4, 4);
        camera.up = Vector3(0, 1, 0);
        camera.target = Vector3(0, 0, 0);
        camera.fovy = 45.0;
        camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
    }

    void setPosition(Vector3 newPosition) {
        camera.position = newPosition;
    }

    void setTarget(Vector3 newTarget) {
        camera.target = newTarget;
    }

    float getFOV() {
        return camera.fovy;
    }

    void setFOV(float newFOV) {
        camera.fovy = newFOV;
    }

    Camera* getPointer() {
        return camera;
    }

    void doFreeCam() {
        UpdateCamera(camera, CameraMode.CAMERA_FREE);
    }

}
