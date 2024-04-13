local player = require "library.player"
local spawning = {}

function spawning.spawnPlayer(spawnPosition, direction)
    local room = World:getRoomAtGridPosition(spawnPosition)
    World.camera:snapToRoom(room)
    player.moveToRoom(room)
    return World:spawnEntity(spawnPosition, direction, "player")
end

function spawning.spawnStartingItems()
    local items = Soko:list()
    local itemBlueprints = World.levelState["starting_items"] or Soko:list()
    for i, itemBlueprint in ipairs(itemBlueprints) do
        local position = itemBlueprint.position + player.instance().gridPosition
        items:add(World:spawnEntity(position, Soko.DIRECTION.NONE, itemBlueprint.template))
    end
    return items
end

return spawning
