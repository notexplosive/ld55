local score_events   = require "library.score_events"
local draw_text      = require "library.draw_text"
local run_context    = require "library.run_context"
local missions       = require "library.missions"
local score          = require "library.score"
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

        local scrim = World:spawnObject(player.gridPosition)
        scrim.tweenableOpacity:set(0)
        scrim.state["layer"] = 3
        scrim.state["renderer"] = "lua"
        scrim.state["render_function"] = function(painter, drawArguments)
            painter:setColor(Soko:color(0, 0, 0, scrim.tweenableOpacity:get()))
            painter:drawFillRectangle(World.camera:tweenableViewBounds():get())
        end

        local circleItems = Soko:list()
        circleItems:add({ sprite = "prop:screen_magic_circle_center", color = "red", spinRate = 1, scaleRate = 5, opacity = 0.5 })
        circleItems:add({ sprite = "prop:screen_magic_circle_inner_ring", color = "purple", spinRate = -.5, scaleRate = 4, opacity = 0.4 })
        circleItems:add({ sprite = "prop:screen_magic_circle_middle_ring", color = "orange", spinRate = -.25, scaleRate = 3, opacity = 0.3 })
        circleItems:add({ sprite = "prop:screen_magic_circle_outer_ring", color = "purple", spinRate = -.05, scaleRate = 2, opacity = 0.3 })

        tween:startMultiplex() -- master multiplex: animated circles in one channel, main sequence in the other

        for i, circleItem in ipairs(circleItems) do
            local circle = World:spawnObject(player.gridPosition)
            circle.state["renderer"] = "SingleFrame"
            circle.state["sheet"] = circleItem.sprite
            circle.state["tint"] = circleItem.color
            circle.state["layer"] = 1
            circle.tweenableScale:set(0)
            circle.tweenableOpacity:set(0)
            tween:interpolate(circle.tweenableOpacity:to(circleItem.opacity), 1, "linear")
            tween:interpolate(circle.tweenableScale:to(1), circleItem.scaleRate, "cubic_fast_slow")
            tween:interpolate(circle.tweenableAngle:to(math.pi * 2 * circleItem.spinRate), 100, "cubic_fast_slow")
        end

        tween:startSequence() -- main sequence: has everything except for the animated circles

        -- fly player out
        tween:startMultiplex()
        tween:callback(function()
            World:stopSong()
            World:playSound("fly_out", 1)
        end)
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


        tween:callback(function()
            center = World.camera:tweenableViewBounds():get():center()

            score_events:beginScoreTally()

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

        local pitchImpl = 0
        local function pitch()
            pitchImpl = math.min(pitchImpl + 0.1, 1)
            return pitchImpl
        end

        local function addEventsToTween(passedTween)
            passedTween:startMultiplex() -- main event multiplex

            -- runs all pending events, this will likely generate more events that will need to be run
            for i = 1, #score_events:all() do
                local event = score_events:all()[i]
                passedTween:startSequence()

                -- add a delay proportional to the number of events that happened
                passedTween:wait(0.2 * i)

                passedTween:dynamic(function(innerTween)
                    if event.entity ~= nil and event.entity:isDestroyed() then
                        return
                    end

                    if event.type == "dud" then
                        innerTween:startSequence()
                        innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 10)), 0.1,
                            "quadratic_fast_slow")
                        innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1,
                            "quadratic_slow_fast")
                        innerTween:endSequence()

                        spawnKicker(event.gridPosition(), innerTween, "X", "white")
                    end

                    if event.type == "begin_rise" then
                        innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, -10)), 0.1,
                            "quadratic_fast_slow")
                    end

                    if event.type == "end_rise" then
                        innerTween:interpolate(event.entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1,
                            "quadratic_slow_fast")
                    end

                    if event.type == "kicker" then
                        spawnKicker(event.gridPosition(), innerTween, event.text, event.color)
                    end

                    if event.type == "destroy" then
                        innerTween:callback(function()
                            for i, entityToDestroy in ipairs(World:getEntitiesAt(event.gridPosition())) do
                                local page = GET_ITEM_RULE_PAGE(entityToDestroy:templateName())
                                if page ~= nil then
                                    innerTween:callback(function()
                                        page.executeDeathTrigger(entityToDestroy, event.entity)
                                        entityToDestroy:destroy()
                                        score_events.onEntityDestroyed(entityToDestroy)
                                    end)
                                end
                            end
                        end)
                    end

                    if event.type == "move" then
                        local move = event.entity:generateDirectionalMove(event.direction)
                        animation.interpolateMove(move)

                        local page = GET_ITEM_RULE_PAGE(event.entity:templateName())
                        if page ~= nil then
                            page.notifyOfMove(event.entity, move:isAllowed())
                        end
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
                            World:playSound("buy", 0.5, 0.5)
                            color = "gold"
                        elseif event.currencyType == "multiplier" then
                            World:playSound("score2", 1, pitch())
                            color = "orange"
                        else
                            World:playSound("score", 1, pitch())
                        end

                        if event.amount < 0 then
                            color = "red"
                        end


                        spawnKicker(event.gridPosition(), innerTween, tostring(event.amount), color)

                        innerTween:endSequence()

                        innerTween:endMultiplex()
                    end
                end)
                passedTween:endSequence()
            end
            passedTween:endMultiplex() -- main event multiplex
            local totalNumberOfEvents = #score_events:all()
            score_events:clearEvents()
            return totalNumberOfEvents
        end

        local entities = score.calculateEntities()

        tween:startMultiplex()    -- all events multiplex
        for i, entityToTrigger in ipairs(entities) do
            tween:startSequence() -- entity sequence

            -- add a delay proportional to the item index, so things still execute in sequence
            tween:wait(0.4 * i)

            tween:callback(function()
                score_events.triggerEntity(entityToTrigger)
                for i, entityToNotify in ipairs(entities) do
                    local page = GET_ITEM_RULE_PAGE(entityToNotify:templateName())
                    if page ~= nil then
                        page.notifyOfTrigger(page, entityToNotify, entityToTrigger)
                    end
                end
            end)

            tween:dynamic(function(innerTween)
                addEventsToTween(innerTween)
            end)
            tween:endSequence() -- entity sequence
        end
        tween:endMultiplex()    -- all events multiplex

        tween:dynamic(function(innerTween)
            -- adds any extra events added to the tween (this is not recursive)
            addEventsToTween(innerTween)
        end)

        tween:interpolate(scrim.tweenableOpacity:to(0.5), 1, "linear")

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
                    draw_text.draw(painter, drawArguments, "FAILED", Soko:worldPosition(0, 0), 0)
                end

                if targetScoreState == "success" then
                    painter:setColor("green")
                    painter:setFontSize(80 * targetScoreCounter.tweenableScale:get())
                    draw_text.draw(painter, drawArguments, "SUCCESS", Soko:worldPosition(0, 0), 0)
                end

                if targetScoreState == "promotion" then
                    painter:setColor("green")
                    painter:setFontSize(80 * targetScoreCounter.tweenableScale:get())
                    draw_text.draw(painter, drawArguments, "PROMOTION", Soko:worldPosition(0, 0), 0)
                end

                if targetScoreState == "next_rank" then
                    local text = "Next Promotion: " ..
                        run_context.getRank() .. " / " .. run_context.rankToNextPromotion()
                    painter:setColor("white")
                    painter:setFontSize(40 * targetScoreCounter.tweenableScale:get())
                    draw_text.draw(painter, drawArguments, text, Soko:worldPosition(0, 0), 0)
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

                -- do rank up
                innerTween:dynamic(function(innerTween2)
                    local prevBracket = run_context.getRankBracket()
                    run_context.gainRank(missionContent.rankReward or 0)
                    local newBracket = run_context.getRankBracket()
                    if not World.levelState["is_tutorial"] then
                        innerTween2:wait(2)

                        if prevBracket ~= newBracket then
                            innerTween2:callback(function()
                                targetScoreState = "promotion"
                            end)
                        else
                            innerTween2:callback(function()
                                targetScoreState = "next_rank"
                            end)
                        end

                        innerTween2:interpolate(targetScoreCounter.tweenableScale:to(1.2), 0.1, "quadratic_fast_slow")
                        innerTween2:interpolate(targetScoreCounter.tweenableScale:to(1), 0.2, "quadratic_slow_fast")
                    end
                end)
            else
                innerTween:callback(function()
                    targetScoreState = "fail"
                end)

                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1.2), 0.1, "quadratic_fast_slow")
                innerTween:interpolate(targetScoreCounter.tweenableScale:to(1), 0.2, "quadratic_slow_fast")
            end
        end)

        tween:wait(2)

        tween:callback(function()
            run_context.gainGold(score_events:currency()["gold"])
            score_events:clearEverything()
            missions:clearContent()

            if World.levelState["is_tutorial"] and not isVictory then
                World:loadLevel("tutorial", { should_warp = true, has_failed = true })
            else
                World:loadLevel("house",
                    { is_victory = isVictory, should_warp = true, from_tutorial = World.levelState["is_tutorial"] })
            end
        end)

        tween:callback(function()
            score_events:endScoreTally()
        end)

        tween:endSequence()  -- main sequence
        tween:endMultiplex() -- master multiplex
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
        for i = 1, 24 do
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

    World:playSound("fly_in")

    doWarp(flyDown, playerEntity, items, whenDone)
end

return animation
