local item_helpers = require "library.item_helpers"
local rule_template = {}

local function emptyFunction() end

local function createRule(description)
    local rule = {}
    rule.description = description
    rule.gridPositions = Soko:list()

    rule.executeTrigger = emptyFunction

    rule.onTrigger = function(ruleFuncion)
        rule.executeTrigger = ruleFuncion
        return rule
    end

    rule.addLocation = function(gridOffset)
        rule.gridPositions:add(gridOffset)
        return rule
    end

    return rule
end

function rule_template.getConnectedItems(rule, entity)
    local connectedItems = Soko:list()
    for i, position in ipairs(rule.gridPositions) do
        local item = item_helpers.getItemAt(entity.gridPosition + position)
        if item then
            connectedItems:add(item)
        end
    end

    return connectedItems
end

function rule_template.getConnectedSlots(rule, entity)
    local connectedItems = Soko:list()
    for i, position in ipairs(rule.gridPositions) do
        local slot = {}
        local item = item_helpers.getItemAt(entity.gridPosition + position)
        if item then
            slot.item = item
        end

        connectedItems:add(slot)
    end

    return connectedItems
end

function rule_template.createPage(title, cost)
    local page = {}
    page.title = title
    page.rules = Soko:list()
    page.costValue = 5
    page.addRule = function(description)
        local rule = createRule(description)
        page.rules:add(rule)
        return rule
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
