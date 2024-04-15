local run_context = require "library.run_context"
local dialogue = {}

function dialogue.show(baseSceneName)
    local hasShown = false

    local scenesToCheck = Soko:list()

    for i = run_context.getRankBracket(), 1, -1 do
        scenesToCheck:add(baseSceneName .. "_" .. i)
    end

    -- add an option for rank 0 (post tutorial)
    scenesToCheck:add(baseSceneName .. "_0")

    -- if we don't find any suffixed scenes, try the scene name itself
    scenesToCheck:add(baseSceneName)

    for i, sceneName in ipairs(scenesToCheck) do
        if World:checkDialogueExists(sceneName) then
            World:showSceneDialogue(sceneName)
            hasShown = true
            break
        end
    end

    if not hasShown then
        print("nothing to show for " .. baseSceneName)
    end
end

function dialogue.doBespokeDialogue(text_message, portrait_frame, actor_name, blip_sound)
    if blip_sound == nil then
        blip_sound = "default_blip"
    end
    if actor_name == nil then
        actor_name = "Player"
    end

    World:showBespokeDialogue(
        {
            whenDone = function()
                -- do something
            end,
            boxPlacement = "bottom",
            alignment = "center",
            pages = {
                {
                    portraitFrame = portrait_frame,
                    text = text_message,
                    blip = blip_sound,
                    name = actor_name,
                    portraitSide = "left"
                }
            }
        }
    )
end

return dialogue
