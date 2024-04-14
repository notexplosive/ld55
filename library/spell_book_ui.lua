local player        = require "library.player"
local draw_text     = require "library.draw_text"
local items         = require "library.items"
local spell_book_ui = {}

function spell_book_ui.create(self)
    local rectangle = Soko:rectangle(0, 0, 0, 0)
    local worldPosition = Soko:toWorldPosition(self.gridPosition) + Soko:getHalfTileSize()
    rectangle.x = worldPosition.x
    rectangle.y = worldPosition.y

    rectangle = rectangle:inflated(Soko:worldPosition(160, 90))
    rectangle.y = rectangle.y - rectangle.height / 4 + Soko:toWorldPosition(Soko:gridPosition(0, -1)).y / 2
    World.camera:panToRectangle(rectangle)

    player.instance().facingDirection = Soko.DIRECTION.UP

    local object = World:spawnObject(self.gridPosition + Soko:gridPosition(0, -4))
    object.tweenablePosition:set(object.tweenablePosition:get() + Soko:toWorldPosition(Soko:gridPosition(0, 1)) / 2)

    local function restore()
        object:destroy()
        local rectangle = World:getRoomAtGridPosition(self.gridPosition):viewBounds()
        World.camera:panToRectangle(rectangle)
        self.state["pose"] = "idle"
    end

    object.state["renderer"] = "lua"
    object.state["render_function"] = function(painter, drawArguments)
        painter:setColor("white")
        if player.hasHeldItem() then
            local heldItemName = player.heldItemName()

            local rulePage = items[heldItemName]
            if rulePage == nil then
                return
            end

            draw_text.drawTitle(painter, drawArguments, rulePage.title)

            local lines = Soko:list()

            for i, rule in ipairs(rulePage.rules) do
                lines:add(rule.description)
            end

            draw_text.drawLines(painter, drawArguments, lines)
        else
            draw_text.drawTitle(painter, drawArguments, "Glossary")
            local lines = Soko:list()

            lines:add("ADJACENT objects are touching in a cardinal direction (not diagonal).")
            lines:add(
                "White reticles when holding an object indicate where the item will be CONNECTED to.")
            lines:add("When you initiate a SUMMON,\nall items in the room are TRIGGERED.")
            lines:add("SUMMONING POWER = AURA x CROSS.")
            draw_text.drawLines(painter, drawArguments, lines)
        end
    end

    return {
        animatedObject = object,
        onInput = function(input)
            if input.direction ~= player.instance().facingDirection then
                restore()
            end

            if input.isPrimary then
                restore()
            end
        end
    }
end

return spell_book_ui
