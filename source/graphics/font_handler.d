module graphics.font_handler;

import raylib;
import std.string;

static final const class FontHandler {
static:
private:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font* font = null;

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

    public void terminate() {
        UnloadFont(*font);
        font = null;
    }

    public void draw() {
        // DrawText("©", 0, 0, 100, Colors.WHITE);

        // DrawTextCodepoint(*font, 169, Vector2(0, 0), 100, Colors.WHITE);

        DrawTextEx(*font, "© <-there is my copyright logo :) ", Vector2(0, 0), font.baseSize, -1, Colors
                .BLACK);
    }

    //* BEGIN INTERNAL API.

}
