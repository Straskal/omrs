local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local gui = require("utils.gui")
local gameplay = require("gameplay.gameplay")
local keys = keyboard.keys

local game = {
    currentstate = {},
    framestart = 0,
    fps = 0
}

function game:switch_state(state)
    if self.currentstate.on_exit then
        self.currentstate:on_exit(self)
    end
    self.currentstate = state
    if self.currentstate.on_enter then
        self.currentstate:on_enter(self)
    end
end

function game:load_level(levelfile)
    self:switch_state(gameplay.new(levelfile))
end

function game:start()
    window.set_title("Old Man Rage Strength")
    window.set_size(1280, 720)
    graphics.set_resolution(640, 360)

    gui:init()

    self:load_level("assets/core/test.lvl.lua")
end

function game:tick(dt)
    -- for development ----------------------------------
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    -----------------------------------------------------

    self.currentstate:on_tick(self, dt)
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
