module level.fish_tank;

import level.fish_definitions;
import std.stdio;

static final const class FishTank {
static:
private:

    //? This stores all the fish in the level.
    // <>< <>< <>< <><

    Fish[ulong] database;

    //* BEGIN PUBLIC API.

    public void update() {
        if (database.length == 0) {
            LargeMouthBass newBass = new LargeMouthBass();
            database[newBass.uuid] = newBass;
            writeln("spawned new largemouth");

        }

        foreach (uuid, fish; database) {
            fish.update();
        }
    }

    //* BEGIN INTERNAL API.

}
