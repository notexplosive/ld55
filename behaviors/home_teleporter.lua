local player = require "library.player"
local home_teleporter = {}

local function flyUp(tween, entity)
    tween:interpolate(entity:displacementTweenable():to(Soko:worldPosition(0, -500)), 0.5,
        "cubic_slow_fast")
    tween:callback(function()
        entity:setVisible(false)
    end)
end

function home_teleporter.onActivate(self, args)
    World:playAnimation(function(tween, params)
        tween:startMultiplex()

        tween:startSequence()
        for i = 1, 30 do
            tween:callback(function()
                player.instance().facingDirection = player.instance().facingDirection:next()
            end)
            tween:wait(0.05)
        end
        tween:endSequence()

        tween:startSequence()
        tween:wait(1)

        flyUp(tween, player.instance())

        tween:endSequence()

        local delay = 0
        for i, loadingDock in ipairs(World:allEntitiesInRoom()) do
            if loadingDock:templateName() == "loading_dock" then
                for xOffset = 0, loadingDock.state["zone_width"] - 1 do
                    for yOffset = 0, loadingDock.state["zone_height"] - 1 do
                        local gridPosition = loadingDock.gridPosition + Soko:gridPosition(xOffset, yOffset)
                        for i, entity in ipairs(World:getEntitiesAt(gridPosition)) do
                            if entity:checkTrait("Pickable", "CanPickUp") then
                                tween:startSequence()
                                tween:wait(delay * 0.1)
                                delay = delay + 1
                                flyUp(tween, entity)
                                tween:endSequence()
                            end
                        end
                    end
                end
            end
        end

        tween:endMultiplex()



        tween:callback(function()
            World:loadLevel("first_level")
        end)
    end)
end

return home_teleporter
