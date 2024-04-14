local player      = require "library.player"
local draw_text   = require "library.draw_text"
local items       = require "library.items"
local shop        = require "library.shop"
local run_context = require "library.run_context"
local animation   = require "library.animation"
local shop_item   = {}


local function createUI(self)
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
        local rulePage = items[self:templateName()]
        if rulePage == nil then
            return
        end

        draw_text.drawTitle(painter, drawArguments, rulePage.title)

        local lines = Soko:list()

        for i, rule in ipairs(rulePage.rules) do
            lines:add(rule.description)
        end

        painter:setColor("white")

        local color = "gold"

        local price = self.state["price"]
        if not run_context.canAfford(price) then
            color = "red"
        end

        lines.add({
            text = "Costs: " .. price .. "G" .. " (you have: " .. run_context.gold() .. "G)",
            color = color
        })

        draw_text.drawLines(painter, drawArguments, lines)
    end

    return {
        animatedObject = object,
        onInput = function(input)
            if input.direction ~= Soko.DIRECTION.NONE then
                local move = animation.interpolateMove(player.instance():generateDirectionalMove(input.direction))
                if move:isAllowed() then
                    restore()
                end
            end

            if input.isPrimary then
                if shop.attemptPurchase(self) then
                    player.pickUpItem(self)
                end
            end
        end
    }
end

function shop_item.playerSteppedOn(self, args)
    player.setUI(createUI(self))
end

return shop_item
