local player = require "library.player"
local spell_book_ui = require "library.spell_book_ui"
local spell_book = {}

function spell_book.onTouched(self, args)
    local rectangle = Soko:rectangle(0, 0, 0, 0)
    local worldPosition = Soko:toWorldPosition(self.gridPosition) + Soko:getHalfTileSize()

    rectangle.x = worldPosition.x
    rectangle.y = worldPosition.y

    rectangle = rectangle:inflated(Soko:worldPosition(160, 90))
    rectangle.y = rectangle.y - rectangle.height / 4 + Soko:toWorldPosition(Soko:gridPosition(0, -1)).y / 2
    World.camera:panToRectangle(rectangle)

    player.instance().facingDirection = Soko.DIRECTION.UP

    player.setUI(spell_book_ui.create(self))
    self.state["pose"] = "open"
end

return spell_book
