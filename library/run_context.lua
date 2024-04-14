local player                  = require "library.player"
local run_context             = {}
local impl                    = {}

impl.loadingDockItems         = {}
impl.personalSpaceItems       = {}
impl.personalSpaceSizeUpgrade = 0
impl.loadingDockSizeUpgrade   = 0

function run_context.clear()
    -- we most likely never want to clear this after startup
end

function run_context.saveLoadingDock()
    local itemBlueprints = Soko:list()

    for i, item in ipairs(run_context.calculateLoadingDockItems()) do
        itemBlueprints:add(
            {
                template = item:templateName(),
                position = item.gridPosition - player.instance().gridPosition
            }
        )
    end

    impl.loadingDockItems = itemBlueprints
end

-- Turns item blueprints back into concrete entities, centered around the target grid position
function run_context.rehydrateLoadingDock(warpGridPosition)
    local itemEntities = Soko:list()
    local itemBlueprints = run_context.loadLoadingDock()
    for i, itemBlueprint in ipairs(itemBlueprints) do
        local position = itemBlueprint.position + warpGridPosition
        itemEntities:add(World:spawnEntity(position, Soko.DIRECTION.NONE, itemBlueprint.template))
    end
    return itemEntities
end

function run_context.loadLoadingDock()
    return impl.loadingDockItems or Soko:list()
end

-- Tally up the loading dock entities
function run_context.calculateLoadingDockItems()
    local items = Soko:list()
    for i, entity in ipairs(World:allEntitiesInRoom()) do
        if World:getTileAt(entity.gridPosition):templateName() == "loading_dock_floor" then
            if entity:checkTrait("Pickable", "CanPickUp") then
                items:add(entity)
            end
        end
    end

    return items
end

run_context.clear()

return run_context
