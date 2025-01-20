module graphics.gui;

import raylib.raylib_types;

static final const class GUI {
static:
private:

    immutable Vector2 standardSize = Vector2(1920.0, 1080.0);
    float currentGUIScale = 1.0;

    //* BEGIN PUBLIC API.

    public float getGUIScale() {
        return currentGUIScale;
    }

    public void __update(Vector2 newWindowSize) {

    }

    //* BEGIN INTERNAL API.
}
