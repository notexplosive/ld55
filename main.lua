local spawning = require "library.spawning"
local animation= require "library.animation"
local exports = {}

PLAYER = nil

function exports.onStart()
    local spawnPosition = World.levelState["force_spawn_position"] or Soko:gridPosition(0,0)
    PLAYER = spawning.spawnPlayer(spawnPosition, Soko.DIRECTION.DOWN)
end

function exports.onMove(move)
    local tile = World:getTileAt(move:targetPosition())
    if move:movingEntity() == PLAYER then
        if tile:checkTrait("Surface", "Wall") then
            move:stop()
        end
    end
end

function exports.onEntityDestroyed(entity)

end


function exports.onRoomStateChanged(key)

end


function exports.onInput(input)
    if PLAYER then
        local move = animation.interpolateMove(PLAYER:generateDirectionalMove(input.direction))

        if World:getRoomAtGridPosition(move:startPosition()) ~=  World:getRoomAtGridPosition(move:targetPosition()) then
            PLAYER = spawning.spawnPlayer(move:targetPosition(), Soko.DIRECTION.DOWN)
        end
    end
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

function exports.onUpdate(dt)

end

return exports

