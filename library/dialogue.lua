local dialogue = {}

function dialogue.show(baseSceneName, dialogueKey)
    local characterSpecificSceneName = baseSceneName .. "_" .. dialogueKey

    local sceneNames = { characterSpecificSceneName, baseSceneName }

    local hasShown = false
    for i, sceneName in ipairs(sceneNames) do
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

return dialogue
