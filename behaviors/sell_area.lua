local items       = require "library.items"
local shop        = require "library.shop"
local run_context = require "library.run_context"
local sell_area   = {}

function sell_area.itemDropped(self, args)
    local item = args.item

    local rulePage = items[item:templateName()]

    if rulePage then
        local amount = math.floor(rulePage.cost() * 0.8)
        shop.spawnKicker(self.gridPosition, amount)
        run_context.gainGold(amount)
        args.item:destroy()
    end
end

return sell_area
