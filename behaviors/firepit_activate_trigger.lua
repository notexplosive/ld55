local dialogue = require("library/dialogue")
local player = require "library.player"
local exports = {}

local function doCheckItem(self)
    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local shouldShow = (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"


    if shouldShow then
        local rand = math.random(1, 100)
        if rand > 50 then
            dialogue.doBespokeDialogue("I found some coal. Neat.", 1)
            local coal = World:spawnEntity(player.instance().gridPosition, Soko.DIRECTION.NONE, "coal")
            player.pickUpItem(coal)
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
