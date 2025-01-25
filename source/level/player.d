module level.player;

import level.water;
import raylib;

static final const class Player {
static:
private:

    Vector3 position;

    //* BEGIN PUBLIC API.

    void setPosition(float x, float y, float z) {
        position = Vector3(x, y, z);
    }

    void updateFloating() {
        position.y = Water.getCollisionPoint(position.x, position.z);
    }

    //* BEGIN INTERNAL API.

}
