local spawning = {}

function spawning.spawnPlayer(spawnPosition, direction)
    local room = World:getRoomAtGridPosition(spawnPosition)
    World:loadRoom(room)
    World.camera:snapToRoom(room)
    return World:spawnEntity(spawnPosition, direction, "player")
end

return spawning
