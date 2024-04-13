local animation = {}

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

local flyMaxPosition = Soko:worldPosition(0, -500)

local function flyUp(tween, entity)
    tween:wait(1)
    tween:interpolate(entity:displacementTweenable():to(flyMaxPosition), 0.5,
        "cubic_slow_fast")
    tween:callback(function()
        entity:setVisible(false)
    end)
end


local function flyDown(tween, entity)
    tween:callback(function()
        entity:displacementTweenable():set(flyMaxPosition)
    end)
    tween:interpolate(entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 1, "cubic_fast_slow")
end

local function doWarp(func, playerEntity, items, whenDone)
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

        local itemTemplates = Soko:list()
        for i, item in ipairs(items) do
            tween:startSequence()
            tween:wait(i * 0.1)
            func(tween, item)
            tween:endSequence()

            itemTemplates:add(
                {
                    template = item:templateName(),
                    position = item.gridPosition - playerEntity.gridPosition
                }
            )
        end

        tween:endMultiplex()

        if whenDone ~= nil then
            tween:callback(function()
                whenDone(itemTemplates)
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
