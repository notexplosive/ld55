local rule_template = require "library.rule_template"
local score_events  = require "library.score_events"
local items         = {}

function GET_ITEM_RULE_PAGE(templateName)
    return items[templateName]
end

local function onRequest_impersonateNexus(page, entity)
    for _, item in ipairs(rule_template.getConnectedItems(page, entity)) do
        if item:templateName() == "nexus" then
            return "nexus"
        end
    end
end

local function getConnections(rule, entity)
    return rule_template.getConnectedItems(rule.parentPage, entity)
end

local function isConnectedToNexus(rule, entity)
    for _, item in ipairs(getConnections(rule, entity)) do
        if item:templateName() == "nexus" then
            return true
        end
    end

    return false
end

----

items.birthday_candle = rule_template.createPage("Birthday Candle", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.birthday_candle.addRule("+25 Aura if connected to Nexus.")
    .onTrigger(function(rule, entity)
        if isConnectedToNexus(rule, entity) then
            score_events.addRegularScoreEvent(entity, 10)
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
items.skull_candle.addRule("+5 Aura if connected to Nexus.")
    .onTrigger(function(rule, entity)
        if isConnectedToNexus(rule, entity) then
            score_events.addRegularScoreEvent(entity, 5)
        end
    end)

items.skull_candle.addRule("-2 Aura for every object adjacent in a cardinal direction")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(rule_template.getAdjacentItems(entity)) do
            if item ~= nil then
                score_events.addRegularScoreEvent(entity, -2)
            end
        end
    end)

----


items.incense = rule_template.createPage("Incense", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.incense.addRule("+1 Cross per adjacent item in a cardinal direction")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(getConnections(rule, entity)) do
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
    .onRequestTemplate(onRequest_impersonateNexus)
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
    .onRequestTemplate(onRequest_impersonateNexus)
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
    .onRequestTemplate(onRequest_impersonateNexus)
items.crystal_knight.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_pawn = rule_template.createPage("Crystal Pawn", 5)
    .addLocation(Soko:gridPosition(0, -1))
    .onRequestTemplate(onRequest_impersonateNexus)
items.crystal_pawn.addRule("If connected to a Nexus, this counts as a Nexus")
    .onTrigger(function(rule, entity)
    end)

----


items.crystal_queen = rule_template.createPage("Crystal Queen", 50)
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
    .onRequestTemplate(onRequest_impersonateNexus)
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
    .onRequestTemplate(onRequest_impersonateNexus)
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
            if item:templateName() == "nexus" then
                score_events.addMultiplierScoreEvent(entity, 1)
                break
            end
        end
    end)

----

items.lighter = rule_template.createPage("Lighter", 5)
items.lighter.addRule("Triggers adjacent candles")
    .onTrigger(function(rule, entity)
        score_events.addBeginRiseEvent(entity)
        for _, item in ipairs(rule_template.getAdjacentItems(entity)) do
            if item ~= nil and item.state["is_candle"] then
                score_events.addKickerEvent(entity, "Again!")
                score_events.triggerEntity(item)
            end
        end
        score_events.addEndRiseEvent(entity)
    end)

----

items.jar_blue = rule_template.createPage("Pot of Wrath", 5)
items.jar_blue.addRule("Gain 2 Cross for every empty empty adjacent space.")
    .onTrigger(function(rule, entity)
        for _, slot in ipairs(rule_template.getAdjacentSlots(entity)) do
            if slot.item == nil then
                score_events.addMultiplierScoreEvent(entity, 2)
            end
        end
    end)

----

items.jar_red = rule_template.createPage("Pot of Envy", 5)
items.jar_red.addRule("Gain 10 Aura for every empty empty adjacent space.")
    .onTrigger(function(rule, entity)
        for _, slot in ipairs(rule_template.getAdjacentSlots(entity)) do
            if slot.item == nil then
                score_events.addRegularScoreEvent(entity, 10)
            end
        end
    end)

----

items.coal = rule_template.createPage("Charcoal", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
items.coal.addRule("Gain 1 Cross for every connected candle.")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(getConnections(rule, entity)) do
            if item ~= nil and item.state["is_candle"] then
                score_events.addMultiplierScoreEvent(entity, 1)
            end
        end
    end)

----

items.dagger = rule_template.createPage("Dagger", 5)
items.dagger.addRule("If there is an item to its right, destroy it and move right.")
    .onTrigger(function(rule, entity)
        score_events.addDestroyItemEvent(entity, entity.gridPosition + Soko:gridPosition(1, 0))
        score_events.addMoveItemEvent(entity, Soko.DIRECTION.RIGHT)
    end)

----

items.sheep = rule_template.createPage("Lamb", 5)
    .onDestroyed(function(entity, destroyer)
        score_events.addMultiplierScoreEvent(destroyer, 10)
    end)
items.sheep.addRule("Gain 10 Cross if destroyed.")

----

items.voodoo_doll = rule_template.createPage("Voodoo Doll", 5)
    .onDestroyed(function(entity, destroyer)
        score_events.addRegularScoreEvent(destroyer, 100)
    end)
items.voodoo_doll.addRule("Gain 100 Aura if destroyed.")

----

items.skull = rule_template.createPage("Skull", 5)
    .addLocation(Soko:gridPosition(2, 0))
    .addLocation(Soko:gridPosition(-2, 0))
    .addLocation(Soko:gridPosition(0, -2))
    .addLocation(Soko:gridPosition(0, 2))
    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, 2))
    .addLocation(Soko:gridPosition(-2, -2))
