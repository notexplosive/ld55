local dialogue = require "library.dialogue"
local player   = require "library.player"
local missions = require "library.missions"
local tutorial = {}

local function talk()
    local itemName = player.heldItemName() or "none"
    dialogue.show("tutorial_item_" .. itemName)
end

function tutorial.onActivate(self, args)
    talk()
end

function tutorial.onFailDrop(self, args)
    talk()
end

function tutorial.onEnter(self, args)
    if World.levelState["has_failed"] then
        dialogue.show("tutorial_fail")
        World.levelState["has_failed"] = false
    end

    missions.setCurrent({
        title = "Tutorial Mission",
        description = "Learning the ropes",
        scoreObjective = 210,
        rankReward = 0, -- you're still rank 0 after finishing the tutorial
        goldReward = 5,
    })
end

return tutorial
