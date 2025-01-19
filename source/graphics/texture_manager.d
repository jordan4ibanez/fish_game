module graphics.texture_manager;

import raylib;
import std.container;
import std.regex;
import std.stdio;
import std.string;

static final const class TextureManager {
static:
private:

    Texture2D*[string] database;

    //* BEGIN PUBLIC API.

    public void newTexture(string location) {

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
            throw new Error("[TextureManager]: ");
        }

        Texture2D* thisTexture = new Texture2D();
        *thisTexture = LoadTexture(toStringz(location));

        database[fileName] = thisTexture;
    }

    public void terminate() {
        writeln("terminating texture");
    }

    //* BEGIN INTERNAL API.
}