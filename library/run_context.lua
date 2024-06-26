local run_context = {}
local impl        = {}

-- Tally up the loading dock / storage entities
local function calculateSpaceItems(tile)
    local items = Soko:list()
    for i, entity in ipairs(World:allEntitiesInRoom()) do
        if World:getTileAt(entity.gridPosition):templateName() == tile then
            if entity:checkTrait("Pickable", "CanPickUp") then
                items:add(entity)
            end
        end
    end

    return items
end

local function dehydrate(entities, centerGridPosition)
    local itemBlueprints = Soko:list()
    for i, item in ipairs(entities) do
        itemBlueprints:add(
            {
                template = item:templateName(),
                position = item.gridPosition - centerGridPosition
            }
        )
    end
    return itemBlueprints
end

-- Turns item blueprints back into concrete entities, centered around a grid position
local function rehydrate(itemBlueprints, centerGridPosition)
    itemBlueprints = itemBlueprints or {}
    local itemEntities = Soko:list()
    for i, itemBlueprint in ipairs(itemBlueprints) do
        local position = itemBlueprint.position + centerGridPosition
        itemEntities:add(World:spawnEntity(position, Soko.DIRECTION.NONE, itemBlueprint.template))
    end
    return itemEntities
end

function run_context.clear()
    -- most likely only ever want to do this on startup
    impl.loadingDockItems = {
        {
            template = "candle",
            position = Soko:gridPosition(0, 1)
        },
        {
            template = "candle",
            position = Soko:gridPosition(0, -1)
        },
        {
            template = "candle",
            position = Soko:gridPosition(1, 0)
        },
        {
            template = "candle",
            position = Soko:gridPosition(-1, 0)
        }
    }
    impl.storageItems     = {}
    impl.storageUpgrade   = 0
    impl.loadingUpgrade   = 0
    impl.wallet           = 10
    impl.progress         = 1
    impl.rank             = 0
end

function run_context.saveLoadingDock(gridPosition)
    impl.loadingDockItems = dehydrate(run_context.calculateLoadingDockItems(), gridPosition)
end

function run_context.saveStorage(gridPosition)
    impl.storageItems = dehydrate(run_context.calculateStorageItems(), gridPosition)
end

function run_context.rehydrateLoadingDock(warpGridPosition)
    return rehydrate(impl.loadingDockItems, warpGridPosition)
end

function run_context.rehydrateStorage(warpGridPosition)
    return rehydrate(impl.storageItems, warpGridPosition)
end

function run_context.calculateLoadingDockItems()
    return calculateSpaceItems("loading_dock_floor")
end

function run_context.calculateStorageItems()
    return calculateSpaceItems("storage_floor")
end

function run_context.canAfford(cost)
    return impl.wallet >= cost
end

function run_context.spend(cost)
    impl.wallet = impl.wallet - cost
end

function run_context.gold()
    return impl.wallet
end

function run_context.gainGold(amount)
    impl.wallet = impl.wallet + amount
end

function run_context.setProgress(progress)
    impl.progress = progress
end

function run_context.getProgress()
    return impl.progress
end

function run_context.gainRank(amount)
    impl.rank = impl.rank + amount
end

function run_context.getRank()
    return impl.rank
end

local function calculateBracket(rank)
    return math.ceil(rank / 3)
end

function run_context.rankToNextPromotion()
    local currentBracket = calculateBracket(impl.rank)
    for i = impl.rank, impl.rank + 1000 do
        if currentBracket ~= calculateBracket(i) then
            return i
        end
    end
    return 0
end

function run_context.getRankBracket()
    return calculateBracket(impl.rank)
end

run_context.clear()

return run_context
