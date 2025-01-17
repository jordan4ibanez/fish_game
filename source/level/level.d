module level.level;

import world.heightmap;

static final const class Level {
static:
private:

    //* BEGIN PUBLIC API.

    public void load(string levelDirectory) {
        Heightmap.load(levelDirectory);
    }

    //* BEGIN INTERNAL API.

}
