local dialogue = require("library/dialogue")
local exports = {}

local function doSpeak(self)
    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local shouldShow = (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"

    if shouldShow then
        dialogue.show(baseSceneName)
    end

    self.state:set("is_complete", true)
end

function exports.onEnter(self)
    self.state:set("is_complete", false)
end

function exports.onActivate(self, params)
    doSpeak(self)
end

function exports.onSpeak(self, params)
    doSpeak(self)
end

return exports
