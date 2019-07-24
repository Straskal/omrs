local graphics = require("milk.graphics")
local animator = require("animator")

local unpack = table.unpack
local drawx = graphics.drawx

return {
    image = graphics.new_image("assets/gos/omrs.png"),
    src = {0, 0, 32, 32},
    speed = 100,
    animationclips = {
        idle = {1, 2, 3, 4, 5, 6}
    },
    animator = animator({
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
    }),
    update = function(self, _, _, dt)
        self.src[1], self.src[2], self.src[3], self.src[4] = self.animator:update(dt)
    end,
    draw = function(self, _, level, _)
        local x, y = level.camera:transform_point(unpack(self.position))
        graphics.set_draw_color(1, 1, 1, 1)
        drawx(self.image, x, y, self.src[1], self.src[2], self.src[3], self.src[4], 1, 1, 0)
    end
}
