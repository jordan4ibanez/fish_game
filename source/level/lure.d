module level.lure;

import graphics.model_handler;
import graphics.texture_handler;
import graphics.model_handler;

static final const class Lure {
static:
private:

    //* BEGIN PUBLIC API.

    public void loadLureData() {
        ModelHandler.loadModelFromFile("models/lures/deep_c_110.glb");
        TextureHandler.loadTexture("models/lures/deep_c_110.png");
        ModelHandler.setModelTexture("deep_c_110.glb", "deep_c_110.png");
        ModelHandler.setModelShader("deep_c_110.glb", "normal");
    }

    //* BEGIN INTERNAL API.

}
