local graphics = require("milk.graphics")

local unpack = table.unpack

local gameobject = {}

local function new(o)
    o = o or {}
    o.srcrect = o.srcrect or {0, 0, 32, 32}
    o.scale = o.scale or 1
    o.rotation = o.rotation or 0
    o.color = o.color or {1, 1, 1, 1}
    o.bbox = o.bbox or {32, 32}
    o.image = nil
    o.super = gameobject

    return setmetatable(o, {__index = gameobject})
end

function gameobject:load(_, level)
    self.image = level.assets:get(self.imagefile)
end

function gameobject:spawned(_, level)
    level.bumpworld:add(self, self.position[1], self.position[2], self.bbox[1], self.bbox[2])
end

function gameobject:draw(_, level, _)
    local posx, posy = level.camera:transform_point(self.position[1], self.position[2])

    graphics.set_draw_color(unpack(self.color))
    graphics.drawx(
        self.image,
        posx - (self.srcrect[3] / 2),
        posy - (self.srcrect[4] / 2),
        self.srcrect[1],
        self.srcrect[2],
        self.srcrect[3],
        self.srcrect[4],
        self.scale,
        self.scale,
        self.rotation
    )
end

function gameobject:destroyed(_, level)
    level.bumpworld:remove(self)
end

return {
    new = new
}
