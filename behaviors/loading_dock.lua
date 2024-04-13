local loading_dock = {}

function loading_dock.onEnter(self, args)
    for xOffset = 0, self.state["zone_width"] - 1 do
        for yOffset = 0, self.state["zone_height"] - 1 do
            World:setTileAt(self.gridPosition + Soko:gridPosition(xOffset, yOffset), "loading_dock_floor")
        end
    end
end

return loading_dock
