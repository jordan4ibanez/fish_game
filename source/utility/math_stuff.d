module utility.math_stuff;

import std.random;

double giveRandom(double min, double max) {
    auto rnd = Random(unpredictableSeed());
    return uniform(min, max, rnd);
}
