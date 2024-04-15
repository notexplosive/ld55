local score_events   = require "library.score_events"
local draw_text      = require "library.draw_text"
local run_context    = require "library.run_context"
local missions       = require "library.missions"
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

local function spawnKicker(gridPosition, tween, text, color)
    tween:dynamic(function(innerTween)
        local textObject = World:spawnObject(gridPosition)
        textObject.state["layer"] = 5
        textObject.state["renderer"] = "lua"
        textObject.state["render_function"] = function(painter, drawArguments)
            painter:setFontSize(25)
            painter:setColor(color or "white")
            local bounds = painter:measureText(text)
            local offset = Soko:worldPosition(bounds.width, bounds.height) / 2
            painter:drawText(text, drawArguments.worldPosition - offset)
        end

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

        innerTween:wait(0.2)

        innerTween:callback(function()
            textObject:destroy()
        end)
    end)
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

        local missionContent = missions:current()

        tween:callback(function()
            center = World.camera:tweenableViewBounds():get():center()

            auraCounter = World:spawnObject(Soko:gridPosition(0, 0))
            auraCounter.tweenablePosition:set(center + Soko:worldPosition(-160, 0))
            auraCounter.state["layer"] = 5
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
            multiplierCounter.state["layer"] = 5
            multiplierCounter.state["renderer"] = "lua"
            multiplierCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor("orange")
                draw_text.scoreCounter(painter, drawArguments, "Cross", score_events.currency().multiplier .. "X")
            end

            goldCounter = World:spawnObject(Soko:gridPosition(0, 0))
            goldCounter.tweenablePosition:set(center + Soko:worldPosition(0, 140))
            goldCounter.state["layer"] = 5
            goldCounter.state["renderer"] = "lua"
            goldCounter.state["render_function"] = function(painter, drawArguments)
                painter:setColor("gold")
                draw_text.scoreCounter(painter, drawArguments, "Gold", score_events.currency().gold)
            end
        end)

        tween:startMultiplex()

        for i = 1, #score_events:all() do
            local event = score_events:all()[i]
            tween:startSequence()

            tween:wait(0.2 * i)
            tween:dynamic(function(innerTween)
                if event.type == "dud" then
                    innerTween:startSequence()
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 10)), 0.1,
                        "quadratic_fast_slow")
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1,
                        "quadratic_slow_fast")
                    innerTween:endSequence()

                    spawnKicker(event.gridPosition, innerTween, "X", "white")
                end

                if event.type == "gain_score" then
                    innerTween:startMultiplex()

                    innerTween:startSequence()
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, -10)), 0.1,
                        "quadratic_fast_slow")
                    innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1,
                        "quadratic_slow_fast")
                    innerTween:endSequence()

                    innerTween:startSequence()

                    innerTween:callback(event.commit)


                    local color = "purple"
                    if event.currencyType == "gold" then
                        color = "gold"
                    elseif event.currencyType == "multiplier" then
                        color = "orange"
                    end

                    if event.amount < 0 then
                        color = "red"
                    end

                    spawnKicker(event.gridPosition, innerTween, tostring(event.amount), color)

                    innerTween:endSequence()

                    innerTween:endMultiplex()
                end
            end)
            tween:endSequence()
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
            local targetScoreState = "score"
            local targetScoreCounter = World:spawnObject(Soko:gridPosition(0, 0))
            targetScoreCounter.tweenablePosition:set(auraCounter.tweenablePosition:get())
            targetScoreCounter.state["layer"] = 5
            targetScoreCounter.state["renderer"] = "lua"
            targetScoreCounter.state["render_function"] = function(painter, drawArguments)
                if targetScoreState == "score" then
                    painter:setColor("white")
                    draw_text.scoreCounter(painter, drawArguments, "Target Power", score_events.targetScore())
                end

                if targetScoreState == "fail" then
                    painter:setColor("red")
                    painter:setFontSize(80 * targetScoreCounter.tweenableScale:get())
                    draw_text.draw(painter, drawArguments, tostring("FAILED"), Soko:worldPosition(0, 0), 0)
                end

                if targetScoreState == "success" then
                    painter:setColor("green")
                    painter:setFontSize(80 * targetScoreCounter.tweenableScale:get())
                    draw_text.draw(painter, drawArguments, tostring("SUCCESS"), Soko:worldPosition(0, 0), 0)
                end
            end

            innerTween:interpolate(targetScoreCounter.tweenablePosition:to(targetScoreCounter.tweenablePosition:get() +
                Soko:worldPosition(0, 100)), 0.5, "quadratic_fast_slow")

            innerTween:wait(0.5)

            isVictory = score_events.totalScore() >= score_events.targetScore()

            if isVictory then
                innerTween:callback(function()
                    targetScoreState = "success"
                end)

                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1.2), 0.1, "quadratic_fast_slow")
                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1), 0.2, "quadratic_slow_fast")

                innerTween:wait(0.25)

                for i = 1, score_events.payment() do
                    innerTween:callback(function()
                        score_events:currency()["gold"] = score_events:currency()["gold"] + 1
                    end)
                    innerTween:wait(0.1)
                end

                innerTween:callback(function()
                    score_events:currency()["rank"] = score_events:currency()["rank"] + (missionContent.rankReward or 0)
                end)
            else
                innerTween:callback(function()
                    targetScoreState = "fail"
                end)

                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1.2), 0.1, "quadratic_fast_slow")
                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1), 0.2, "quadratic_slow_fast")
            end
        end)

        tween:wait(1)

        tween:callback(function()
            run_context.gainGold(score_events:currency()["gold"])
            score_events:clearEvents()
            missions:clearContent()

            if World.levelState["is_tutorial"] and not isVictory then
                World:loadLevel("tutorial", { should_warp = true, has_failed = true })
            else
                World:loadLevel("house",
                    { is_victory = isVictory, should_warp = true, from_tutorial = World.levelState["is_tutorial"] })
            end
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
