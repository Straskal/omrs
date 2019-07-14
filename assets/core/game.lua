local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local level = require("assets.core.level")
local bmfont = require("assets.utils.font")
local gui = require("assets.utils.gui")
local player = require("assets.player.player")
local edtmenu = require("assets.editor.menu")
local keys = keyboard.keys

local game = {}

_G.RESOLUTION = {w = 640, h = 360}

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)
    gui.init()

    -- open editor by default
    edtmenu.open()

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
    edtmenu.draw()
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
