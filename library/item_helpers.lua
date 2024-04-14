local score_events = require "library.score_events"
local item_helpers = {}


function item_helpers.getItemAt(gridPosition)
    local room = score_events.currentRoom()
    for i, entity in ipairs(room:allEntities()) do
        if entity.gridPosition == gridPosition then
            if entity:checkTrait("Surface", "Item") then
                return entity
            end
        end
    end
    return nil
end

return item_helpers
