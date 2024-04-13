local player = require "library.player"
local exports = {}

function exports.onActivate(self, args)
    
    local entity = player.instance()
    entity.gridPosition = Soko:gridPosition(self.state["position_x"], self.state["position_y"])
    local room = World:getRoomAtGridPosition(entity.gridPosition)
    player.moveToRoom(room)
end

return exports
