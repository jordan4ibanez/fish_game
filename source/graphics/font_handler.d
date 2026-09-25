module graphics.font_handler;

import graphics.gui;
import raylib;
import std.math.rounding;
import std.string;

static final const class FontHandler {
static:
public:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font* font = null;
    immutable float spacing = -1;
    float currentFontSize = 1;

    void initialize() {
        font = new Font();

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>©";

        *font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), 64, cast(int*) codePointString, 0);
    }

    Vector2 getTextSize(string text) {
        return MeasureTextEx(*font, toStringz(text), currentFontSize, spacing);
    }

    void draw(string text, float x, float y, Color color = Colors.BLACK) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), currentFontSize, spacing, color);
    }

    void drawShadowed(string text, float x, float y, Color foregroundColor = Colors.WHITE) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), currentFontSize, spacing, Colors.BLACK);
        DrawTextEx(*font, toStringz(text), Vector2(x - 1, y - 1), currentFontSize, spacing, foregroundColor);
    }

    void terminate() {
        if (font !is null) {
            UnloadFont(*font);
        }
        font = null;
    }

    void __update() {
        // This allows the font to look slightly off, like it's a texture font.
        currentFontSize = font.baseSize * (GUI.getGUIScale() * 0.75);
    }

}
