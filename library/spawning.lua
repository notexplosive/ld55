local spawning = {}

function spawning.spawnPlayer(spawnPosition, direction)
    local room = World:getRoomAtGridPosition(spawnPosition)
    World:loadRoom(room)
    World.camera:snapToRoom(room)
    print("loaded room " .. room:topLeft().x .. "," .. room:topLeft().y )
    return World:spawnEntity(spawnPosition, direction, "player")
end

return spawning