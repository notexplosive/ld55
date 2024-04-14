local score_events = {}
local impl         = {}
impl.list          = Soko:list()

local function addScore(entity, amount, isMultiplier)
    impl.list:add(
        {
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            amount = amount,
            isMultiplier = isMultiplier,
            entity = entity
        }
    )
end

function score_events.addRegularScoreEvent(entity, amount)
    addScore(entity, amount, false)
end

function score_events.addMultiplierScoreEvent(entity, amount)
    addScore(entity, amount, true)
end

function score_events.all()
    return impl.list
end

function score_events.clearEvents()
    impl.list:clear()
end

return score_events
