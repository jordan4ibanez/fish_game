module utility.uuid;

static final const class UUID {
static:
public:

    ulong next() {
        return tickAndGive();
    }

private:

    ulong currentID = 1;

    ulong tickAndGive() {
        ulong current = currentID;
        currentID++;
        return current;
    }

}
