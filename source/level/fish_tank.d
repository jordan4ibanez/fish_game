module level.fish_tank;

import graphics.model_handler;
import level.fish_definitions;
import level.ground;
import level.water;
import raylib;
import std.stdio;
import utility.delta;

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

        double delta = Delta.getDelta();

        foreach (uuid, fish; database) {
            fish.update(delta);
        }
    }

    public void draw() {
        foreach (uuid, fish; database) {

            ModelHandler.draw(fish.model(), fish.position, fish.rotation);

            float groundYHeight = Ground.getCollisionPoint(fish.position.x, fish.position.z);
            DrawCircle3D(Vector3(fish.position.x, groundYHeight, fish.position.z), 1, Vector3(1, 0, 0), 0, Colors
                    .RED);
            DrawSphere(Vector3(fish.position.x, groundYHeight, fish.position.z), 0.1, Colors.RED);

            float waterYHeight = Water.getCollisionPoint(fish.position.x, fish.position.z);

            DrawCircle3D(Vector3(fish.position.x, waterYHeight, fish.position.z), 1, Vector3(1, 0, 0), 0, Colors
                    .GREEN);
            DrawSphere(Vector3(fish.position.x, waterYHeight, fish.position.z), 0.01, Colors.GREEN);

            // Collision point upper.
            DrawSphere(Vector3Add(fish.position, Vector3(fish.position.x, fish.collisionVertical, fish
                    .position.z)), 0.01, Colors.BLUE);
            // Collision point lower.
            DrawSphere(Vector3Subtract(fish.position, Vector3(fish.position.x, fish.collisionVertical, fish
                    .position.z)), 0.01, Colors.GREEN);

            DrawCube(fish.lookTarget, 1, 1, 1, Colors.ORANGE);

        }
    }

    //* BEGIN INTERNAL API.

}
