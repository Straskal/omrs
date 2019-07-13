local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local player = require("assets.player")
local level = require("assets.level")
local bmfont = require("assets.bmfont")
local keys = keyboard.keys

local game = {}

_G.RESOLUTION = {w = 640, h = 360}

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)
    self.level = level.new()
    self.level:spawn(player)
    self.font = bmfont.new_font("assets/font.png")
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
    bmfont.printx(self.font, 100, 100, "Hello there, big boiz", -10, 0.5)
    bmfont.printx(self.font, 100, 140, "zebras are dope as shit quite", -10, 0.5)
    bmfont.printx(self.font, 100, 180, "Hello there, big boiz", -10, 0.5)
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
