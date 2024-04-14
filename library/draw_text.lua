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

return draw_text
