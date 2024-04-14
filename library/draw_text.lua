local score_events = require "library.score_events"
local draw_text = {}

function draw_text.draw(painter, drawArguments, text, offset, angle, restrictWidth)
    local bounds = painter:measureText(text, restrictWidth)
    local basePos = drawArguments.worldPosition - Soko:worldPosition(bounds.width, bounds.height) / 2
    local finalPos = basePos + offset
    painter:drawText(text, finalPos, restrictWidth, angle or 0, true)

    bounds.x = finalPos.x
    bounds.y = finalPos.y
    return bounds
end

function draw_text.scoreCounter(painter, drawArguments, title, text)
    painter:setFontSize(20)
    draw_text.draw(painter, drawArguments, title, Soko:worldPosition(0, -80 / 2 - 10), 0)
    painter:setFontSize(80)
    draw_text.draw(painter, drawArguments, tostring(text),
        Soko:worldPosition(0, 0), 0)
end

return draw_text
