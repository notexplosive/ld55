local rules = {}

local function emptyFunction() end

local function createRule(description)
    local rule = {}
    rule.description = description
    rule.gridPositions = Soko:list()

    rule.executeFunction = emptyFunction

    rule.setFunction = function(ruleFuncion)
        rule.executeFunction = ruleFuncion
        return rule
    end

    rule.addLocation = function(gridOffset)
        rule.gridPositions:add(gridOffset)
        return rule
    end
    return rule
end

function rules.createPage(title)
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

return rules
