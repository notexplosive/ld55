local rule_template = {}

local function emptyFunction() end

local function createRule(description)
    local rule = {}
    rule.description = description
    rule.gridPositions = Soko:list()

    rule.execute = emptyFunction

    rule.setFunction = function(ruleFuncion)
        rule.execute = ruleFuncion
        return rule
    end

    rule.addLocation = function(gridOffset)
        rule.gridPositions:add(gridOffset)
        return rule
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
