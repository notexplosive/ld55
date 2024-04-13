local dialogue = require("library/dialogue")
local exports = {}

local function doSpeak(self, other)
    if not other.state:has("actor_key") then
        return
    end

    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local dialogueKey = other.state:get("actor_key")
    local shouldShow = dialogueKey ~= nil and (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"

    if shouldShow then
        dialogue.show(baseSceneName, other.state:get("actor_key"))
    end

    self.state:set("is_complete", true)
end

function exports.onEnter(self)
    print("Entered!")
    self.state:set("is_complete", false)
end

function exports.onTouched(self, params)
    print("Touched!")
    local move = params.move
    local other = move:movingEntity()
    doSpeak(self, other)
end

function exports.onSpeak(self, params)
    local other = params.speaker
    doSpeak(self, other)
end

-- Example, not actually used
local function doBespokeDialogue()
    World:showBespokeDialogue(
        {
            boxPlacement = "bottom",
            alignment = "center",
            whenDone = function()
                -- when dialogue is done
            end,
            pages = {
                {
                    portraitFrame = 6,
                    text = "[color(179cfe)]Howdy.[/color]",
                    blip = "default_blip",
                    name = "Player",
                    portraitSide = "left"
                }
            }
        }
    )
end

return exports
