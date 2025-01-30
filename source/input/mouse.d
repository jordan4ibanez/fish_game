module input.mouse;

import raylib;

static final const class Mouse {
static:
private:

    //? I like to have specific modules for things.

    //* BEGIN PUBLIC API.

    public Vector2 getDelta() {
        return GetMouseDelta();
    }

    public bool isButtonPressed(MouseButton button) {
        return IsMouseButtonPressed(button);
    }

    public bool isButtonDown(MouseButton button) {
        return IsMouseButtonDown(button);
    }

    //* BEGIN INTERNAL API.

}
