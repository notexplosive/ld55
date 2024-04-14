local player = require "library.player"
local animation = require "library.animation"
local home_teleporter = {}


local function getItems()
    local items = Soko:list()
    for i, loadingDock in ipairs(World:allEntitiesInRoom()) do
        if loadingDock:templateName() == "loading_dock" then
            for xOffset = 0, loadingDock.state["zone_width"] - 1 do
                for yOffset = 0, loadingDock.state["zone_height"] - 1 do
                    local gridPosition = loadingDock.gridPosition + Soko:gridPosition(xOffset, yOffset)
                    for i, entity in ipairs(World:getEntitiesAt(gridPosition)) do
                        if entity:checkTrait("Pickable", "CanPickUp") then
                            items:add(entity)
                        end
                    end
                end
            end
        end
    end

    return items
end

function home_teleporter.onActivate(self, args)
    local items = getItems()
    animation.warpOut(player.instance(), items, function(itemTemplates)
        World:loadLevel("first_level", {
            starting_items = itemTemplates,
            target_score = 200 -- todo: this should come from the selected mission
        })
    end)
end

return home_teleporter
