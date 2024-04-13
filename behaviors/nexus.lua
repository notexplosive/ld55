local player = require "library.player"
local summon_ui = require "library.summon_ui"
local nexus = {}

function nexus.onActivate(self, args)
    local rectangle = Soko:rectangle(0, 0, 0, 0)

    local worldPosition = Soko:toWorldPosition(self.gridPosition) + Soko:getHalfTileSize()

    rectangle.x = worldPosition.x
    rectangle.y = worldPosition.y

    rectangle = rectangle:inflated(Soko:worldPosition(160, 90))
    rectangle.y = rectangle.y - rectangle.height / 3
    World.camera:panToRectangle(rectangle)

    player.instance().facingDirection = Soko.DIRECTION.UP

    player.setUI(summon_ui.create())
end

return nexus
