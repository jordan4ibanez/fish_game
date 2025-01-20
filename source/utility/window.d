module utility.window;

import graphics.font_handler;
import graphics.gui;
import raylib;

static final const class Window {
static:
private:

    bool maximized = false;

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

        return !WindowShouldClose();
    }

    public void maximize() {
        MaximizeWindow();
    }

    public void unmaximize() {
        RestoreWindow();
    }

    //* BEGIN INTERNAL API.

    void updateSystem() {
        GUI.__update(getSize());
        FontHandler.__update();
    }

}
