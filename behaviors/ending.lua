local ending = {}

function ending.onEnter(self, args)
    World:playAnimation(function(tween)
        tween:wait(3)
        tween:callback(function()
            World:showSceneDialogue("ending")
        end)
    end, {})
end

return ending
