local animation = require "library.animation"
local lerp      = require "library.lerp"
local player    = {}
local impl      = {}

function player.setInstance(entity)
    impl.instance = entity
end

function player.instance()
    return impl.instance
end

function player.clearState()
    impl = {}
end

function player.heldItem()
    return impl.heldItem
end

function player.pickUpItem(entity)
    entity.state["layer"] = 4

    entity.state["height"] = 0
    animation.interpolateState(entity.state, "height", lerp.number, 20, 0.05)

    impl.heldItem = entity
end

function player.dropItem()
    if impl.heldItem == nil then
        print("error: attempted to drop when not holding anything")
        return
    end

    impl.heldItem.state["layer"] = 2
    impl.heldItem.displacementTweenable():set(Soko:worldPosition(0, -impl.heldItem.state["height"]))
    animation.displacementToZero(impl.heldItem)

    impl.heldItem.gridPosition = impl.instance.gridPosition
    impl.heldItem = nil
end

return player
