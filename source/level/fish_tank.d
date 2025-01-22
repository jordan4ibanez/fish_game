module level.fish_tank;

import graphics.model_handler;
import level.fish_definitions;
import raylib;
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

    public void draw() {
        foreach (uuid, fish; database) {
            ModelHandler.draw(fish.model(), fish.position, Vector3(fish.rotation.x, fish.rotation.y, 0));
        }
    }

    //* BEGIN INTERNAL API.

}
