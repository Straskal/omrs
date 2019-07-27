local animator = {}

local function new(config)
    return setmetatable({
        frame_width = config.frame_width,
        frame_height = config.frame_height,
        rows = config.rows,
        columns = config.columns,
        seconds_per_frame = config.seconds_per_frame or 0.1,
        current_anim = config.initial_anim,
        last_anim_time = 0,
        current_anim_frame = 1,
        accumulated_time = 0,
        time = 0
    }, { __index = animator })
end

function animator:set_animation(animation)
    if self.current_anim ~= animation then
        self.current_anim = animation
        self.current_anim_frame = 1
    end
end

function animator:update(dt)
    self.time = self.time + dt
    if self.time - self.last_anim_time > self.seconds_per_frame then
        self.current_anim_frame = self.current_anim_frame + 1
        if self.current_anim_frame > #self.current_anim then
            self.current_anim_frame = 1
        end
        self.last_anim_time = self.time
    end
    local row = math.floor((self.current_anim[self.current_anim_frame] - 1) / self.columns)
    local column = math.floor((self.current_anim[self.current_anim_frame] - 1) % self.columns)
    local src_x = column * self.frame_width
    local src_y = row * self.frame_height
    return src_x, src_y, self.frame_width, self.frame_height
end

return {
    new = new
}
