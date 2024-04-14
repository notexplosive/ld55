local player = require "library.player"
local spell_book_ui = require "library.spell_book_ui"
local spell_book = {}

function spell_book.onTouched(self, args)
    player.setUI(spell_book_ui.create(self))
    self.state["pose"] = "open"
end

return spell_book
