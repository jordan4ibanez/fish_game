module graphics.font_handler;

import graphics.gui;
import raylib;
import std.math.rounding;
import std.stdio;
import std.string;

static final const class FontHandler {
static:
private:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font* font = null;
    immutable float spacing = -1;
    float currentFontSize = 1;

    //* BEGIN PUBLIC API.

    public void initialize() {
        font = new Font();

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>©";

        // This is a small hack to get the base size.
        Font tempFont = LoadFont(toStringz("font/roboto_condensed.ttf"));

        *font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), tempFont.baseSize * 2, cast(int*) codePointString, 0);

        UnloadFont(tempFont);
    }

    public Vector2 getTextSize(string text) {
        return MeasureTextEx(*font, toStringz(text), font.baseSize, spacing);
    }

    public void draw(string text, float x, float y, Color color = Colors.BLACK) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), font.baseSize, spacing, color);
    }

    public void drawShadowed(string text, float x, float y, Color foregroundColor = Colors.WHITE) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), font.baseSize, spacing, Colors.BLACK);
        DrawTextEx(*font, toStringz(text), Vector2(x - 1, y - 1), font.baseSize, spacing, foregroundColor);
    }

    public void terminate() {
        UnloadFont(*font);
        font = null;
    }

    public void __update() {
        
    }
    //* BEGIN INTERNAL API.

}
