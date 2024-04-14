local dialogue = require("library/dialogue")
local player = require "library.player"
local exports = {}

local function doCheckItem(self)
    if not self.state:has("search_chance") then
        return
    end
    if not self.state:has("item_list") then
        return
    end

    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local shouldShow = (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"
    local search_chance = self.state:get("search_chance")
    local item_list = self.state:get("item_list")

    if shouldShow then
        local rand = math.random(1, 100)
        if rand <= search_chance then
            local length = #item_list
            local item_found = item_list[math.random(1, length)]
            dialogue.doBespokeDialogue("I found " .. item_found .. "!", 2)
            local new_item = World:spawnEntity(player.instance().gridPosition, Soko.DIRECTION.NONE, item_found)
            player.pickUpItem(new_item)
        else
            dialogue.doBespokeDialogue("Didn't find anything of interest.", 1)
        end
    end

    self.state:set("is_complete", true)

end



function exports.onEnter(self)
    --  do nothing
end

function exports.onActivate(self, params)
    doCheckItem(self)
end

function exports.onSpeak(self, params)
    doCheckItem(self)
end

return exports
