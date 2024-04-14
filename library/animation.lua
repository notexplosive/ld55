local score_events   = require "library.score_events"
local draw_text      = require "library.draw_text"
local animation      = {}
local ABOVE_POSITION = -40


local flyMaxPosition = Soko:worldPosition(0, -500)

local function flyUp(tween, entity)
    tween:startSequence()
    tween:wait(1)
    tween:interpolate(entity:displacementTweenable():to(flyMaxPosition), 0.5,
        "cubic_slow_fast")
    tween:callback(function()
        entity:setVisible(false)
    end)
    tween:endSequence()
end


local function flyDown(tween, entity)
    tween:startSequence()
    tween:callback(function()
        entity:displacementTweenable():set(flyMaxPosition)
    end)
    tween:interpolate(entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 1, "cubic_fast_slow")
    tween:endSequence()
end

function animation.doScoringAnimation(player)
    World:playAnimation(function(tween)
        -- wait for camera (boooooo!!!!!)
        tween:wait(1)
        local showTotal = false

        -- these values aren't known until the first callback of the tween
        local auraCounter
        local multiplierCounter
        local goldCounter
        local center
        local isVictory

        tween:callback(function()
            center = World.camera:tweenableViewBounds():get():center()

            auraCounter = World:spawnObject(Soko:gridPosition(0, 0))
            auraCounter.tweenablePosition:set(center + Soko:worldPosition(-160, 0))
            auraCounter.state["layer"] = 4
            auraCounter.state["renderer"] = "lua"
            auraCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor("purple")
                painter:setFontSize(20)
                local text = "Aura"
                local number = tostring(score_events.currency().normal)
                if showTotal then
                    text = "Summoning Power"
                    number = tostring(score_events.totalScore())
                    painter:setColor("white")
                end

                draw_text.draw(painter, drawArguments, text, Soko:worldPosition(0, -80 / 2 - 10), 0)
                painter:setFontSize(80)
                draw_text.draw(painter, drawArguments, number, Soko:worldPosition(0, 0), 0)
            end

            multiplierCounter = World:spawnObject(Soko:gridPosition(0, 0))
            multiplierCounter.tweenablePosition:set(center + Soko:worldPosition(160, 0))
            multiplierCounter.state["layer"] = 4
            multiplierCounter.state["renderer"] = "lua"
            multiplierCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor("orange")
                draw_text.scoreCounter(painter, drawArguments, "Cross", score_events.currency().multiplier .. "X")
            end

            goldCounter = World:spawnObject(Soko:gridPosition(0, 0))
            goldCounter.tweenablePosition:set(center + Soko:worldPosition(0, 140))
            goldCounter.state["layer"] = 4
            goldCounter.state["renderer"] = "lua"
            goldCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor("gold")
                draw_text.scoreCounter(painter, drawArguments, "Gold", score_events.currency().gold)
            end
        end)

        tween:startMultiplex()

        for i = 1, #score_events:all() do
            local event = score_events:all()[i]
            if event.type == "gain_score" then
                tween:startSequence()

                tween:wait(0.2 * i)
                tween:dynamic(function(innerTween)
                    local textObject = World:spawnObject(event.gridPosition)
                    textObject.state["layer"] = 4
                    textObject.state["renderer"] = "lua"
                    textObject.state["render_function"] = function(painter, drawArguments)
                        painter:setFontSize(25)

                        if event.currencyType == "gold" then
                            painter:setColor("gold")
                        elseif event.currencyType == "multiplier" then
                            painter:setColor("orange")
                        else
                            painter:setColor("purple")
                        end

                        local text = tostring(event.amount)
                        local bounds = painter:measureText(text)
                        local offset = Soko:worldPosition(bounds.width, bounds.height) / 2
                        painter:drawText(text, drawArguments.worldPosition - offset)
                    end

                    innerTween:startMultiplex()

                    innerTween:startSequence()
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, -10)), 0.1,
                        "quadratic_fast_slow")
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1,
                        "quadratic_slow_fast")
                    innerTween:endSequence()

                    innerTween:startSequence()

                    innerTween:callback(event.commit)

                    innerTween:interpolate(
                        textObject.tweenablePosition:to(
                            textObject.tweenablePosition:get() + Soko:worldPosition(0, ABOVE_POSITION - 20)),
                        0.25,
                        "cubic_fast_slow"
                    )

                    innerTween:interpolate(
                        textObject.tweenablePosition:to(
                            textObject.tweenablePosition:get() + Soko:worldPosition(0, ABOVE_POSITION)),
                        0.15,
                        "cubic_slow_fast"
                    )
                    innerTween:endSequence()

                    innerTween:endMultiplex()

                    innerTween:wait(0.2)

                    innerTween:callback(function()
                        textObject:destroy()
                    end)
                end)
                tween:endSequence()
            end
        end
        tween:endMultiplex()

        tween:wait(0.5)


        tween:dynamic(function(innerTween)
            innerTween:startMultiplex()
            innerTween:interpolate(auraCounter.tweenablePosition:to(center), 0.5, "quadratic_slow_fast")
            innerTween:interpolate(multiplierCounter.tweenablePosition:to(center), 0.5, "quadratic_slow_fast")
            innerTween:endMultiplex()
        end)


        tween:callback(function()
            multiplierCounter:destroy()
            showTotal = true
        end)

        tween:wait(0.2)

        tween:dynamic(function(innerTween)
            innerTween:interpolate(auraCounter.tweenablePosition:to(center + Soko:worldPosition(0, -120)), 0.5,
                "quadratic_slow_fast")
        end)

        tween:startMultiplex()
        flyUp(tween, player)
        tween:startSequence()
        for i = 1, 32 do
            tween:callback(function()
                player.facingDirection = player.facingDirection:next()
            end)
            tween:wait(0.05)
        end
        tween:endSequence()
        tween:endMultiplex()

        tween:dynamic(function(innerTween)
            local targetScoreColor = "white"
            local targetScoreCounter = World:spawnObject(Soko:gridPosition(0, 0))
            targetScoreCounter.tweenablePosition:set(auraCounter.tweenablePosition:get())
            targetScoreCounter.state["layer"] = 4
            targetScoreCounter.state["renderer"] = "lua"
            targetScoreCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor(targetScoreColor)
                draw_text.scoreCounter(painter, drawArguments, "Target Score", World.levelState["target_score"])
            end

            innerTween:interpolate(targetScoreCounter.tweenablePosition:to(targetScoreCounter.tweenablePosition:get() +
                Soko:worldPosition(0, 100)), 0.5, "quadratic_fast_slow")

            innerTween:wait(0.5)

            isVictory = score_events.totalScore() >= World.levelState["target_score"]

            if isVictory then
                for i = 1, World.levelState["payment"] do
                    innerTween:callback(function()
                        score_events:currency()["gold"] = score_events:currency()["gold"] + 1
                    end)
                    innerTween:wait(0.1)
                end
            else
                innerTween:callback(function()
                    targetScoreColor = "red"
                end)
            end
        end)

        tween:wait(1)

        tween:callback(function()
            -- TODO: add earned gold into total wallet
            -- score_events:currency()["gold"]

            score_events:clearEvents()
            World:loadLevel("house", { is_victory = isVictory, should_warp = true })
        end)
    end)
