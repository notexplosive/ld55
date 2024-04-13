local animation = {}

local function moveAnimation(tween, params)
    local move = params.move
    local movingEntity = move:movingEntity()
    move:execute()

    if move:isAllowed() then
        local size = Soko:getHalfTileSize().x * 2
        movingEntity:displacementTweenable():set(move.direction:toWorldPosition() * -size)

        tween:interpolate(
            movingEntity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.025, "quadratic_fast_slow")
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
    World:playAnimation(moveAnimation, { move = move })
    return move
end

function animation.displacementToZero(entity)
    World:playAnimation(function(tween, params)
        tween:interpolate(entity:displacementTweenable():to(Soko:worldPosition(0, 0)), 0.1, "quadratic_slow_fast")
    end)
end

return animation
