local matrix = require("thirdparty.matrix")

local Camera = {}
Camera.__index = Camera

local function new()
    local instance = {
        matrix = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
        -- cache these so we aren't creating massive matrices all of the time
        invmatrix = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
        translation = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
        view_translation = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
        scale = matrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}),
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
    if zoom < 3 then
        self.zoom = zoom
    end
end

function Camera:zoom_out(amount)
    local zoom = self.zoom - amount
    if zoom > 0.25 then
        self.zoom = zoom
    end
end

function Camera:get_zoom_percentage()
    return (self.zoom / 3.75) * 375
end

function Camera:calc_matrix()
    self.translation[1][3] = -self.position[1]
    self.translation[2][3] = -self.position[2]
    self.scale[1][1] = self.zoom
    self.scale[2][2] = self.zoom
    self.view_translation[1][3] = 640 * 0.5
    self.view_translation[2][3] = 360 * 0.5

    self.matrix = self.view_translation * self.scale * self.translation
    self.invmatrix = self.matrix:invert()
end

-- so we don't have to create one every frame
local m = matrix({0, 0, 1})

function Camera:screen2world(x, y)
    m[1][1], m[2][1] = x, y
    matrix.multiply(self.invmatrix, m)
    return m[1][1], m[2][1]
end

function Camera:transform_point(x, y)
    m[1][1], m[2][1] = x, y
    matrix.multiply(self.matrix, m)
    return m[1][1], m[2][1]
end

return {
    new = new
}
