local player       = require "library.player"
local draw_text    = require "library.draw_text"
local animation    = require "library.animation"
local missions     = require "library.missions"
local mission_post = {}

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

        if player.currentUI() == nil then
            local rectangle = World:getRoomAtGridPosition(self.gridPosition):viewBounds()
            World.camera:panToRectangle(rectangle)
        end
        self.state["pose"] = "idle"
    end

    object.state["renderer"] = "lua"
    object.state["render_function"] = function(painter, drawArguments)
        local content = self.state["mission_content"]
        draw_text.drawTitle(painter, drawArguments, content.title)

        local lines = Soko:list()

        painter:setColor("white")
        lines:add("Generate " .. content.scoreObjective .. " Summoning Power")

        lines.add({
            text = "Awards " .. content.rankReward .. " rank",
            color = "green"
        })

        lines.add({
            text = "Awards " .. content.goldReward .. "G",
            color = "gold"
        })

        draw_text.drawLines(painter, drawArguments, lines)
    end

    return {
        animatedObject = object,
        onInput = function(input)
            if input.direction ~= Soko.DIRECTION.NONE then
                if player.move(input.direction) then
                    restore()
                end
            end

            if input.isPrimary then
                missions.setCurrent(self.state["mission_content"])
                World:raiseEntityEvent("choseMission", {})
                restore()
            end
        end
    }
end

function mission_post.choseMission(self, args)
    World:playAsyncAnimation(function(tween, params)
        local object = World:spawnObject(self.gridPosition)
        object.tweenablePosition:set(object.tweenablePosition:get() + self:displacementTweenable():get())
        object.state:addOtherState(self.state)

        for i = 1, 9 do
            tween:wait(0.1)
            tween:callback(function()
                object.state["frame"] = object.state["frame"] + 1
            end)
        end

        tween:callback(function()
            object:destroy()
        end)

        self:destroy()
    end, {})
end

function mission_post.onEnter(self, args)
    self:displacementTweenable():set(Soko:worldPosition(0, -25))
end

function mission_post.playerSteppedOn(self, args)
    if not missions.hasCurrentContent() then
        player.setUI(createUI(self))
    end
end

return mission_post
