local draw_text = require "library.draw_text"
return function(painter, drawArguments)
    painter:setFontSize(drawArguments.state["size"] or 20)
    draw_text.draw(painter, drawArguments, drawArguments.state["text"], Soko:worldPosition(0, 0), 0)
end
