local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local levelstate = require("levelstate")
local gui = require("gui")
local keys = keyboard.keys

local unpack = table.unpack
local format = string.format

local game = {
    statestack = {},
    framestart = 0,
    fps = 0,
    bgcolor = {0, 0, 0, 1}
}

function game:push_state(state)
    table.insert(self.statestack, state)
    if state.enter then
        state:enter(self)
    end
end

function game:pop_state()
    local len = #self.statestack
    if len > 0 and self.statestack[len].exit then
        self.statestack[#self.statestack]:exit(self)
    end
    table.remove(self.statestack)
end

function game:switch_state(state)
    while #self.statestack > 0 do
        self:pop_state()
    end
    self:push_state(state)
end

function game:start()
    window.set_title("Old Man Rage Strength")
    window.set_size(1280, 720)
    graphics.set_resolution(480, 272)

    gui:init()

    self:push_state(levelstate("assets/levels/test.lvl.lua"))
end

function game:update(dt)
    -- for development ----------------------------------
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end
    -----------------------------------------------------

    -- attempt to tick all states from top to bottom
    for i = #self.statestack, 1, -1 do
        self.statestack[i]:update(self, dt)
        if not self.statestack[i].update_below then
            break
        end
    end
end

function game:draw(dt)
    graphics.set_draw_color(unpack(self.bgcolor))
    graphics.clear()
    gui:begin_draw()
    -- attempt to draw all states from bottom to top
    local len = #self.statestack
    for i = 1, len do
        local above = self.statestack[i + 1]
        if (not above) or above.draw_below then
            self.statestack[i]:draw(self, dt)
        end
    end
    -- draw fps
    gui:label(430, 5, format("FPS: %.0f", game.fps))
    gui:end_draw()
    graphics.present()
end

return game
