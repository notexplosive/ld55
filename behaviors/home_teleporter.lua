local player = require "library.player"
local animation = require "library.animation"
local run_context = require "library.run_context"
local home_teleporter = {}

function home_teleporter.onActivate(self, args)
    local items = run_context.calculateLoadingDockItems()
    animation.warpOut(player.instance(), items, function()
        World:loadLevel("wyatt_sandbox", {})
    end)

    for i, entity in ipairs(World:allEntities()) do
        if entity.state["special"] == "storage" then
            run_context.saveStorage(entity.gridPosition)
        end
    end

    run_context.saveLoadingDock(self.gridPosition)
end

return home_teleporter
