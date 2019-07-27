local keyboard = require("milk.keyboard")
local sprite = require("sprite")
local animator = require("animator")
local levelstate = require("levelstate")

local keys = keyboard.keys

local function preload(level)
    level:preload("assets/gos/other.obj.lua")
    level.assets:load_image("assets/gos/omrs.png")
end

local player = {}

local function new()
    return setmetatable(
        {
            image = nil,
            src = {0, 0, 0, 0},
            speed = 100,
            sprite = sprite.new(),
            animationclips = {
                idle = {1, 2, 3, 4, 5, 6}
            },
            animator = animator.new(
                {
                    frame_width = 32,
                    frame_height = 32,
                    rows = 2,
                    columns = 4,
                    seconds_per_frame = 0.1,
                    initial_anim = {1, 2, 3, 4, 5, 6},
                    last_anim_time = 0,
                    current_anim_frame = 1,
                    accumulated_time = 0,
                    time = 0
                }
            )
        },
        {__index = player}
    )
end

function player:load(_, level)
    self.image = level.assets:get("assets/gos/omrs.png")
end

function player:spawned(_, level)
    level.bumpworld:add(self, self.position[1], self.position[2], 28, 32)
end

function player:update(game, level, dt)
    if keyboard.is_key_pressed(keys.SPACE) then
        game:switch_state(levelstate("assets/levels/test.lvl.lua"))
    end
    if keyboard.is_key_pressed(keys.P) then
        level:spawn(
            "assets/gos/other.obj.lua",
            {
                position = {self.position[1] + 50, self.position[2] + 50},
                speed = 2
            }
        )
    end

    local inputx, inputy = 0, 0
    if keyboard.is_key_down(keys.W) then
        inputy = -1
    end
    if keyboard.is_key_down(keys.A) then
        inputx = -1
    end
    if keyboard.is_key_down(keys.S) then
        inputy = 1
    end
    if keyboard.is_key_down(keys.D) then
        inputx = 1
    end

    local colls, len
    self.position[1], self.position[2], colls, len =
        level.bumpworld:move(
        self,
        self.position[1] + (self.speed * inputx) * dt,
        self.position[2] + (self.speed * inputy) * dt
    )

    if len > 0 then
        level:destroy(colls[1].other)
    end

    self.src[1], self.src[2], self.src[3], self.src[4] = self.animator:update(dt)
end

function player:draw(_, level, _)
    self.sprite:draw(self, level.camera)
end

function player:destroyed(_, level)
    level.bumpworld:remove(self)
end

return {
    preload = preload,
    new = new
}
