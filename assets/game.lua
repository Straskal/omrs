local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local player = require("assets.player")
local keys = keyboard.keys

local game = {}

_G.RESOLUTION = {w = 256, h = 144}

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)

    player:spawned()
end

function game:tick(dt)
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    player:tick(dt)
end

function game:draw(dt)
   player:draw(dt)
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
