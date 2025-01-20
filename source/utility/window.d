module utility.window;

import raylib;

static final const class Window {
static:
private:

    //* BEGIN PUBLIC API.

    public int getWidth() {
        return GetRenderWidth();
    }

    public int getHeight() {
        return GetRenderHeight();
    }

    public Vector2 getSize() {
        return Vector2(getWidth(), getHeight());
    }

    //* BEGIN INTERNAL API.

}
