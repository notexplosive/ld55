local draw_text = {}

function draw_text.draw(painter, drawArguments, text, offset, angle)
    local bounds = painter:measureText(text, nil)
    local basePos = drawArguments.worldPosition - Soko:worldPosition(bounds.width, bounds.height) / 2
    local finalPos = basePos + offset
    painter:drawText(text, finalPos, nil, angle or 0, true)

    bounds.x = finalPos.x
    bounds.y = finalPos.y
    return bounds
end

return draw_text
