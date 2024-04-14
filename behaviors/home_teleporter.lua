local player = require "library.player"
local animation = require "library.animation"
local run_context = require "library.run_context"
local home_teleporter = {}

function home_teleporter.onActivate(self, args)
    local items = run_context.calculateLoadingDockItems()
    animation.warpOut(player.instance(), items, function()
        World:loadLevel("first_level", {
            target_score = 200 -- todo: this should come from the selected mission
        })
    end)
    run_context.saveLoadingDock()
end

return home_teleporter
