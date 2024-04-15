local bone_door = {}

function bone_door.onTrigger(self, args)
    if args.name == self.state["trigger"] then
        self:destroy()

        local prop = self.state["prop"]
        prop:destroy()

        --[[

        World:playAsyncAnimation(function(tween)
            tween:interpolate(prop.tweenablePosition:to(prop.tweenablePosition:get() + Soko:worldPosition(0, -500)), 1,
                "cubic_slow_fast")
            tween:callback(function()
            end)
        end, {})

        ]]
    end
end

return bone_door
