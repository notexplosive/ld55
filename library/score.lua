local player       = require "library.player"
local items        = require "library.items"
local score_events = require "library.score_events"
local score        = {}

function score.triggerEntity(entity)
    if World:getTileAt(entity.gridPosition):templateName() == "carpet" then
        score_events.addDudEvent(entity)
        return
    end

    local page = items[entity:templateName()]
    if page ~= nil then
        for _, rule in ipairs(page.rules) do
            rule.executeTrigger(rule, entity)
        end
    end
end

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

local function calculateEntities(room)
    local entities = room:allEntities()

    entities:sort(function(a, b)
        local yDiff = a.gridPosition.y - b.gridPosition.y
        if yDiff ~= 0 then
            return yDiff
        end

        return a.gridPosition.x - b.gridPosition.x
    end)

    return entities
end

function score.execute()
    local room = World:getRoomAtGridPosition(player:instance().gridPosition)
    score_events.setRoom(room)

    local entities = calculateEntities(room)

    -- impersonation phase
    local shouldLoop = true
    while shouldLoop do
        shouldLoop = false
        for i = 1, #entities do
            local entity = entities[i]
            local impersonation = score.requestImpersonation(entity)
            if impersonation ~= nil then
                entities = calculateEntities(room)
                shouldLoop = true
                break
            end
        end
    end

    -- trigger phase
    for i, entity in ipairs(entities) do
        score.triggerEntity(entity)
    end
end

return score
