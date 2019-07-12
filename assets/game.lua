local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local keys = keyboard.keys

local game = {}

local RESOLUTION = {w = 256, h = 144}
local PLAYER_SPEED = 50

function game:start()
    window.set_size(1280, 720)
    graphics.set_resolution(RESOLUTION.w, RESOLUTION.h)

    self.player_img = graphics.new_image("assets/omrs.png")
    local w, h = self.player_img:get_size()
    self.player_size = {w = w * 0.5, h = h * 0.5}
    self.player_pos = {x = 100, y = 100}
end

function game:tick(dt)
    if keyboard.is_key_released(keys.ESCAPE) then
        window.close()
    end
    if keyboard.is_key_released(keys.F) then
        window.set_fullscreen(not window.is_fullscreen())
    end

    if keyboard.is_key_down(keys.W) then
        self.player_pos.y = self.player_pos.y - PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.A) then
        self.player_pos.x = self.player_pos.x - PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.S) then
        self.player_pos.y = self.player_pos.y + PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.D) then
        self.player_pos.x = self.player_pos.x + PLAYER_SPEED * dt
    end

    self.player_pos.x = math.max(0 + 16, math.min(self.player_pos.x, RESOLUTION.w - 16))
    self.player_pos.y = math.max(0 + 16, math.min(self.player_pos.y, RESOLUTION.h - 16))
end

-- luacheck: push ignore dt
function game:draw(dt)
    local x = self.player_pos.x - 16
    local y = self.player_pos.y - 16
    graphics.drawx(self.player_img, x, y, 0, 0, 32, 32, 1, 1, 0)
end
-- luacheck: pop

-- luacheck: push ignore self
function game:stop()
end
-- luacheck: pop

return game
