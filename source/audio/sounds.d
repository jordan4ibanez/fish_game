module audio.sounds;

import raylib;
import std.file;
import std.path;
import std.random;
import std.stdio;
import std.string;

private class SoundPool {
    Sound master;
    // Allows up to 4 overlapping instances at once.
    Sound[4] voices;
    size_t nextVoice = 0;

    // Load master and setup aliases pointing to the same RAM buffer.
    this(string filePath) {
        auto cStr = filePath.toStringz();
        master = LoadSound(cStr);
        foreach (i; 0 .. voices.length) {
            voices[i] = LoadSoundAlias(master);
        }
    }

    void play(float volume, float pitch) {
        Sound voice = voices[nextVoice];
        SetSoundVolume(voice, volume);
        SetSoundPitch(voice, pitch);
        PlaySound(voice);
        nextVoice = (nextVoice + 1) % voices.length;
    }

    // Play with a subtle random pitch shift.
    void playPitched(float volume, float pitchVariance) {
        float randomPitch = uniform(1.0f - pitchVariance, 1.0f + pitchVariance);
        play(volume, randomPitch);
    }

    void unload() {
        foreach (ref v; voices) {
            UnloadSoundAlias(v);
        }
        UnloadSound(master);
    }
}

static final const class Sounds {
static:
private:

    SoundPool[string] database;

public:

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
                    database[fileName] = new SoundPool(fullPath);
                }
            }
        }
    }

    void terminate() {
        foreach (pool; database) {
            pool.unload();
        }
    }

    void play(string name, float volume = 1.0f, float pitch = 1.0f) {
        if (name !in database) {
            throw new Error(name ~ " is not a sound.");
        }
        database[name].play(volume, pitch);
    }

    void playPitched(string name, float volume = 1.0f, float pitchVariance = 0.1f) {
        if (name !in database) {
            throw new Error(name ~ " is not a sound.");
        }
        database[name].playPitched(volume, pitchVariance);

    }

}
