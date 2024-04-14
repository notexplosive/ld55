local dialogue = {}

function dialogue.show(baseSceneName)
    local hasShown = false
    if World:checkDialogueExists(baseSceneName) then
        World:showSceneDialogue(baseSceneName)
        hasShown = true
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
