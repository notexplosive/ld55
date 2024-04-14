local dialogue = require("library/dialogue")
local exports = {}

local function doCheckItem(self)
    local hasDone = self.state:get("is_complete")
    local isOneOff = self.state:get("one_off")
    local shouldShow = (isOneOff and not hasDone) or (not isOneOff)
    local baseSceneName = self.state:get("scene") or "default"

    local function doBespokeDialogue(text_message, player_frame)
        World:showBespokeDialogue(
            {
                whenDone = function()
                    -- when dialogue is done
                end,
                boxPlacement = "bottom",
                alignment = "center",
                pages = {
                    {
                        portraitFrame = player_frame,
                        text = text_message,
                        blip = "default_blip",
                        name = "Player",
                        portraitSide = "left"
                    }
                }
            }
        )
    end

    if shouldShow then
        local rand = math.random(1, 100)
        if rand > 90 then
            dialogue.show("I found some Coal.", 0)
        else
            doBespokeDialogue("Nothing to find", 1)
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
