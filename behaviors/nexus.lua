local player = require "library.player"
local nexus = {}

function nexus.onActivate(self, args)
    player.instance()
end

return nexus
