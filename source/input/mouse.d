module input.mouse;

import raylib;

static final const class Mouse {
static:
public:

    Vector2 getDelta() {
        return GetMouseDelta();
    }

    bool isButtonPressed(MouseButton button) {
        return IsMouseButtonPressed(button);
    }

    bool isButtonDown(MouseButton button) {
        return IsMouseButtonDown(button);
    }

}
