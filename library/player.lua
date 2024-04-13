local animation   = require "library.animation"
local lerp        = require "library.lerp"
local items       = require "library.items"
local player      = {}
local impl        = {}

local HELD_HEIGHT = 20

local function setupHeldItemGraphic(entityTemplate)
    -- spawns a new instance of the entity in case it didn't already exist
    local entity = World:spawnEntity(Soko:gridPosition(0, 0), Soko.DIRECTION.NONE, entityTemplate)

    impl.heldItem.graphic = World:spawnObject(Soko:gridPosition(0, 0))
    impl.heldItem.graphic.state:addOtherState(entity.state)
    impl.heldItem.graphic.state["layer"] = 4

    entity:destroy()
end

function player.setInstance(entity)
    local oldState
    if impl.instance then
        oldState = impl.instance.state
    end

    impl.instance = entity

    if oldState then
        entity.state:addOtherState(oldState)
    end

    if impl.uiObject ~= nil then
        impl.uiObject:destroy()
    end

    if impl.heldItem ~= nil and player.heldItemGraphic() then
        player.heldItemGraphic():destroy()
        setupHeldItemGraphic(impl.heldItem.templateName)
        impl.heldItem.graphic.state["height"] = HELD_HEIGHT
    end

    impl.uiObject = World:spawnObject(Soko:gridPosition(0, 0))
    impl.uiObject.state["renderer"] = "lua"
    impl.uiObject.state["layer"] = 3
    impl.uiObject.state["render_function"] = function(painter, drawArguments)
        if impl.heldItem then
            local page = items[impl.heldItem.templateName]

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

    animation.toPose(impl.instance, "idle")
end

function player.instance()
    return impl.instance
end

function player.clearState()
    impl = {}
end

function player.hasHeldItem()
    return impl.heldItem ~= nil
end

function player.heldItemGraphic()
    if impl.heldItem == nil then
        return nil
    end

    return impl.heldItem.graphic
end

function player.heldItemName()
    if impl.heldItem == nil then
        return nil
    end

    return impl.heldItem.templateName
end

function player.pickUpItem(entity)
    if not entity:checkTrait("Pickable", "CanPickUp") then
        return
    end

    impl.heldItem = {
        templateName = entity:templateName(),
    }

    setupHeldItemGraphic(entity:templateName())
    impl.heldItem.graphic.state["height"] = 0
    animation.interpolateState(impl.heldItem.graphic.state, "height", lerp.number, HELD_HEIGHT, 0.05)
    impl.instance.state["is_carrying"] = true
    animation.toPose(impl.instance, "idle")

    entity:destroy()
end

function player.dropItem()
    if impl.heldItem == nil then
        print("error: attempted to drop when not holding anything")
        return
    end

    local droppedItem = World:spawnEntity(impl.instance.gridPosition, Soko.DIRECTION.NONE, impl.heldItem.templateName)

    impl.instance.state["is_carrying"] = false
    animation.toPose(impl.instance, "idle")
    droppedItem.state:addOtherState(impl.heldItem.graphic.state)
    droppedItem.state["layer"] = 2
    droppedItem.displacementTweenable():set(Soko:worldPosition(0, -droppedItem.state["height"]))
    animation.displacementToZero(droppedItem)

    droppedItem.gridPosition = impl.instance.gridPosition
    impl.heldItem.graphic:destroy()
    impl.heldItem = nil
end

return player
