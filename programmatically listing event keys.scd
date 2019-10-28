(
~serverMsg = {
    |name|
    name.beginsWith("/")
    || name.beginsWith("b_")
    || name.beginsWith("n_")
    || name.beginsWith("g_")

};

"\n--- EVENT TYPES ---".postln;
Event.eventTypes.keysValuesDo {
    |name, value|
    "Event.eventTypes[%]".format("\\" ++ name.asString).postln;
    value.def.constants.do {
        |symbol|
        if (symbol.isKindOf(Symbol)) {
            if (symbol.asString.beginsWith("/").not) {
                "\t~%".format(symbol).postln;
            }
        }
    }
};

"\n--- PARENT EVENTS ---".postln;
Event.parentEvents.keysValuesDo {
    |subeventName, subevent|
    subevent.keysValuesDo {
        |name, func|
        if (func.isKindOf(Function)) {
            "Event.parentEvents[%][%]".format(
                "\\" ++ subeventName,
                "\\" ++ name
            ).postln;
            func.def.constants.do {
                |symbol|
                if (symbol.isKindOf(Symbol)) {
                    if (~serverMsg.value(symbol.asString).not) {
                        "\t~%".format(symbol).postln;
                    }
                }
            }
        }
    }
}
)