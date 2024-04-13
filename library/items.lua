local rules = require "library.rules"
local items = {}

items.candle = rules.createPage("Candle")
items.candle.addRule("+10 Aura if the Nexus is 3 squares away in a cardinal direction")
    .setFunction(function(entity)

    end)
    .addLocation(Soko:gridPosition(3, 0))
    .addLocation(Soko:gridPosition(-3, 0))
    .addLocation(Soko:gridPosition(0, -3))
    .addLocation(Soko:gridPosition(0, 3))

items.candle.addRule("-2 Aura for every object adjacent in a cardinal direction")
    .setFunction(function(entity)

    end)

items.incense = rules.createPage("Incense")
items.incense.addRule("+2 Cross for every adjacent object in a cardinal direction")
    .setFunction(function(entity)

    end)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))



return items
