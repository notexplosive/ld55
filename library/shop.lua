local run_context = require "library.run_context"
local draw_text   = require "library.draw_text"
local shop        = {}
local impl        = {}


function shop.placeOfferAt(gridPosition)
    local shopItem = World:spawnEntity(gridPosition, Soko.DIRECTION.NONE, "birthday_candle")
    shopItem.state["price"] = 5
    shopItem.state["behavior"] = "shop_item"
    shopItem.state["cannot_pick_up"] = true
end

function shop.spawnKicker(gridPosition, price)
    World:playAsyncAnimation(function(tween, params)
        local object = World:spawnObject(gridPosition)
        object.state["renderer"] = "lua"
        object.state["render_function"] = function(painter, drawArguments)
            painter:setColor("gold")
            painter:setFontSize(22)
            draw_text.draw(painter, drawArguments, price, Soko:worldPosition(0, 0))
        end
        object.state["layer"] = 5

        tween:interpolate(object.tweenablePosition:to(object.tweenablePosition:get() + Soko:worldPosition(0, -50)),
            0.25,
            "cubic_fast_slow")

        tween:wait(0.5)

        tween:callback(function()
            object:destroy()
        end)
    end, {})
end

function shop.attemptPurchase(shopItemEntity)
    local price = shopItemEntity.state["price"]
    if run_context.canAfford(price) then
        run_context.spend(price)
        shopItemEntity.state:clear("price")
        shopItemEntity.state:clear("behavior")
        shopItemEntity.state:clear("cannot_pick_up")

        shop.spawnKicker(shopItemEntity.gridPosition, price)
        return true
    end
    return false
end

return shop
