local rule_template = require "library.rule_template"
local score_events  = require "library.score_events"
local items         = {}


items.birthday_candle = rule_template.createPage("Birthday Candle")
items.birthday_candle.addRule("+10 Aura if the Nexus is directly adjacent in a cardinal direction.")
    .onTrigger(function(self, entity)
        for _, item in ipairs(self.getConnectedItems(entity)) do
            if item:templateName() == "nexus" then
                score_events.addRegularScoreEvent(entity, 10)
            end
        end
    end)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))

----

items.skull_candle = rule_template.createPage("Skull Candle")
items.skull_candle.addRule("+5 Aura if Nexus is 3 squares away cardinally or 2 squares diagonally.")
    .onTrigger(function(self, entity)
        for _, item in ipairs(self.getConnectedItems(entity)) do
            if item:templateName() == "nexus" then
                score_events.addRegularScoreEvent(entity, 5)
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
    .onTrigger(function(self, entity)

    end)

----


items.incense = rule_template.createPage("Incense")
items.incense.addRule("+1 Cross per adjacent item in a cardinal direction")
    .onTrigger(function(self, entity)
        for _, item in ipairs(self.getConnectedItems(entity)) do
            if item ~= nil then
                score_events.addMultiplierScoreEvent(entity, 1)
            end
        end
    end)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))

return items
