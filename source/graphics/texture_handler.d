module graphics.texture_handler;

import raylib;
import std.container;
import std.regex;
import std.stdio;
import std.string;

static final const class TextureHandler {
static:
private:

    Texture2D*[string] database;

    //* BEGIN PUBLIC API.

    public void loadTexture(string location) {

        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("[TextureManager]: Texture must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            if (!outputFileName.endsWith(".png")) {
                throw new Error("[TextureManager]: Not a .png");
            }
            return outputFileName;
        }();

        if (fileName in database) {
            throw new Error("[TextureManager]: Tried to overwrite [" ~ fileName ~ "]");
        }

        Texture2D* thisTexture = new Texture2D();
        *thisTexture = LoadTexture(toStringz(location));

        if (!IsTextureValid(*thisTexture)) {
            throw new Error("[TextureManager]: Texture [" ~ location ~ "] is invalid.");
        }

        database[fileName] = thisTexture;
    }

    public Texture2D* getTexturePointer(string textureName) {
        if (textureName !in database) {
            throw new Error("[TextureManager]: Texture does not exist. " ~ textureName);
        }

        return database[textureName];
    }

    public void deleteTexture(string textureName) {
        if (textureName !in database) {
            throw new Error(
                "[TextureManager]: Texture does not exist. Cannot delete. " ~ textureName);
        }

        Texture* thisTexture = database[textureName];
        UnloadTexture(*thisTexture);
        database.remove(textureName);
    }

    public void terminate() {
        foreach (textureName, thisTexture; database) {
            UnloadTexture(*thisTexture);
        }

        database.clear();
    }

    //* BEGIN INTERNAL API.
}
