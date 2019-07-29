local animator = {}

local function new(config)
    return setmetatable(
        {
            framewidth = config.framewidth,
            frameheight = config.frameheight,
            rows = config.rows,
            columns = config.columns,
            secperframe = config.secperframe or 0.1,
            currentanim = config.initialanim,
            lastframetime = 0,
            currentframe = 1,
            time = 0
        },
        {__index = animator}
    )
end

function animator:set_animation(animation)
    if self.currentanim ~= animation then
        self.currentanim = animation
        self.currentframe = 1
    end
end

function animator:update(go, dt)
    self.time = self.time + dt
    if self.time - self.lastframetime > self.secperframe then
        self.currentframe = self.currentframe + 1
        if self.currentframe > #self.currentanim then
            self.currentframe = 1
        end
        self.lastframetime = self.time
    end

    local row = math.floor((self.currentanim[self.currentframe] - 1) / self.columns)
    local column = math.floor((self.currentanim[self.currentframe] - 1) % self.columns)

    go.srcrect[1], go.srcrect[2], go.srcrect[3], go.srcrect[4] =
        column * self.framewidth,
        row * self.frameheight,
        self.framewidth,
        self.frameheight
end

return {
    new = new
}
