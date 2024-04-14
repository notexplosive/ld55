local player        = require "library.player"
local draw_text     = require "library.draw_text"
local items         = require "library.items"
local spell_book_ui = {}

local function drawTitle(painter, drawArguments, title)
    local titleFontSize = 16
    painter:setFontSize(titleFontSize)
    draw_text.draw(painter, drawArguments, title, Soko:worldPosition(0, -titleFontSize))
end

local function drawLines(painter, drawArguments, lines)
    local fontSize = 8
    painter:setFontSize(fontSize)
    local yPosition = 0
    local restrictedWidth = 180

    for i, line in ipairs(lines) do
        local bounds = painter:measureText(line, restrictedWidth)
        local offset = bounds:size()
        offset.x = 0
        draw_text.draw(painter, drawArguments, line,
            Soko:worldPosition(0, yPosition) + offset / 2, 0, restrictedWidth)

        yPosition = yPosition + bounds:bottomRight().y + 5
    end
end

function spell_book_ui.create(self)
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

            drawTitle(painter, drawArguments, rulePage.title)

            local lines = Soko:list()

            for i, rule in ipairs(rulePage.rules) do
                lines:add(rule.description)
            end

            drawLines(painter, drawArguments, lines)
        else
            drawTitle(painter, drawArguments, "Glossary")
            local lines = Soko:list()

            lines:add("ADJACENT objects are touching in a cardinal direction (not diagonal).")
            lines:add(
                "White reticles when holding an object indicate where the item will be CONNECTED to.")
            lines:add("When you initiate a SUMMON,\nall items in the room are TRIGGERED.")
            lines:add("SUMMONING POWER = AURA x CROSS.")
            drawLines(painter, drawArguments, lines)
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
