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

function score.execute()
    local room = World:getRoomAtGridPosition(player:instance().gridPosition)
    local entities = room:allEntities()

    score_events.setRoom(room)

    entities:sort(function(a, b)
        local yDiff = a.gridPosition.y - b.gridPosition.y
        if yDiff ~= 0 then
            return yDiff
        end

        return a.gridPosition.x - b.gridPosition.x
    end)

    for i, entity in ipairs(entities) do
        score.triggerEntity(entity)
    end
end

return score
