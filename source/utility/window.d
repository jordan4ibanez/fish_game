module utility.window;

import graphics.font_handler;
import graphics.gui;
import raylib;
import utility.delta;

static final const class Window {
static:

private:
    bool maximized = false;
    bool mouseLocked = false;

public:

    int getWidth() {
        return GetRenderWidth();
    }

    int getHeight() {
        return GetRenderHeight();
    }

    Vector2 getSize() {
        return Vector2(getWidth(), getHeight());
    }

    bool shouldStayOpen() {
        // This calls the update system to automatically make common utilities run.
        updateSystem();

        return !WindowShouldClose();
    }

    void maximize() {
        maximized = true;
        MaximizeWindow();
    }

    void unmaximize() {
        maximized = false;
        RestoreWindow();
    }

    void toggleMaximize() {
        if (maximized) {
            unmaximize();
        } else {
            maximize();
        }
    }

    void lockMouse() {
        mouseLocked = true;
        DisableCursor();
    }

    void unlockMouse() {
        mouseLocked = false;
        EnableCursor();
    }

    void toggleMouseLock() {
        if (mouseLocked) {
            unlockMouse();
        } else {
            lockMouse();
        }
    }

    bool isMouseLocked() {
        return mouseLocked;
    }

private:

    void updateSystem() {
        Delta.__calculateDelta();
        GUI.__update(getSize());
        FontHandler.__update();
    }

}
