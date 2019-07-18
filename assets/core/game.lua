local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local gui = require("utils.gui")
local editstate = require("editor.editstate")
local keys = keyboard.keys

local game = {
    state_stack = {}
}

function game:push_state(state)
    table.insert(self.state_stack, state)
    if state.on_enter then
        state:on_enter(self)
    end
end

function game:pop_state()
    local len = #self.state_stack
    if len > 0 and self.state_stack[len].on_exit then
        self.state_stack[#self.state_stack]:on_exit(self)
        table.remove(self.state_stack)
    end
end

function game:switch_state(state)
    while #self.state_stack > 0 do
        self:pop_state()
    end
    self:push_state(state)
end

function game:start()
    window.set_title("Old Man Rage Strength")
    window.set_size(1280, 720)
    graphics.set_resolution(640, 360)

    gui:init()

    self:push_state(editstate)
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

    -- attempt to tick all states from top to bottom
    for i = #self.state_stack, 1, -1 do
        self.state_stack[i]:on_tick(self, dt)
        if not self.state_stack[i].update_below then
            break
        end
    end
end

function game:draw(dt)
    -- attempt to draw all states from bottom to top
    local len = #self.state_stack
    for i = 1, len do
        local above = self.state_stack[i + 1]
        if (not above) or above.draw_below then
            self.state_stack[i]:on_draw(self, dt)
        end
    end
end

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
