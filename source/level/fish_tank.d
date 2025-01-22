module level.fish_tank;

import graphics.model_handler;
import level.fish_definitions;
import level.ground;
import level.water;
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
            float groundYHeight = Ground.getCollisionPoint(fish.position.x, fish.position.z);
            DrawCircle3D(Vector3(fish.position.x, groundYHeight, fish.position.z), 1, Vector3(1, 0, 0), 0, Colors
                    .RED);
            DrawSphere(Vector3(fish.position.x, groundYHeight, fish.position.z), 0.1, Colors.RED);

            float waterYHeight = Water.getCollisionPoint(fish.position.x, fish.position.z);

            DrawCircle3D(Vector3(fish.position.x, waterYHeight, fish.position.z), 1, Vector3(1, 0, 0), 0, Colors
                    .GREEN);
            DrawSphere(Vector3(fish.position.x, waterYHeight, fish.position.z), 0.01, Colors.GREEN);

        }
    }

    //* BEGIN INTERNAL API.

}
