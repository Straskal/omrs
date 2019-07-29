local graphics = require("milk.graphics")
local gui = require("gui")

local format = string.format

local debugstate = {}

local function new(level)
    return setmetatable(
        {
            level = level,
            updatebelow = true,
            drawbelow = true
        },
        {__index = debugstate}
    )
end

-- luacheck: push ignore
function debugstate:update(dt)
end
-- luacheck: pop

function debugstate:draw()
    -- draw colliders
    graphics.set_draw_color(1, 0, 0, 0.2)
    local gos, len = self.level.bumpworld:getItems()
    for i = 1, len do
        local x, y, w, h = self.level.bumpworld:getRect(gos[i])
        graphics.draw_filled_rect(x, y, w, h)
    end

    -- draw fps
    graphics.set_draw_color(1, 1, 1, 1)
    gui:label(430, 5, format("FPS: %.0f", self.level.game.fps))
end

return {
    new = new
}
