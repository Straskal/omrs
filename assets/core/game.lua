local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local level = require("assets.core.level")
local gui = require("assets.utils.gui")
local player = require("assets.player.player")
local edtmenu = require("assets.editor.menu")
local keys = keyboard.keys

_G.RESOLUTION = {w = 640, h = 360}

local game = {}

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)
    gui.init()

    self.level = level.new()
    self.level:spawn(player)
end

function game:tick(dt)
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    if keyboard.is_key_released(keys.TILDE) then
        edtmenu.toggle()
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
