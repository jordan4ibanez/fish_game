module level.level;

import level.ground;
import level.water;

static final const class Level {
static:
private:

    bool loaded = false;

    //* BEGIN PUBLIC API.

    public void load(string levelDirectory) {
        if (loaded) {
            throw new Error("[Level]: Unload the level first.");
        }
        Ground.load(levelDirectory);
        Water.load();

        loaded = true;
    }

    public void unload() {
        throw new Error("[Level]: unloading not implemented");
        loaded = false;
    }

    //* BEGIN INTERNAL API.

}
