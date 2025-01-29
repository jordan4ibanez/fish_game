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

    //* BEGIN INTERNAL API.

}
