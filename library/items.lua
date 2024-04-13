local rule_template = require "library.rule_template"
local score_events  = require "library.score_events"
local items         = {}

local function getItemAt(room, gridPosition)
    for i, entity in ipairs(room:allEntities()) do
        if entity.gridPosition == gridPosition then
            if entity:checkTrait("Surface", "Item") then
                return entity
            end
        end
    end
end

items.birthday_candle = rule_template.createPage("Birthday Candle")
items.birthday_candle.addRule("+10 Aura if the Nexus is directly adjacent in a cardinal direction.")
    .setFunction(function(entity, room)
        local items = Soko:list()
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(1, 0)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(-1, 0)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(0, -1)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(0, 1)))

        for _, item in ipairs(items) do
            if item:templateName() == "nexus" then
                score_events.addEvent(entity, 10)
            end
        end
    end)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))

items.skull_candle = rule_template.createPage("Ritual Candle")
items.skull_candle.addRule("+5 Aura if Nexus is 3 squares away cardinally or 2 squares diagonally.")
    .setFunction(function(entity, room)
        local items = Soko:list()
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(3, 0)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(-3, 0)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(0, -3)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(0, 3)))

        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(2, 2)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(-2, -2)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(-2, 2)))
        items:add(getItemAt(room, entity.gridPosition + Soko:gridPosition(2, -2)))

        for _, item in ipairs(items) do
            if item:templateName() == "nexus" then
                score_events.addEvent(entity, 5)
            end
        end
    end)
    .addLocation(Soko:gridPosition(3, 0))
    .addLocation(Soko:gridPosition(-3, 0))
    .addLocation(Soko:gridPosition(0, -3))
    .addLocation(Soko:gridPosition(0, 3))

    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(-2, -2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, 2))

items.skull_candle.addRule("-2 Aura for every object adjacent in a cardinal direction")
    .setFunction(function(entity, room)

    end)

return items
