local items        = require "library.items"
local score_events = require "library.score_events"
local score        = {}

function score.requestImpersonation(entity)
    local page = items[entity:templateName()]
    if page ~= nil then
        local override = page.requestTemplateOverride(page, entity)
        if override ~= nil then
            entity:destroy()
            return World:spawnEntity(entity.gridPosition, entity.facingDirection, override)
        end
    end
    return nil
end

function score.calculateEntities()
    local entities = score_events.currentRoom():allEntities()

    entities:sort(function(a, b)
        local yDiff = a.gridPosition.y - b.gridPosition.y
        if yDiff ~= 0 then
            return yDiff
        end

        return a.gridPosition.x - b.gridPosition.x
    end)

    local result = Soko:list()

    for i, entity in ipairs(entities) do
        local template = entity:templateName()
        if GET_ITEM_RULE_PAGE(template) ~= nil then
            result:add(entity)
        end
    end

    return result
end

function score.execute(gridPosition)
    local room = World:getRoomAtGridPosition(gridPosition)
    score_events.setRoom(room)

    local entities = score.calculateEntities()

    -- impersonation phase
    local shouldLoop = true
    while shouldLoop do
        shouldLoop = false
        for i = 1, #entities do
            local entity = entities[i]
            local impersonation = score.requestImpersonation(entity)
            if impersonation ~= nil then
                entities = score.calculateEntities()
                shouldLoop = true
                break
            end
        end
    end
end

return score
