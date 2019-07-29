local keyboard = require("milk.keyboard")
local gameobject = require("gameobject")
local animator = require("animator")
local levelstate = require("levelstate")

local keys = keyboard.keys

local function preload(level)
    level.assets:load_image("assets/gos/omrs.png")
    level.assets:load_sound("assets/gos/beep.wav")
end

local function new()
    return gameobject.new(
        {
            speed = 75,
            animator = animator.new(
                {
                    framewidth = 32,
                    frameheight = 32,
                    rows = 2,
                    columns = 4,
                    secperframe = 0.1,
                    initialanim = {1, 2, 3, 4, 5, 6}
                }
            ),
            onload = function(self)
                self.sound = self.level.assets:get("assets/gos/beep.wav")
                self.image = self.level.assets:get("assets/gos/omrs.png")
            end,
            onupdate = function(self, dt)
                if keyboard.is_key_pressed(keys.SPACE) then
                    self.level.game:switch_state(levelstate("assets/levels/test.lvl.lua"))
                end
                if keyboard.is_key_pressed(keys.P) then
                    self.sound:play()
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

                local coll = self:moveandcollide((self.speed * inputx) * dt, (self.speed * inputy) * dt)
                if coll then
                    print("collision!")
                end

                self.animator:update(self, dt)
            end
        }
    )
end

return {
    preload = preload,
    new = new
}
