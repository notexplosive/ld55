local exports      = {}
local spawning     = require "library.spawning"
local animation    = require "library.animation"
local player       = require "library.player"
local score_events = require "library.score_events"
local run_context  = require "library.run_context"
local shop         = require "library.shop"
local missions     = require "library.missions"
local constants    = require "library.constants"
local items        = require "library.items"

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

        if entity.state["behavior"] == "mission_post" then
            missions.setup(entity)
        end

        if entity.state["special"] == "storage" then
            run_context.rehydrateStorage(entity.gridPosition)
        end

        if entity.state["special"] == "shop" then
            shop.placeOfferAt(entity.gridPosition)
        end

        if entity.state["behavior"] == "tutorial" and World.levelState["has_failed"] then
            player.instance().gridPosition = entity.gridPosition + Soko:gridPosition(0, 1)
            local room = World:getRoomAtGridPosition(entity.gridPosition)
            player.moveToRoom(room)
            World.camera:snapToRoom(room)
        end

        if entity:templateName() == "npc" then
            entity:displacementTweenable():set(Soko:worldPosition(0, -constants.playerHeight))
        end

        if entity.state["behavior"] == "bone_door" then
            local prop = World:spawnObject(entity.gridPosition)
            prop.tweenablePosition:set(prop.tweenablePosition:get() + Soko:worldPosition(0, 0))
            prop.state["renderer"] = "SingleFrame"
            prop.state["layer"] = 1
            prop.state["sheet"] = "bone_doorway"
            entity:setVisible(false)
            entity.state["prop"] = prop
        end

        if entity:templateName() == "shelf" then
            local tempItem = World:spawnEntity(entity.gridPosition, Soko.DIRECTION.NONE, entity.state["item"])

            local object = World:spawnObject(entity.gridPosition)
            local startigPosition = object.tweenablePosition:get()
            object.tweenablePosition:set(startigPosition + Soko:worldPosition(-5, -8))
            object.state:addOtherState(tempItem.state)

            local object2 = World:spawnObject(entity.gridPosition)
            object2.tweenablePosition:set(startigPosition + Soko:worldPosition(5, -6))
            object2.state:addOtherState(tempItem.state)

            tempItem:destroy()
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
            player.move(input.direction)
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
                        local canPickUp = true
                        if itemAtPosition.state["price"] then
                            canPickUp = shop.attemptPurchase(itemAtPosition)
                        end

                        if canPickUp then
                            player.pickUpItem(itemAtPosition)
                        end
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
                if shelfAhead ~= nil then
                    if shelfAhead:templateName() == "shelf" and player.heldItemName() == shelfAhead.state["item"] then
                        local droppedItem = player.dropItem()

                        if droppedItem then
                            droppedItem:destroy()
                        end
                    end

                    World:raiseEventAt(shelfAhead.gridPosition, "onFailDrop", {})
                else
                    -- has item, attempt to drop it
                    if itemAtPosition == nil then
                        player.dropItem()
                    else
                        -- fail to drop because there's an item there
                        World:raiseEventAt(itemAtPosition.gridPosition, "onFailDrop", {})
                    end
                end
            end
        end
    end
end

function exports.onMove(move)
    for i, gridling in ipairs(World:getGridlingsAt(move:targetPosition())) do
        if gridling:checkTrait("Surface", "Item") and move:movingEntity():checkTrait("Surface", "Item") then
            move:stop()
        end

        if gridling:checkTrait("Surface", "Wall") then
            move:stop()
            if move:movingEntity() == player.instance() then
                World:raiseEventAt(move:targetPosition(), "onTouched", { move = move })
            end
        end
    end
end

function exports.onUpdate(dt)
    if player.instance() ~= nil then
        local playerWorldPosition =
            Soko:toWorldPosition(player.instance().gridPosition) + player.instance():displacementTweenable():get()
        if player.hasHeldItem() then
            local newPosition = playerWorldPosition + Soko:worldPosition(0, -player.heldItemGraphic().state["height"])
            player.heldItemGraphic().tweenablePosition:set(newPosition)
        end

        local cameraSize = World.roomState["force_camera_size"]
        if cameraSize ~= nil then
            local gridAlignedWorldPosition = Soko:toWorldPosition(player.instance().gridPosition)
            local rectangle = Soko:rectangle(gridAlignedWorldPosition.x, gridAlignedWorldPosition.y, 0, 0)
            rectangle = rectangle:inflated(Soko:worldPosition(cameraSize[1], cameraSize[2]))
            rectangle = rectangle.constrain(World.getRoomAtGridPosition(player.instance().gridPosition):viewBounds())
            World.camera:panToRectangle(rectangle)
        end

        local graphic = player.instance().state["graphic"]
        graphic.state:addOtherState(player.instance().state)
        graphic.state["direction"] = player.instance().facingDirection.name
        graphic.tweenablePosition:set(playerWorldPosition + Soko:worldPosition(0, -constants.playerHeight))
    end
end

function exports.onEntityDestroyed(entity)
end

function exports.onRoomStateChanged(key)

end

function exports.onLoadLevel()
    player.clearState()
    score_events.clearEverything()
end

function exports.onLoadCheckpoint()
    -- player.clearState()
    -- score_events.clearEvents()
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
