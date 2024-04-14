local player = require "library.player"
local exports = {}

local function warp(x, y)
    local entity = player.instance()
    entity.gridPosition = Soko:gridPosition(x, y)
    local room = World:getRoomAtGridPosition(entity.gridPosition)
    player.moveToRoom(room)
    World.camera:snapToRoom(room)
    player.move(Soko.DIRECTION.DOWN)
end

function exports.onActivate(self, args)
    warp(self.state["position_x"], self.state["position_y"])
end

function exports.onFailDrop(self, args)
    warp(self.state["position_x"], self.state["position_y"])
end

return exports
