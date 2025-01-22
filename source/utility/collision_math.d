module utility.collision_math;

import raylib.raylib_types;

// Begin stackoverflow.
// https://stackoverflow.com/a/2049593
float sign(Vector2 p1, Vector2 p2, Vector2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

// https://stackoverflow.com/a/2049593
bool pointInTriangle(Vector2 point, Vector2 v1, Vector2 v2, Vector2 v3) {
    float d1 = sign(point, v1, v2);
    float d2 = sign(point, v2, v3);
    float d3 = sign(point, v3, v1);

    bool has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    bool has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(has_neg && has_pos);
}

// https://stackoverflow.com/a/5507832
float calculateY(Vector3 point1, Vector3 point2, Vector3 point3, Vector2 position) {
    float det = (point2.z - point3.z) * (point1.x - point3.x) + (
        point3.x - point2.x) * (point1.z - point3.z);

    float l1 = ((point2.z - point3.z) * (position.x - point3.x) + (
            point3.x - point2.x) * (position.y - point3.z)) / det;
    float l2 = ((point3.z - point1.z) * (position.x - point3.x) + (
            point1.x - point3.x) * (position.y - point3.z)) / det;
    float l3 = 1.0f - l1 - l2;

    return l1 * point1.y + l2 * point2.y + l3 * point3.y;
}
// End stackoverflow.
