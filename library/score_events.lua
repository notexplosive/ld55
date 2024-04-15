local missions     = require "library.missions"
local score_events = {}
local impl         = {}
impl.list          = Soko:list()
impl.room          = nil
impl.currency      = {
    normal = 0,
    gold = 0,
    multiplier = 1
}

local function addScore(entity, amount, currencyType)
    impl.list:add(
        {
            type = "gain_score",
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            amount = amount,
            currencyType = currencyType,
            entity = entity,
            commit = function()
                impl.currency[currencyType] = impl.currency[currencyType] + amount
            end
        }
    )
end

function score_events.triggerEntity(entity)
    if World:getTileAt(entity.gridPosition):templateName() == "carpet" then
        score_events.addDudEvent(entity)
        return
    end

    local page = GET_ITEM_RULE_PAGE(entity:templateName())

    if page ~= nil then
        for _, rule in ipairs(page.rules) do
            rule.executeTrigger(rule, entity)
        end
    end
end

function score_events.payment()
    return missions.current().goldReward or 0
end

function score_events.targetScore()
    return missions.current().scoreObjective or 0
end

function score_events.addRegularScoreEvent(entity, amount)
    addScore(entity, amount, "normal")
end

function score_events.addMultiplierScoreEvent(entity, amount)
    addScore(entity, amount, "multiplier")
end

function score_events.addGoldEvent(entity, amount)
    addScore(entity, amount, "gold")
end

function score_events.addDudEvent(entity)
    impl.list:add(
        {
            type = "dud",
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            entity = entity
        }
    )
end

function score_events.addBeginRiseEvent(entity)
    impl.list:add(
        {
            type = "begin_rise",
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            entity = entity
        }
    )
end

function score_events.addKickerEvent(entity, text)
    impl.list:add(
        {
            type = "kicker",
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            entity = entity,

            text = text,
            color = "white"
        }
    )
end

function score_events.addEndRiseEvent(entity)
    impl.list:add(
        {
            type = "end_rise",
            worldPosition = Soko:toWorldPosition(entity.gridPosition),
            gridPosition = entity.gridPosition,
            entity = entity
        }
    )
end

function score_events.all()
    return impl.list
end

function score_events.clearEvents()
    impl.list:clear()
    impl.room = nil
    impl.currency = {
        normal = 0,
        gold = 0,
        rank = 0,
        multiplier = 1
    }
end

function score_events.setRoom(room)
    impl.room = room
end

function score_events.currentRoom()
    return impl.room
end

function score_events.currency()
    return impl.currency
end

function score_events.totalScore()
    return impl.currency.normal * impl.currency.multiplier
end

score_events.clearEvents()
return score_events
