local graphics = require("milk.graphics")

local unpack = table.unpack

local sprite = {}

local function new()
    return setmetatable(
        {
            scale = 1,
            rotation = 0,
            color = {1, 1, 1, 1}
        },
        {__index = sprite}
    )
end

function sprite:draw(go, camera)
    local posx, posy = camera:transform_point(go.position[1], go.position[2])

    graphics.set_draw_color(unpack(self.color))
    graphics.drawx(
        go.image,
        posx - (go.src[3] / 2),
        posy - (go.src[4] / 2),
        go.src[1],
        go.src[2],
        go.src[3],
        go.src[4],
        self.scale,
        self.scale,
        self.rotation
    )
end

return {
    new = new
}
