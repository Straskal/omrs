local keyboard = require("milk.keyboard")
local gameobject = require("gameobject")
local animator = require("animator")
local levelstate = require("levelstate")

local keys = keyboard.keys

local function preload(level)
    level:preload("assets/gos/other.obj.lua")
    level.assets:load_image("assets/gos/omrs.png")
    level.assets:load_sound("assets/gos/beep.wav")
end

local function new()
    return gameobject.new(
        {
            image = nil,
            sound = nil,
            imagefile = "assets/gos/omrs.png",
            speed = 100,
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
            ),
            load = function(self)
                self.sound = self.level.assets:get("assets/gos/beep.wav")
                self.image = self.level.assets:get("assets/gos/omrs.png")
            end,
            update = function(self, dt)
                if keyboard.is_key_pressed(keys.SPACE) then
                    self.level.game:switch_state(levelstate("assets/levels/test.lvl.lua"))
                end
                if keyboard.is_key_pressed(keys.P) then
                    self.level:spawn(
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
                    self.level.bumpworld:move(
                    self,
                    self.position[1] + (self.speed * inputx) * dt,
                    self.position[2] + (self.speed * inputy) * dt
                )

                if len > 0 then
                    self.level:destroy(colls[1].other)
                end

                self.srcrect[1], self.srcrect[2], self.srcrect[3], self.srcrect[4] = self.animator:update(dt)
            end
        }
    )
end

return {
    preload = preload,
    new = new
}
