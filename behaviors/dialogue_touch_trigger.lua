local dialogue = require("library/dialogue")
local exports = {}

local function doSpeak(self, other)
    if not other.state:has("actor_key") then
        return
    end

    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local shouldShow = (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"

    if shouldShow then
        dialogue.show(baseSceneName)
        if self.state["trigger"] then
            World:raiseEntityEvent("onTrigger", { name = self.state["trigger"] })
        end
    end

    self.state:set("is_complete", true)
end

function exports.onEnter(self)
    self.state:set("is_complete", false)
end

function exports.onTouched(self, params)
    local move = params.move
    local other = move:movingEntity()
    doSpeak(self, other)
end

function exports.onSpeak(self, params)
    local other = params.speaker
    doSpeak(self, other)
end

return exports
