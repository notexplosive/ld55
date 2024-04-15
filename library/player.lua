local animation = require "library.animation"
local lerp      = require "library.lerp"
local items     = require "library.items"
local constants = require "library.constants"
local player    = {}
local impl      = {}

local function setupHeldItemGraphic(entityTemplate)
    -- spawns a new instance of the entity in case it didn't already exist
    local entity = World:spawnEntity(Soko:gridPosition(0, 0), Soko.DIRECTION.NONE, entityTemplate)

    impl.heldItem.graphic = World:spawnObject(Soko:gridPosition(0, 0))
    impl.heldItem.graphic.state:addOtherState(entity.state)
    impl.heldItem.graphic.state["layer"] = 4

    entity:destroy()
end

function player.moveToRoom(room)
    World:loadRoom(room)
    World.camera:panToRoom(room)
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
        impl.heldItem.graphic.state["height"] = constants.objectHoldHeight
    end

    entity:setVisible(false)
    entity.state["graphic"] = World:spawnObject(entity.gridPosition)

    impl.uiObject = World:spawnObject(Soko:gridPosition(0, 0))
    impl.uiObject.state["renderer"] = "lua"
    impl.uiObject.state["layer"] = 3
    impl.uiObject.state["render_function"] = function(painter, drawArguments)
        if impl.heldItem and not player.hasCurrentUI() then
            local page = items[impl.heldItem.templateName]

            if page ~= nil then
                for _, rule in ipairs(page.rules) do
                    for _, gridOffset in ipairs(rule.parentPage.gridPositions) do
                        painter:drawCircle(
                            Soko:toWorldPosition(impl.instance.gridPosition + gridOffset) + Soko:getHalfTileSize() +
                            impl.instance:displacementTweenable():get(), 5, 2, 5)
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
    animation.interpolateState(impl.heldItem.graphic.state, "height", lerp.number, constants.objectHoldHeight, 0.05)
    impl.instance.state["is_carrying"] = true
    animation.toPose(impl.instance, "idle")

    World:playSound("pickup", 1)

    entity:destroy()
end

function player.dropItem()
    if impl.heldItem == nil then
        print("error: attempted to drop when not holding anything")
        return nil
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

    World:playSound("drop", 0.5)

    World:raiseEventAt(droppedItem.gridPosition, "itemDropped", { item = droppedItem })
    return droppedItem
end

function player.setUI(ui)
    impl.currentUI = ui
end

function player.hasCurrentUI()
    return impl.currentUI ~= nil and not impl.currentUI.animatedObject:isDestroyed()
end

function player.currentUI()
    if player.hasCurrentUI() then
        return impl.currentUI
    end
end

function player.move(direction)
    local move = animation.interpolateMove(player.instance():generateDirectionalMove(direction))

    if move:isAllowed() then
        World:playSound("step", 0.8, -.5)

        local targetRoom = World:getRoomAtGridPosition(move:targetPosition())
        if World:getRoomAtGridPosition(move:startPosition()) ~= targetRoom then
            player.moveToRoom(targetRoom)
        end

        World:raiseEventAt(move:targetPosition(), "playerSteppedOn", {})
        return true
    end
    return false
end

return player
