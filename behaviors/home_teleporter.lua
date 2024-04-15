local player = require "library.player"
local animation = require "library.animation"
local run_context = require "library.run_context"
local home_teleporter = {}

local levels = Soko:list()
levels:add("level_cowboy")
levels:add("wyatt_sandbox") -- temp! remove this when we have more levels

function home_teleporter.onActivate(self, args)
    local items = run_context.calculateLoadingDockItems()
    animation.warpOut(player.instance(), items, function()
        World:loadLevel(levels[run_context.getProgress()], {})
        run_context.setProgress(run_context.getProgress() + 1)

        if run_context.getProgress() > #levels then
            run_context.setProgress(1)
        end
    end)

    for i, entity in ipairs(World:allEntities()) do
        if entity.state["special"] == "storage" then
            run_context.saveStorage(entity.gridPosition)
        end
    end

    run_context.saveLoadingDock(self.gridPosition)
end

return home_teleporter
