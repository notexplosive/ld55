local score_events = {}
local impl         = {}
impl.list          = Soko:list()

function score_events.addEvent(entity, amount)
    impl.list:add(
        {
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            amount = amount,
            entity = entity
        }
    )
end

function score_events.all()
    return impl.list
end

function score_events.clearEvents()
    impl.list:clear()
end

return score_events
