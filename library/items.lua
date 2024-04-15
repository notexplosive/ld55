local rule_template = require "library.rule_template"
local score_events  = require "library.score_events"
local items         = {}

local function requestTemplate(itemEntity)
    local item = items[itemEntity:templateName()]
    if item ~= nil then
        local template = item.requestTemplateOverride(item, itemEntity)
        if template ~= nil then
            print(item, "is impersonating", template)
            return template
        end
    end

    return itemEntity:templateName()
end

items.birthday_candle = rule_template.createPage("Birthday Candle", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.birthday_candle.addRule("+10 Aura if the Nexus is directly adjacent in a cardinal direction.")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(rule_template.getConnectedItems(rule.parentPage, entity)) do
            if requestTemplate(item) == "nexus" then
                score_events.addRegularScoreEvent(entity, 10)
            end
        end
    end)


----

items.skull_candle = rule_template.createPage("Skull Candle", 5)
    .addLocation(Soko:gridPosition(3, 0))
    .addLocation(Soko:gridPosition(-3, 0))
    .addLocation(Soko:gridPosition(0, -3))
    .addLocation(Soko:gridPosition(0, 3))

    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(-2, -2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, 2))
items.skull_candle.addRule("+5 Aura if Nexus is 3 squares away cardinally or 2 squares diagonally.")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(rule_template.getConnectedItems(rule.parentPage, entity)) do
            if requestTemplate(item) == "nexus" then
                score_events.addRegularScoreEvent(entity, 5)
            end
        end
    end)

items.skull_candle.addRule("-2 Aura for every object adjacent in a cardinal direction")
    .onTrigger(function(rule, entity)

    end)

----


items.incense = rule_template.createPage("Incense", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.incense.addRule("+1 Cross per adjacent item in a cardinal direction")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(rule_template.getConnectedItems(rule.parentPage, entity)) do
            if item ~= nil then
                score_events.addMultiplierScoreEvent(entity, 1)
            end
        end
    end)

----


items.crystal_bishop = rule_template.createPage("Crystal Bishop", 5)
    .addLocation(Soko:gridPosition(1, 1))
    .addLocation(Soko:gridPosition(-1, 1))
    .addLocation(Soko:gridPosition(1, -1))
    .addLocation(Soko:gridPosition(-1, -1))
    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(-2, 2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, -2))
    .addLocation(Soko:gridPosition(3, 3))
    .addLocation(Soko:gridPosition(-3, 3))
    .addLocation(Soko:gridPosition(3, -3))
    .addLocation(Soko:gridPosition(-3, -3))
items.crystal_bishop.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_king = rule_template.createPage("Crystal King", 5)
    .addLocation(Soko:gridPosition(1, 1))
    .addLocation(Soko:gridPosition(-1, 1))
    .addLocation(Soko:gridPosition(1, -1))
    .addLocation(Soko:gridPosition(-1, -1))
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.crystal_king.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_knight = rule_template.createPage("Crystal Knight", 5)
    .addLocation(Soko:gridPosition(-2, 1))
    .addLocation(Soko:gridPosition(-2, -1))
    .addLocation(Soko:gridPosition(2, 1))
    .addLocation(Soko:gridPosition(2, -1))
    .addLocation(Soko:gridPosition(1, 2))
    .addLocation(Soko:gridPosition(-1, 2))
    .addLocation(Soko:gridPosition(1, -2))
    .addLocation(Soko:gridPosition(-1, -2))
items.crystal_knight.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_pawn = rule_template.createPage("Crystal Pawn", 5)
    .addLocation(Soko:gridPosition(0, -1))
    .onRequestTemplate(function(page, entity)
        for _, item in ipairs(rule_template.getConnectedItems(page, entity)) do
            if requestTemplate(item) == "nexus" then
                return "nexus"
            end
        end
    end)
items.crystal_pawn.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_queen = rule_template.createPage("Crystal Queen", 5)
    .addLocation(Soko:gridPosition(1, 1))
    .addLocation(Soko:gridPosition(-1, 1))
    .addLocation(Soko:gridPosition(1, -1))
    .addLocation(Soko:gridPosition(-1, -1))
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(-2, 2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, -2))
    .addLocation(Soko:gridPosition(2, 0))
    .addLocation(Soko:gridPosition(-2, 0))
    .addLocation(Soko:gridPosition(0, -2))
    .addLocation(Soko:gridPosition(0, 2))
    .addLocation(Soko:gridPosition(3, 3))
    .addLocation(Soko:gridPosition(-3, 3))
    .addLocation(Soko:gridPosition(3, -3))
    .addLocation(Soko:gridPosition(-3, -3))
    .addLocation(Soko:gridPosition(3, 0))
    .addLocation(Soko:gridPosition(-3, 0))
    .addLocation(Soko:gridPosition(0, -3))
    .addLocation(Soko:gridPosition(0, 3))
items.crystal_queen.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_rook = rule_template.createPage("Crystal Rook", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
    .addLocation(Soko:gridPosition(2, 0))
    .addLocation(Soko:gridPosition(-2, 0))
    .addLocation(Soko:gridPosition(0, -2))
    .addLocation(Soko:gridPosition(0, 2))
    .addLocation(Soko:gridPosition(3, 0))
    .addLocation(Soko:gridPosition(-3, 0))
    .addLocation(Soko:gridPosition(0, -3))
    .addLocation(Soko:gridPosition(0, 3))
items.crystal_rook.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----

items.jar_greed = rule_template.createPage("Pot of Greed", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
    .addLocation(Soko:gridPosition(1, 1))
    .addLocation(Soko:gridPosition(1, -1))
    .addLocation(Soko:gridPosition(-1, 1))
    .addLocation(Soko:gridPosition(-1, -1))
items.jar_greed.addRule("Gain 2 gold per empty connection.")
    .onTrigger(function(rule, entity)
        for _, slot in ipairs(rule_template.getConnectedSlots(rule.parentPage, entity)) do
            if slot.item == nil then
                score_events.addGoldEvent(entity, 1)
            end
        end
    end)

----


items.candle = rule_template.createPage("Candle", 0)
items.candle.addRule("Gain 1 Cross if adjacent to the Nexus.")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(rule_template.getAdjacentItems(entity)) do
            if requestTemplate(item) == "nexus" then
                score_events.addMultiplierScoreEvent(entity, 1)
                break
            end
        end
    end)


return items
