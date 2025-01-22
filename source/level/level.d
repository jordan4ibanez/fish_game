module level.level;

import level.ground;
import level.water;

static final const class Level {
static:
private:

    //* BEGIN PUBLIC API.

    public void load(string levelDirectory) {
        Ground.load(levelDirectory);
        Water.load();
    }

    //* BEGIN INTERNAL API.

}
