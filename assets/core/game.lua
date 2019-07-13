local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local level = require("assets.core.level")
local bmfont = require("assets.utils.font")
local player = require("assets.player.player")
local keys = keyboard.keys

local game = {}

_G.RESOLUTION = {w = 640, h = 360}

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)
    self.level = level.new()
    self.level:spawn(player)
    local image = graphics.new_image("assets/utils/font.png")
    self.font = bmfont.new_font(image, -11, -3, 0.5)
end

function game:tick(dt)
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    self.level:tick(dt)
end

function game:draw(dt)
    self.level:draw(dt)
    graphics.set_draw_color(0.5, 0.5, 0.5, 1)
    graphics.draw_rect((640 / 2) - (240 / 2), 360 - 120, 240, 100)
    graphics.set_draw_color(1, 1, 1, 1)
    self.font:print(
        (640 / 2) - (240 / 2) + 10,
        (360 - 120) + 10,
        "You have picked up a [item] plank [defcolor] [+] !",
        21
    )
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
