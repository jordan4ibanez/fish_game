module utility.uuid;

static final const class UUID {
static:
private:

    //? Don't use this for network security lol.

    ulong currentID;

    //* BEGIN PUBLIC API.

    public ulong next() {
        return tickAndGive();
    }

    //* BEGIN INTERNAL API.

    ulong tickAndGive() {
        ulong current = currentID;
        currentID++;
        return current;
    }

}
