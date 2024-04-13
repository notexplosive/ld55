local animation = require "library.animation"
local lerp      = require "library.lerp"
local items     = require "library.items"
local player    = {}
local impl      = {}

function player.setInstance(entity)
    impl.instance = entity

    if impl.uiObject ~= nil then
        impl.uiObject:destroy()
    end
    impl.uiObject = World:spawnObject(Soko:gridPosition(0, 0))
    impl.uiObject.state["renderer"] = "lua"
    impl.uiObject.state["layer"] = 3
    impl.uiObject.state["render_function"] = function(painter, drawArguments)
        if impl.heldItem then
            local page = items[impl.heldItem:templateName()]

            if page ~= nil then
                for _, rule in ipairs(page.rules) do
                    for _, gridOffset in ipairs(rule.gridPositions) do
                        painter:drawCircle(
                            Soko:toWorldPosition(impl.instance.gridPosition + gridOffset) + Soko:getHalfTileSize() +
                            impl.instance:displacementTweenable():get(), 10, 2, 10)
                    end
                end
            end
        end
    end
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
    if not entity:checkTrait("Pickable", "CanPickUp") then
        return
    end

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
