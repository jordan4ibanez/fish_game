module graphics.camera_handler;

import raylib;

static final const class CameraHandler {
static:
private:

    Camera* camera = null;

    //* BEGIN PUBLIC API.

    public void initialize() {
        camera = new Camera();
        camera.position = Vector3(0, 4, 4);
        camera.up = Vector3(0, 1, 0);
        camera.target = Vector3(0, 0, 0);
        camera.fovy = 45.0;
        camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
    }

    public void setPosition(float x, float y, float z) {
        camera.position = Vector3(x, y, z);
    }

    public void setTarget(float x, float y, float z) {
        camera.target = Vector3(x, y, z);
    }

    public float getFOV() {
        return camera.fovy;
    }

    public void setFOV(float newFOV) {
        camera.fovy = newFOV;
    }

    public Camera* getPointer() {
        return camera;
    }

    //* BEGIN INTERNAL API.

}
