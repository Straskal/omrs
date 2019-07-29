local gameobject = require("gameobject")
local animator = require("animator")

local function preload(level)
    level.assets:load_image("assets/gos/omrs.png")
    level.assets:load_sound("assets/gos/beep.wav")
end

local function new()
    return gameobject.new(
        {
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
            onspawn = function(self)
                self.sound:play()
            end,
            onupdate = function(self, dt)
                self.animator:update(self, dt)
            end,
            ondestroy = function(self)
                self.sound:play()
            end,
        }
    )
end

return {
    preload = preload,
    new = new
}
