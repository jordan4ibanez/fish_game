module audio.sounds;

import raylib;
import std.file;
import std.path;
import std.stdio;
import std.string;

static final const class Sounds {
static:
private:

    Sound[string] database;

public:

    // todo: this needs a ring buffer or something.

    void load() {
        writeln("Loading sounds");
        foreach (DirEntry entry; dirEntries(absolutePath(getcwd()), SpanMode.depth)) {
            if (entry.isFile && entry.name.extension.toLower() == ".ogg") {

                string fullPath = entry.name;
                string fileName = fullPath.baseName;

                writeln("loading " ~ fullPath);

                // This may be sloppy, but I don't want it to be that sloppy.
                if (fileName in database) {
                    throw new Exception(fileName ~ " is a duplicate! Hit in: " ~ fullPath);
                } else {
                    database[fileName] = LoadSound(fullPath.toStringz);
                }
            }
        }
    }

    void play(string name) {
        if (name !in database) {
            throw new Error(name ~ " is not a sound.");
        }
        PlaySound(database[name]);
    }

}
