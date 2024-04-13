local exports   = {}
local spawning  = require "library.spawning"
local animation = require "library.animation"
local player    = require "library.player"

function exports.onStart()
    local spawnPosition = World.levelState["force_spawn_position"]

    if spawnPosition == nil then
        for i, entity in ipairs(World:allEntities()) do
            if entity:templateName() == "player_spawn" then
                spawnPosition = entity.gridPosition
                break
            end
        end
    end

    spawnPosition = spawnPosition or Soko:gridPosition(0, 0)

    player.setInstance(spawning.spawnPlayer(spawnPosition, Soko.DIRECTION.DOWN))
end

function exports.onInput(input)
    if player.instance() then
        if input.direction ~= Soko.DIRECTION.NONE then
            local move = animation.interpolateMove(player.instance():generateDirectionalMove(input.direction))

            if World:getRoomAtGridPosition(move:startPosition()) ~= World:getRoomAtGridPosition(move:targetPosition()) then
                player.setInstance(spawning.spawnPlayer(move:targetPosition(), move.direction))
            end
        end

        if input.isPrimary then
            local itemAtPosition = nil

            for i, entity in ipairs(World:getEntitiesAt(player.instance().gridPosition)) do
                if entity:checkTrait("Surface", "Item") and entity ~= player.heldItem() then
                    itemAtPosition = entity
                    break
                end
            end

            if player.heldItem() == nil then
                -- is empty handed, pick up item if there is one
                if itemAtPosition ~= nil then
                    if itemAtPosition:checkTrait("Pickable", "CanPickUp") then
                        player.pickUpItem(itemAtPosition)
                    end

                    if itemAtPosition:templateName() == "nexus" then
                        print("tap nexus")
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
    local tile = World:getTileAt(move:targetPosition())
    if move:movingEntity() == player.instance() then
        if tile:checkTrait("Surface", "Wall") then
            move:stop()
        end
    end
end

function exports.onUpdate(dt)
    if player.heldItem() ~= nil then
        local gridOffset = player.instance().gridPosition - player.heldItem().gridPosition
        local newPosition =
            Soko.toWorldPosition(gridOffset) + player.instance():displacementTweenable():get() +
            Soko:worldPosition(0, -player.heldItem().state["height"])
        player.heldItem():displacementTweenable():set(newPosition)
    end
end

function exports.onEntityDestroyed(entity)

end

function exports.onRoomStateChanged(key)

end

function exports.onLoadLevel()

end

function exports.onLoadCheckpoint()

end

function exports.onEnter()

end

function exports.onTurn()

end

function exports.onLeave()

end

return exports
