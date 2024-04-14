local player = require "library.player"
local run_context = require "library.run_context"
local spawning = {}

function spawning.spawnPlayer(spawnPosition, direction)
    local room = World:getRoomAtGridPosition(spawnPosition)
    World.camera:snapToRoom(room)
    player.moveToRoom(room)
    return World:spawnEntity(spawnPosition, direction, "player")
end

return spawning
