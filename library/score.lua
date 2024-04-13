local player = require "library.player"
local items  = require "library.items"
local score  = {}

function score.execute()
    local room = World:getRoomAtGridPosition(player:instance().gridPosition)

    for i, entity in ipairs(room:allEntities()) do
        local page = items[entity:templateName()]
        if page ~= nil then
            for _, rule in ipairs(page.rules) do
                rule.execute(entity, room)
            end
        end
    end
end

return score
