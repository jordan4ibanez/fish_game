module utility.math_stuff;

import std.random;

double giveRandomDouble(double min, double max) {
    auto rnd = Random(unpredictableSeed());
    return uniform(min, max, rnd);
}

int giveRandomInt(int min, int max) {
    auto rnd = Random(unpredictableSeed());
    return uniform(min, max, rnd);
}