end

function animation.toPose(entity, pose)
    entity.state["pose"] = pose

    if entity.state["is_carrying"] then
        entity.state["pose"] = pose .. "_carry"
    end
end

function animation.interpolateState(state, key, lerpFunction, value, duration)
    World:playAnimation(function(tween, params)
        local getter = function()
            return state[key]
        end

        local setter = function(x)
            state[key] = x
        end

        local tweenable = Soko:tweenable(getter, setter, lerpFunction)

        tween:interpolate(tweenable:to(value), duration, "linear")
    end)
end

function animation.interpolateMove(move)
    local function moveAnimation(tween, params)
        local move = params.move
        local movingEntity = move:movingEntity()
        tween:callback(function()
            animation.toPose(movingEntity, "walk")
        end)
        move:execute()

        if move:isAllowed() then
            local size = Soko:getHalfTileSize().x * 2
            movingEntity:displacementTweenable():set(move.direction:toWorldPosition() * -size)

            tween:interpolate(
                movingEntity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.15, "linear")
        end

        tween:callback(function()
            animation.toPose(movingEntity, "idle")
        end)
    end

    World:playAnimation(moveAnimation, { move = move })
    return move
end

function animation.displacementToZero(entity)
    World:playAnimation(function(tween, params)
        tween:interpolate(entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1, "quadratic_slow_fast")
    end)
end

local function doWarp(func, playerEntity, itemEntities, whenDone)
    World:playAnimation(function(tween, params)
        tween:startMultiplex()

        tween:startSequence()

        func(tween, playerEntity)

        tween:endSequence()

        tween:startSequence()
        for i = 1, 32 do
            tween:callback(function()
                playerEntity.facingDirection = playerEntity.facingDirection:next()
            end)
            tween:wait(0.05)
        end
        tween:callback(function()
            playerEntity.facingDirection = Soko.DIRECTION.DOWN
        end)
        tween:endSequence()

        for i, item in ipairs(itemEntities) do
            tween:startSequence()
            tween:wait(i * 0.1)
            func(tween, item)
            tween:endSequence()
        end

        tween:endMultiplex()

        if whenDone ~= nil then
            tween:callback(function()
                whenDone()
            end)
        end
    end)
end

function animation.warpOut(playerEntity, items, whenDone)
    doWarp(flyUp, playerEntity, items, whenDone)
end

function animation.warpIn(playerEntity, items, whenDone)
    for i, item in ipairs(items) do
        item:displacementTweenable():set(flyMaxPosition)
    end

    doWarp(flyDown, playerEntity, items, whenDone)
end

return animation
