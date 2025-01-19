module level.level;

import level.ground;

static final const class Level {
static:
private:

    //* BEGIN PUBLIC API.

    public void load(string levelDirectory) {
        Heightmap.load(levelDirectory);
    }

    //* BEGIN INTERNAL API.

}
