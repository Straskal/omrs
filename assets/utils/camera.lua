local graphics = require("milk.graphics")
local matrix = require("thirdparty.matrix")

local Camera = {}
Camera.__index = Camera

local function new()
    local instance = {
        tranmatrix = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
        position = {0, 0},
        zoom = 1
    }
    setmetatable(instance, Camera)
    return instance
end

function Camera:move(x, y)
    self.position[1] = self.position[1] + x
    self.position[2] = self.position[2] + y
end

function Camera:zoom_in(amount)
    local zoom = self.zoom + amount
    if zoom < 5 then
        self.zoom = zoom
    end
end

function Camera:zoom_out(amount)
    local zoom = self.zoom - amount
    if zoom > 0.25 then
        self.zoom = zoom
    end
end

function Camera:screen2world(x, y)
    local inv = matrix.invert(self.tranmatrix)
    local posvec = inv:mul({{x},{y},{1}})
    return posvec[1][1], posvec[2][1]
end

function Camera:calc_matrix()
    local postranslation = matrix({{1, 0, -self.position[1]}, {0, 1, -self.position[2]}, {0, 0, 1}})
    local zoomscale = matrix({{self.zoom, 0, 0}, {0, self.zoom, 0}, {0, 0, 1}})
    local vptranslation = matrix({{1, 0, 640 * 0.5}, {0, 1, 360 * 0.5}, {0, 0, 1}})
    self.tranmatrix = vptranslation * zoomscale * postranslation
end

function Camera:draw(image, x, y, srcx, srcy, srcw, srch)
    local vec = self.tranmatrix:mul(matrix({x, y, 1}))
    graphics.drawx(image, vec[1][1], vec[2][1], srcx, srcy, srcw, srch, self.zoom, self.zoom, 0)
end

function Camera:draw_rect(x, y, w, h)
    local vec = self.tranmatrix:mul(matrix({x, y, 1}))
    graphics.draw_rect(vec[1][1], vec[2][1], w * self.zoom, h * self.zoom)
end

function Camera:draw_filled_rect(x, y, w, h)
    local vec = self.tranmatrix:mul(matrix({x, y, 1}))
    graphics.draw_filled_rect(vec[1][1], vec[2][1], w * self.zoom, h * self.zoom)
end

return {
    new = new
}
