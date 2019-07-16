local graphics = require("milk.graphics")

local Camera = {}
Camera.__index = Camera

local function new()
    local self = {}
    self.positionx = 0
    self.positiony = 0
    self.zoom = 1
    setmetatable(self, Camera)
    return self
end

function Camera:move(x, y)
    self.positionx = x
    self.positiony = y
end

function Camera:zoom_in()
    self.zoom = self.zoom + 0.05
end

function Camera:zoom_out()
    self.zoom = self.zoom - 0.05
end

function Camera:draw(image, x, y)
    graphics.draw(image, self.positionx - x, self.positiony - y)
end

function Camera:drawx(image, x, y, srcx, srcy, srcw, srch)
    graphics.drawx(
        image,
        (x - self.positionx) * self.zoom,
        (y - self.positiony) * self.zoom,
        srcx,
        srcy,
        srcw,
        srch,
        self.zoom,
        self.zoom,
        0
    )
end

return {
    new = new
}
