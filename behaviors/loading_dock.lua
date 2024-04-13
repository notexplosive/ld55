local loading_dock = {}

function loading_dock.onEnter(self, args)
    for xOffset = 1, self.state["zone_width"] do
        for yOffset = 1, self.state["zone_height"] do
            World:setTileAt(self.gridPosition + Soko:gridPosition(xOffset, yOffset), "loading_dock_floor")
        end
    end
end

return loading_dock
