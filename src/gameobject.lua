local graphics = require("milk.graphics")

local unpack = table.unpack
local dummyfunc = function()
end

local function defaultdraw(self)
    local posx, posy = self.level.camera:transform_point(self.position[1], self.position[2])
    local zoom = self.level.camera.zoom

    graphics.set_draw_color(unpack(self.color))
    graphics.drawx(
        self.image,
        -- center the image
        posx - (self.srcrect[3] / 2) * zoom,
        posy - (self.srcrect[4] / 2) * zoom,
        self.srcrect[1],
        self.srcrect[2],
        self.srcrect[3],
        self.srcrect[4],
        self.scale * zoom,
        self.scale * zoom,
        self.rotation
    )
end

local gameobject = {}

local function new(o)
    o = o or {}

    -- image properties
    o.image = o.image or nil
    o.srcrect = o.srcrect or {0, 0, 32, 32}
    o.color = o.color or {1, 1, 1, 1}
    o.layer = o.layer or 0

    -- body properties
    o.scale = o.scale or 1
    o.rotation = o.rotation or 0
    o.bbox = o.bbox or {32, 32}

    -- callbacks
    o.onload = o.onload or dummyfunc
    o.onspawn = o.onspawn or dummyfunc
    o.onupdate = o.onupdate or dummyfunc
    o.ondestroy = o.ondestroy or dummyfunc
    o.ondraw = o.ondraw or defaultdraw

    return setmetatable(o, {__index = gameobject})
end

function gameobject:load()
    self:onload()
end

function gameobject:spawned()
    self.level.bumpworld:add(
        self,
        self.position[1] - self.bbox[1] / 2,
        self.position[2] - self.bbox[2] / 2,
        self.bbox[1],
        self.bbox[2]
    )
    self:onspawn()
end

function gameobject:update(dt)
    self:onupdate(dt)
end

function gameobject:draw()
    self:ondraw()
end

function gameobject:destroyed()
    self:ondestroy()
    self.level.bumpworld:remove(self)
end

function gameobject:updatebbox()
    self.level.bumpworld.update(self, self.position[1], self.position[2])
end

function gameobject:move(x, y)
    local xoff = self.bbox[1] / 2
    local yoff = self.bbox[2] / 2

    self.position[1], self.position[2] = (self.position[1] - xoff) + x, (self.position[2] - yoff) + y
    self:updatebbox()
end

function gameobject:moveandcollide(x, y)
    local xoff = self.bbox[1] / 2
    local yoff = self.bbox[2] / 2
    local targetx, targety = (self.position[1] - xoff) + x, (self.position[2] - yoff) + y
    local actualx, actualy, colls = self.level.bumpworld:move(self, targetx, targety)

    self.position[1], self.position[2] = actualx + xoff, actualy + yoff
    return colls[1]
end

return {
    new = new
}
