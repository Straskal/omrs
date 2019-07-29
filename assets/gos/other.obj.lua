local graphics = require("milk.graphics")
local animator = require("animator")

local unpack = table.unpack
local drawx = graphics.drawx

local function preload(level)
    level.assets:load_sound("assets/gos/beep.wav")
    level.assets:load_image("assets/gos/omrs.png")
end

local function new()
    return {
        image = nil,
        beep = nil,
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
        load = function(self)
            self.image = self.level.assets:get("assets/gos/omrs.png")
            self.beep = self.level.assets:get("assets/gos/beep.wav")
        end,
        spawned = function(self)
            self.level.bumpworld:add(self, self.position[1], self.position[2], 28, 28)
            self.beep:play()
        end,
        update = function(self, dt)
            self.src[1], self.src[2], self.src[3], self.src[4] = self.animator:update(dt)
        end,
        draw = function(self, _)
            local x, y = self.level.camera:transform_point(unpack(self.position))
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
        destroyed = function(self)
            self.level.bumpworld:remove(self)
            self.beep:play()
        end
    }
end

return {
    preload = preload,
    new = new
}
