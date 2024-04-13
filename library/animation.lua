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

function animation.interpolateMove(move)
    World:playAnimation(moveAnimation, {move = move})
    return move
end

return animation