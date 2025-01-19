module graphics.texture_manager;

import raylib;
import std.container;
import std.string;

static final const class TextureManager {
static:
private:

    Texture2D*[string] database;

    //* BEGIN PUBLIC API.

    public void newTexture(string location) {
        Texture2D* thisTexture = new Texture2D();
        *thisTexture = LoadTexture(toStringz(location));

        database.remove("test");
    }

    //* BEGIN INTERNAL API.
}
