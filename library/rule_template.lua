local item_helpers = require "library.item_helpers"
local rule_template = {}

local function emptyFunction() end

local function createRule(description)
    local rule = {}
    rule.description = description
    rule.gridPositions = Soko:list()

    rule.execute = emptyFunction

    rule.onTrigger = function(ruleFuncion)
        rule.execute = ruleFuncion
        return rule
    end

    rule.addLocation = function(gridOffset)
        rule.gridPositions:add(gridOffset)
        return rule
    end

    rule.getConnectedItems = function(entity)
        local connectedItems = Soko:list()
        for i, position in ipairs(rule.gridPositions) do
            local item = item_helpers.getItemAt(entity.gridPosition + position)
            if item then
                connectedItems:add(item)
            end
        end
        return connectedItems
    end

    return rule
end

function rule_template.createPage(title)
    local page = {}
    page.title = title
    page.rules = Soko:list()
    page.addRule = function(description)
        local rule = createRule(description)
        page.rules:add(rule)
        return rule
    end
    return page
end

return rule_template
