local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local keys = keyboard.keys

local unpack = table.unpack
local drawx = graphics.drawx

return {
    image = graphics.new_image("assets/gos/omrs.png"),
    src = {0, 0, 32, 32},
    layer = 1,
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
    end,
    draw = function(self, camera, _)
        local x, y = camera:transform_point(unpack(self.position))
        graphics.set_draw_color(1, 1, 1, 1)
        drawx(self.image, x, y, self.src[1], self.src[2], self.src[3], self.src[4], 1, 1, 0)
    end
}
