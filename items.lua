
["cannabis"] = {
    label = "Cannabis",
    weight = 30,
    stack = true,
},

["cannabis_fertilizer"] = {
    label = "Cannabis Dünger",
    weight = 150,
    stack = true,
    close = true,
    client = {
        export = 'f_cannabis.fertilize',
    },
},

["cannabis_seed"] = {
    label = "Cannabis Samen",
    weight = 15,
    stack = true,
    close = true,
    client = {
        export = 'f_cannabis.plant',
    },
},