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

return dialogue
