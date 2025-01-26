module level.player;

import graphics.model_handler;
import level.ground;
import level.water;
import raylib;
import std.stdio;

static final const class Player {
static:
private:

    Vector3 position;

    //* BEGIN PUBLIC API.

    //!! NOTE:
    // Animation seems to be double the blender keyframes. So frame 30 is 60.

    public void setPosition(float x, float y, float z) {
        position = Vector3(x, y, z);
    }

    public void setDefaultPosition() {
        Vector2 groundSize = Ground.getSizeFloating();
        position.x = groundSize.x / 2.0;
        position.z = groundSize.y / 2.0;
        ModelHandler.playAnimation("person.glb", 0, 0);
    }

    public void updateFloating() {
        position.y = Water.getCollisionPoint(position.x, position.z);
        position.y -= 0.1;
    }

    public void draw() {
        ModelHandler.draw("boat.glb", position);

        Vector3 playerOnBoat = position;
        playerOnBoat.y += 0.6;
        ModelHandler.draw("person.glb", playerOnBoat);

    }

    //* BEGIN INTERNAL API.

}
