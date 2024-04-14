local exports      = {}
local spawning     = require "library.spawning"
local animation    = require "library.animation"
local player       = require "library.player"
local score_events = require "library.score_events"
local run_context  = require "library.run_context"

function exports.onStart()
    if player.instance() == nil then
        local shouldWarp = World.levelState["should_warp"] or false
        local shouldIncludeItems = not World.levelState["skip_items"]
        local spawnPosition = World.levelState["force_spawn_position"]

        if spawnPosition == nil then
            for i, entity in ipairs(World:allEntities()) do
                if entity:templateName() == "player_spawn" then
                    spawnPosition = entity.gridPosition
                    break
                end

                if entity:templateName() == "nexus" then
                    spawnPosition = entity.gridPosition
                    shouldWarp = true
                    break
                end
            end
        end

        spawnPosition = spawnPosition or Soko:gridPosition(0, 0)

        player.setInstance(spawning.spawnPlayer(spawnPosition, Soko.DIRECTION.DOWN))

        if shouldWarp then
            local items = Soko:list()
            if shouldIncludeItems then
                items = run_context.rehydrateLoadingDock(player.instance().gridPosition)
            end
            animation.warpIn(player.instance(), items)
        end
    end

    for i, entity in ipairs(World:allEntities()) do
        if entity.state["behavior"] == "home_teleporter" then
            run_context.rehydrateLoadingDock(entity.gridPosition)
        end
    end
end

function exports.onInput(input)
    if player.currentUI() then
        player.currentUI().onInput(input)
        return
    end

    if player.instance() then
        if input.direction ~= Soko.DIRECTION.NONE then
            local move = animation.interpolateMove(player.instance():generateDirectionalMove(input.direction))

            if move:isAllowed() then
                local targetRoom = World:getRoomAtGridPosition(move:targetPosition())
                if World:getRoomAtGridPosition(move:startPosition()) ~= targetRoom then
                    player.moveToRoom(targetRoom)
                end
            end
        end

        if input.isPrimary then
            local itemAtPosition = nil
            local shelfAhead = nil

            for i, entity in ipairs(World:getEntitiesAt(player.instance().gridPosition)) do
                if entity:checkTrait("Surface", "Item") then
                    itemAtPosition = entity
                    break
                end
            end

            for i, entity in ipairs(World:getEntitiesAt(player.instance().gridPosition + player.instance().facingDirection:toGridPosition())) do
                if entity:checkTrait("Surface", "Wall") and entity:checkTrait("Pickable", "CanActivate") then
                    shelfAhead = entity
                    break
                end
            end

            if not player.hasHeldItem() then
                -- is empty handed, pick up item if there is one
                if itemAtPosition ~= nil then
                    if itemAtPosition:checkTrait("Pickable", "CanPickUp") then
                        player.pickUpItem(itemAtPosition)
                    else
                        -- activate item
                        World:raiseEventAt(itemAtPosition.gridPosition, "onActivate", {})
                    end
                else
                    if shelfAhead ~= nil then
                        if shelfAhead:templateName() == "shelf" then
                            player.pickUpItem(World:spawnEntity(player.instance().gridPosition, Soko.DIRECTION.NONE,
                                shelfAhead.state["item"]))
                        end

                        -- activate item
                        World:raiseEventAt(shelfAhead.gridPosition, "onActivate", {})
                    end
                end
            else
                -- has item, attempt to drop it
                if itemAtPosition == nil then
                    player.dropItem()
                else
                    -- fail to drop because there's an item there
                end
            end
        end
    end
end

function exports.onMove(move)
    for i, gridling in ipairs(World:getGridlingsAt(move:targetPosition())) do
        if move:movingEntity() == player.instance() then
            if gridling:checkTrait("Surface", "Wall") then
                World:raiseEventAt(move:targetPosition(), "onTouched", { move = move })
                move:stop()
            end
        end
    end
end

function exports.onUpdate(dt)
    local playerWorldPosition =
        Soko:toWorldPosition(player.instance().gridPosition) + player.instance():displacementTweenable():get()
    if player.hasHeldItem() then
        local newPosition = playerWorldPosition + Soko:worldPosition(0, -player.heldItemGraphic().state["height"])
        player.heldItemGraphic().tweenablePosition:set(newPosition)
    end

    local cameraSize = World.roomState["force_camera_size"]
    if cameraSize ~= nil then
        local playerWorldPosition = Soko:toWorldPosition(player.instance().gridPosition)
        local rectangle = Soko:rectangle(playerWorldPosition.x, playerWorldPosition.y, 0, 0)
        rectangle = rectangle:inflated(Soko:worldPosition(cameraSize[1], cameraSize[2]))
        rectangle = rectangle.constrain(World.getRoomAtGridPosition(player.instance().gridPosition):viewBounds())
        World.camera:panToRectangle(rectangle)
    end
end

function exports.onEntityDestroyed(entity)

end

function exports.onRoomStateChanged(key)

end

function exports.onLoadLevel()
    player.clearState()
    score_events.clearEvents()
end

function exports.onLoadCheckpoint()
    player.clearState()
    score_events.clearEvents()
end

function exports.onEnter()
    World:raiseEntityEvent("onEnter", {})
end

function exports.onLeave()
    World:raiseEntityEvent("onExit", {})
end

function exports.onTurn()

end

return exports
