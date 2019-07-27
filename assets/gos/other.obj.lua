local graphics = require("milk.graphics")
local animator = require("animator")

local unpack = table.unpack
local drawx = graphics.drawx

local function preload(level)
    level.assets:load_sound("assets/gos/beep.wav")
    level.assets:load_image("assets/gos/omrs.png")
end

local function new(level)
    return {
        image = level.assets:get("assets/gos/omrs.png"),
        beep = level.assets:get("assets/gos/beep.wav"),
        src = {0, 0, 32, 32},
        boop = nil,
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
        spawned = function(self, _, _)
            level.bumpworld:add(self, self.position[1], self.position[2], 28, 28)
            self.beep:play()
        end,
        update = function(self, _, _, dt)
            self.src[1], self.src[2], self.src[3], self.src[4] = self.animator:update(dt)
        end,
        draw = function(self, _, _, _)
            local x, y = level.camera:transform_point(unpack(self.position))
            graphics.set_draw_color(1, 1, 1, 1)
            drawx(
                self.image,
                x - (self.src[3] / 2),
                y - (self.src[4] / 2),
                self.src[1],
                self.src[2],
                self.src[3],
                self.src[4],
                1,
                1,
                0
            )
        end,
        destroyed = function(self, _, _)
            level.bumpworld:remove(self)
            self.beep:play()
        end
    }
end

return {
    preload = preload,
    new = new
}
