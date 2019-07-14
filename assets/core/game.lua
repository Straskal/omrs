local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local gui = require("assets.utils.gui")
local playstate = require("assets.core.playstate")
local keys = keyboard.keys

_G.RESOLUTION = {w = 640, h = 360}

local game = {
    state_stack = {}
}

function game:push_state(state)
    table.insert(self.state_stack, state)
    state:enter()
end

function game:pop_state()
    self.state_stack[#self.state_stack]:exit()
    table.remove(self.state_stack)
end

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(_G.RESOLUTION.w, _G.RESOLUTION.h)
    gui.init()

    self:push_state(playstate.new())
end

function game:tick(dt)
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    self.state_stack[#self.state_stack]:tick(self, dt)
end

function game:draw(dt)
    for i = 1, #self.state_stack do
        self.state_stack[i]:draw(self, dt)
    end
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