items.skull.addRule("Gain 5 Aura for each connected Skull or Skull Candle.")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(getConnections(rule, entity)) do
            if item ~= nil and item.state["is_skull"] then
                score_events.addRegularScoreEvent(entity, 5)
            end
        end
    end)

----

items.crown = rule_template.createPage("Crown of Succession", 5)
    .addLocation(Soko:gridPosition(0, 1))
items.crown.addRule("If connected item is destroyed gain 5 Gold.")
    .onTrigger(function(rule, entity)
        score_events.addBeginRiseEvent(entity)
        for _, item in ipairs(getConnections(rule, entity)) do
            score_events.addKickerEvent(item, "KING")
            score_events.whenDestroyed(item, function()
                score_events.addGoldEvent(entity, 5)
            end)
        end
        score_events.addEndRiseEvent(entity)
    end)

----

items.rose_gold = rule_template.createPage("Gilded Rose", 5)
    .onOtherTrigger(function(page, selfEntity, otherEntity)
        for _, adjacentEntity in ipairs(rule_template.getAdjacentItems(selfEntity)) do
            if adjacentEntity == otherEntity then
                score_events.addGoldEvent(selfEntity, 2)
            end
        end
    end)
items.rose_gold.addRule("Gain 2 Gold whenever an adjacent item triggers.")

----

items.rose_gold = rule_template.createPage("Red Rose", 5)
    .onOtherTrigger(function(page, selfEntity, otherEntity)
        for _, adjacentEntity in ipairs(rule_template.getAdjacentItems(selfEntity)) do
            if adjacentEntity == otherEntity then
                score_events.addRegularScoreEvent(selfEntity, 15)
            end
        end
    end)
items.rose_gold.addRule("Gain 15 Aura whenever an adjacent item triggers.")

---

items.rose_gold = rule_template.createPage("Blue Rose", 5)
    .onOtherTrigger(function(page, selfEntity, otherEntity)
        for _, adjacentEntity in ipairs(rule_template.getAdjacentItems(selfEntity)) do
            if adjacentEntity == otherEntity then
                score_events.addMultiplierScoreEvent(selfEntity, 2)
            end
        end
    end)
items.rose_gold.addRule("Gain 2 Cross whenever an adjacent item triggers.")

---

items.dynamite = rule_template.createPage("Dynamite", 5)
    .addLocation(Soko:gridPosition(1, 0))
    .addLocation(Soko:gridPosition(-1, 0))
    .addLocation(Soko:gridPosition(0, -1))
    .addLocation(Soko:gridPosition(0, 1))
    .addLocation(Soko:gridPosition(1, 1))
    .addLocation(Soko:gridPosition(1, -1))
    .addLocation(Soko:gridPosition(-1, 1))
    .addLocation(Soko:gridPosition(-1, -1))
    .addLocation(Soko:gridPosition(2, 0))
    .addLocation(Soko:gridPosition(-2, 0))
    .addLocation(Soko:gridPosition(0, -2))
    .addLocation(Soko:gridPosition(0, 2))
    .addLocation(Soko:gridPosition(2, 2))
    .addLocation(Soko:gridPosition(2, -2))
    .addLocation(Soko:gridPosition(-2, 2))
    .addLocation(Soko:gridPosition(-2, -2))
items.dynamite.addRule("Destroy all connected items and then itself")
    .onTrigger(function(rule, entity)
        for _, item in ipairs(getConnections(rule, entity)) do
            if item ~= nil then
                score_events.addDestroyItemEvent(item, item.gridPosition)
            end
        end

        score_events.addDestroyItemEvent(entity, entity.gridPosition)
    end)

----

items.book_m = rule_template.createPage("Plumbing for Dummies", 5)
    .onMove(function(entity, success)
        if success then
            score_events.addMultiplierScoreEvent(entity, 4)
        else
            score_events.addDudEvent(entity)
        end
    end)
items.book_m.addRule("Move one square to the right, if nothing blocks the move, gain 4 Cross.")
    .onTrigger(function(rule, entity)
        score_events.addMoveItemEvent(entity, Soko.DIRECTION.RIGHT)
    end)

---

items.teddy = rule_template.createPage("Teddy Bear", 5)
items.teddy.addRule("Triggers adjacent items")
    .onTrigger(function(rule, entity)
        score_events.addBeginRiseEvent(entity)
        for _, item in ipairs(rule_template.getAdjacentItems(entity)) do
            if item ~= nil then
                score_events.addKickerEvent(entity, "Again!")
                score_events.triggerEntity(item)
            end
        end
        score_events.addEndRiseEvent(entity)
    end)


---

items.mushroom = rule_template.createPage("Magecap", 5)
items.mushroom.addRule("Gain 20 Aura")
    .onTrigger(function(rule, entity)
        score_events.addRegularScoreEvent(entity, 20)
    end)

---

return items
