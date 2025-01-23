module utility.delta;

import core.time;

static final const class Delta {
static:
private:
    // Start with delta of a HUGE amount, limited by maxDelta
    MonoTime before = MonoTime.zero;
    MonoTime after = MonoTime.zero;

    double delta = 0;

    double maxDelta = 1.0 / 5.0;

    //* BEGIN PUBLIC API.

    public void __calculateDelta() {
        after = MonoTime.currTime;
        Duration duration = after - before;
        delta = cast(double) duration.total!("nsecs") / 1_000_000_000.0;

        // A delta limiter
        if (delta > maxDelta) {
            delta = maxDelta;
        }

        before = MonoTime.currTime;
    }

    public double getDelta() {
        return delta;
    }

    public void setMaxDelta(double newDeltaMax) {
        maxDelta = newDeltaMax;
    }

    public void setMaxDeltaFPS(double FPS) {
        maxDelta = 1.0 / FPS;
    }

    //* BEGIN INTERNAL API.

}
