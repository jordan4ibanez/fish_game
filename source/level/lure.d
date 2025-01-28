module level.lure;

import graphics.model_handler;
import graphics.texture_handler;
import raylib;

static final const class Lure {
static:
private:

    Vector3 position;

    //* BEGIN PUBLIC API.

    public void loadLureData() {
        ModelHandler.loadModelFromFile("models/lures/deep_c_110.glb");
        TextureHandler.loadTexture("models/lures/deep_c_110.png");
        ModelHandler.setModelTexture("deep_c_110.glb", "deep_c_110.png");
        ModelHandler.setModelShader("deep_c_110.glb", "normal");
    }

    public void draw() {
        ModelHandler.draw("deep_c_110.glb", position);
    }

    public void setPosition(Vector3 newPosition) {
        position = newPosition;
    }

    //* BEGIN INTERNAL API.

}
