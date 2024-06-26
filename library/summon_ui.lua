local player    = require "library.player"
local draw_text = require "library.draw_text"
local score     = require "library.score"
local animation = require "library.animation"
local summon_ui = {}

function summon_ui.create()
    local object = World:spawnObject(player.instance().gridPosition)

    local selectedOption = 1
    local timestamp = nil

    local function selectOption(i)
        if selectedOption ~= i then
            selectedOption = i
            timestamp = nil
        end
    end

    local function restore()
        object:destroy()
        local rectangle = World:getRoomAtGridPosition(player.instance().gridPosition):viewBounds()
        World.camera:panToRectangle(rectangle)
    end

    local options = {}
    options[1] = {}
    options[1].text = "Cancel"
    options[1].offset = Soko:worldPosition(-100, -20)
    options[1].execute = function()
        restore()
    end

    options[2] = {}
    options[2].text = "Begin"
    options[2].offset = Soko:worldPosition(100, -20)
    options[2].execute = function()
        restore()
        score.execute(player.instance().gridPosition)
    end

    object.state["renderer"] = "lua"
    local titleBounds = nil
    object.state["render_function"] = function(painter, drawArguments)
        if timestamp == nil then
            timestamp = drawArguments:elapsedTime()
        end

        local duration = 0.15
        local timeDelta = math.min(drawArguments:elapsedTime() - timestamp, duration) / duration
        local titleAngle = math.sin(drawArguments:elapsedTime() * 2) * 0.01

        painter:setFontSize(32)
        if titleBounds then
            painter:setColor("00000099")
            painter:drawFillRectangle(titleBounds:inflated(Soko:worldPosition(20, 20)))
        end
        painter:setColor("white")
        titleBounds = draw_text.draw(painter, drawArguments, "Begin Summoning?", Soko:worldPosition(0, -100), titleAngle)

        painter:setFontSize(15)
        for i in pairs(options) do
            local option = options[i]
            local angle = 0

            if i == selectedOption then
                angle = math.sin(drawArguments:elapsedTime() * 10) * 0.2

                if option.bounds then
                    painter:setColor("orange")
                    painter:drawFillRectangle(option.bounds:inflated(Soko:worldPosition(10, 10) * timeDelta))
                end

                painter:setColor("000000")
            else
                painter:setColor("white")
            end

            option.bounds = draw_text.draw(painter, drawArguments, option.text, option.offset, angle)
        end
    end

    return {
        animatedObject = object,
        onInput = function(input)
            if input.direction == Soko.DIRECTION.DOWN then
                restore()
            end

            if input.direction == Soko.DIRECTION.LEFT then
                selectOption(1)
            end

            if input.direction == Soko.DIRECTION.RIGHT then
                selectOption(2)
            end

            if input.isPrimary then
                if selectedOption == 1 then
                    restore()
                end

                if selectedOption == 2 then
                    options[selectedOption].execute()
                    animation.doScoringAnimation(player.instance())
                end
            end
        end
    }
end

return summon_ui
