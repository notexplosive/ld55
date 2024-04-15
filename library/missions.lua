local missions = {}
local currentContent = nil

function missions.setup(entity)
    local difficulty = entity.state["mission"]

    local result = {}
    result.title = "???"
    result.description = "???"
    result.scoreObjective = 0
    result.rankReward = 0
    result.goldReward = 0

    if difficulty == "easy" then
        result.title = "Easy Mission"
        result.description = "An easy, but low paying mission."
        result.scoreObjective = 100
        result.rankReward = 1
        result.goldReward = 5
    elseif difficulty == "medium" then
        result.title = "Medium Mission"
        result.description = "An medium difficulty mission, with decent reward."
        result.scoreObjective = 200
        result.rankReward = 2
        result.goldReward = 12
    elseif difficulty == "hard" then
        result.title = "Hard Mission"
        result.description = "A difficult mission that pays well."
        result.scoreObjective = 400
        result.rankReward = 4
        result.goldReward = 20
    end

    entity.state["mission_content"] = result
end

function missions.setCurrent(missionContent)
    currentContent = missionContent
end

function missions.hasCurrentContent()
    return currentContent ~= nil
end

function missions.current()
    return currentContent or {}
end

function missions.clearContent()
    currentContent = nil
end

return missions
