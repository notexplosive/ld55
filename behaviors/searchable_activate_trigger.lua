local dialogue = require("library/dialogue")
local player = require "library.player"
local items = require "library.items"
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

            local item_name = item_found
            local rulePage = items[item_found]
            if rulePage then
                item_name = rulePage.getTitle()
            end

            dialogue.doBespokeDialogue("I found " .. item_name .. "!", 2)
            local new_item = World:spawnEntity(player.instance().gridPosition, Soko.DIRECTION.NONE, item_found)
            player.pickUpItem(new_item)
        end
    end

    if self.state:has("opened_frame") then
        self.state:set("frame", self.state:get("opened_frame"))
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
