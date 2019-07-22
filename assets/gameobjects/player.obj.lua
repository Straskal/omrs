local keyboard = require("milk.keyboard")
local keys = keyboard.keys

return {
    image = {
        file = "assets/gameobjects/omrs.png",
        src = {0, 0, 32, 32},
        layer = 1
    },
    animation = {
        framewidth = 32,
        frameheight = 32,
        rows = 2,
        columns = 4,
        clips = {
            idle = {1, 2, 3, 4, 5, 6}
        },
        current_clip = "idle"
    },
    speed = 100,
    update = function(self, dt)
        if keyboard.is_key_down(keys.W) then
            self.position[2] = self.position[2] - self.speed * dt
        end
        if keyboard.is_key_down(keys.A) then
            self.position[1] = self.position[1] - self.speed * dt
        end
        if keyboard.is_key_down(keys.S) then
            self.position[2] = self.position[2] + self.speed * dt
        end
        if keyboard.is_key_down(keys.D) then
            self.position[1] = self.position[1] + self.speed * dt
        end
    end
}