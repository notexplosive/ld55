local item_helpers = require "library.item_helpers"
local rule_template = {}

local function emptyFunction() end

local function createRule(description, parentPage)
    local rule = {}
    rule.description = description
    rule.parentPage = parentPage

    rule.executeTrigger = emptyFunction

    rule.onTrigger = function(ruleFuncion)
        rule.executeTrigger = ruleFuncion
        return rule
    end

    return rule
end

function rule_template.getConnectedItems(page, entity)
    local connectedItems = Soko:list()
    for i, position in ipairs(page.gridPositions) do
        local item = item_helpers.getItemAt(entity.gridPosition + position)
        if item then
            connectedItems:add(item)
        end
    end

    return connectedItems
end

function rule_template.getConnectedSlots(page, entity)
    local connectedItems = Soko:list()
    for i, position in ipairs(page.gridPositions) do
        local slot = {}
        slot.item = item_helpers.getItemAt(entity.gridPosition + position)

        connectedItems:add(slot)
    end

    return connectedItems
end

function rule_template.getAdjacentSlots(entity)
    local positions = Soko:list()
    positions:add(Soko:gridPosition(0, -1))
    positions:add(Soko:gridPosition(-1, 0))
    positions:add(Soko:gridPosition(1, 0))
    positions:add(Soko:gridPosition(0, 1))

    local adjacentItems = Soko:list()
    for i, position in ipairs(positions) do
        local slot = {}
        -- might be nil, that's OK
        slot.item = item_helpers.getItemAt(entity.gridPosition + position)
        adjacentItems:add(slot)
    end

    return adjacentItems
end

function rule_template.getAdjacentItems(entity)
    local positions = Soko:list()
    positions:add(Soko:gridPosition(0, -1))
    positions:add(Soko:gridPosition(-1, 0))
    positions:add(Soko:gridPosition(1, 0))
    positions:add(Soko:gridPosition(0, 1))

    local adjacentItems = Soko:list()
    for i, position in ipairs(positions) do
        local item = item_helpers.getItemAt(entity.gridPosition + position)
        if item ~= nil then
            adjacentItems:add(item)
        end
    end

    return adjacentItems
end

function rule_template.createPage(title, cost)
    local page = {}
    page.title = title
    page.rules = Soko:list()
    page.costValue = cost
    page.gridPositions = Soko:list()
    page.requestTemplateOverride = emptyFunction
    page.executeDeathTrigger = emptyFunction
    page.notifyOfTrigger = emptyFunction

    page.onRequestTemplate = function(overrideFunc)
        page.requestTemplateOverride = overrideFunc
        return page
    end

    page.onDestroyed = function(overrideFunc)
        page.executeDeathTrigger = overrideFunc
        return page
    end

    page.onOtherTrigger = function(overrideFunc)
        page.notifyOfTrigger = overrideFunc
        return page
    end

    page.addRule = function(description)
        local rule = createRule(description, page)
        page.rules:add(rule)
        return rule
    end

    page.addLocation = function(gridOffset)
        page.gridPositions:add(gridOffset)
        return page
    end

    page.cost = function()
        return page.costValue
    end
    page.getTitle = function()
        return page.title
    end
    return page
end

return rule_template
