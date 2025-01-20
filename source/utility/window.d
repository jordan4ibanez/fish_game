module utility.window;

import graphics.font_handler;
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

    public bool shouldStayOpen() {
        // This calls the update system to automatically make common utilities run.
        updateSystem();

        return WindowShouldClose();
    }

    //* BEGIN INTERNAL API.

    void updateSystem() {
        FontHandler.__update();
    }

}
