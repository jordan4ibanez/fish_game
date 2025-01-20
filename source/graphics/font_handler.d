module graphics.font_handler;

import raylib;
import std.string;

static final const class FontHandler {
static:
private:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font* font = null;
    float fontHeight;
    immutable float spacing = -1;

    //* BEGIN PUBLIC API.

    public void initialize() {
        font = new Font();

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>©";

        Font tempFont = LoadFont(toStringz("font/roboto_condensed.ttf"));

        *font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), tempFont.baseSize, cast(int*) codePointString, 0);

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
    //* BEGIN INTERNAL API.

}
