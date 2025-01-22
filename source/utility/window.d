module utility.window;

import graphics.font_handler;
import graphics.gui;
import raylib;

static final const class Window {
static:
private:

    bool maximized = false;
    bool mouseLocked = false;

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
        maximized = true;
        MaximizeWindow();
    }

    public void unmaximize() {
        maximized = false;
        RestoreWindow();
    }

    public void toggleMaximize() {
        if (maximized) {
            unmaximize();
        } else {
            maximize();
        }
    }

    public void lockMouse() {
        mouseLocked = true;
        DisableCursor();
    }

    public void unlockMouse() {
        mouseLocked = false;
        EnableCursor();
    }

    public void toggleMouseLock() {
        if (mouseLocked) {
            unlockMouse();
        } else {
            lockMouse();
        }
    }

    //* BEGIN INTERNAL API.

    void updateSystem() {
        GUI.__update(getSize());
        FontHandler.__update();
    }

}
