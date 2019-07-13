local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local gameobject = require("assets.gameobject")
local animator = require("assets.animator")
local keys = keyboard.keys

local player = gameobject.new("RADINALD", {x = 32, y = 32})

local PLAYER_SPEED = 50

function player:spawned()
    self.image = graphics.new_image("assets/omrs.png")
    self.animations = {
        idle = {1, 2, 3, 4, 5, 6}
    }
    self.animator = animator.new({
        frame_width = 32,
        frame_height = 32,
        rows = 2,
        columns = 4,
        initial_anim = self.animations.idle
    })
end

function player:tick(dt)
    if keyboard.is_key_down(keys.W) then
        self.position.y = self.position.y - PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.A) then
        self.position.x = self.position.x - PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.S) then
        self.position.y = self.position.y + PLAYER_SPEED * dt
    end
    if keyboard.is_key_down(keys.D) then
        self.position.x = self.position.x + PLAYER_SPEED * dt
    end

    self.position.x = math.max(0 + 16, math.min(self.position.x, _G.RESOLUTION.w - 16))
    self.position.y = math.max(0 + 16, math.min(self.position.y, _G.RESOLUTION.h - 16))
end

function player:draw(dt)
    local x = self.position.x - 16
    local y = self.position.y - 16
    local srcx, srcy, srcw, srch = self.animator:tick(dt)
    graphics.drawx(self.image, x, y, srcx, srcy, srcw, srch, 2, 2, 0)
end

return player
