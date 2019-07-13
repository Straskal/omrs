local animator = {}
local Animator_mt = {}

function Animator_mt:configure(config)
    self.frame_width = config.frame_width
    self.frame_height = config.frame_height
    self.rows = config.rows
    self.columns = config.columns
    self.seconds_per_frame = config.seconds_per_frame or 0.1
    self.current_anim = config.initial_anim
    self.last_anim_time = 0
    self.current_anim_frame = 1
    self.accumulated_time = 0
    self.time = 0
end

function Animator_mt:set_animation(animation)
    if self.current_anim ~= animation then
        self.current_anim = animation
        self.current_anim_frame = 1
    end
end

function Animator_mt:tick(dt)
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

function animator.new(config)
    local self = {}
    setmetatable(self, { __index = Animator_mt })
    self:configure(config)
    return self
end

return animator