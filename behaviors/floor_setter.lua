local floor_setter = {}

function floor_setter.onEnter(self, args)
    for i, tile in ipairs(World:getRoomAtGridPosition(self.gridPosition):allTiles()) do
        if tile:templateName() == "floor" then
            self.state["previous"] = tile.state["sheet"]
            self.state["tile"] = tile
            tile.state["sheet"] = self.state["sheet"]
            return
        end
    end
end

function floor_setter.onExit(self, args)
    if self.state["tile"] then
        self.state["tile"].state["sheet"] = self.state["previous"]
    end
end

return floor_setter
