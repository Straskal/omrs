local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local gui = require("gui")

local format = string.format

local debugstate = {}

local function new(level)
    return setmetatable(
        {
            level = level,
            updatebelow = true,
            drawbelow = true,
            drawcolliders = true
        },
        {__index = debugstate}
    )
end

-- luacheck: push ignore
function debugstate:update(dt)
end
-- luacheck: pop

function debugstate:draw()
    if self.drawcolliders then
        graphics.set_draw_color(1, 0, 0, 0.2)
        local gos, len = self.level.bumpworld:getItems()
        for i = 1, len do
            local x, y, w, h = self.level.bumpworld:getRect(gos[i])
            graphics.draw_filled_rect(x, y, w, h)
        end
    end

    -- draw fps
    graphics.set_draw_color(1, 1, 1, 1)
    gui:label(430, 5, format("FPS: %.0f", self.level.game.fps))

    -- draw collider checkbox
    gui:label(410, 22, "colliders")
    gui:checkbox(1, self, "drawcolliders", 460, 20, 8, 8)

    -- draw hot obj position
    local msx, msy = mouse.get_position()
    local wmsx, wmsy = self.level.camera:screen2world(msx, msy)
    local objs, len = self.level.bumpworld:queryPoint(wmsx, wmsy)
    if len > 0 then
        gui:label(msx + 5, msy - 5, format("%.0f, %.0f", objs[1].position[1], objs[1].position[2]))
    end
end

return {
    new = new
}
