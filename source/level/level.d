module level.level;

import level.fish_tank;
import level.ground;
import level.lure;
import level.player;
import level.water;

static final const class Level {
static:
private:

    // If you're in a level, this logic container will get called.

    bool loaded = false;
    bool paused = false;

    //* BEGIN PUBLIC API.

    public void load(string levelDirectory) {
        if (loaded) {
            throw new Error("[Level]: Unload the level first.");
        }
        // todo: water level parse.
        Ground.load(levelDirectory);
        Water.load();
        Player.setDefaultPosition();

        loaded = true;
    }

    public void unload() {
        throw new Error("[Level]: unloading not implemented");
        loaded = false;
    }

    public void update() {
        if (paused) {
            return;
        }

        Ground.update();
        Water.update();
        FishTank.update();
        Player.update();
    }

    public void draw() {
        Ground.draw();
        FishTank.draw();
        Player.draw();
        Lure.draw();
        Water.draw();
    }

    public void togglePause() {
        paused = !paused;
    }

    //* BEGIN INTERNAL API.

}
