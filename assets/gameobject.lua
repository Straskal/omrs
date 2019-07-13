local graphics = require("milk.graphics")

local gameobject = {}
local GameObject_mt = {}

-- luacheck: push ignore self
function GameObject_mt:spawned()
end
function GameObject_mt:tick()
end
function GameObject_mt:destroyed()
end
-- luacheck: pop

function GameObject_mt:draw()
    graphics.draw(self.image, self.position.x, self.position.y)
end

-- name of object and position in world space (vec2)
function gameobject.new(name, position)
    local self = {}
    self.name = name
    self.position = position
    self.image = nil
    setmetatable(self, {__index = GameObject_mt})
    return self
end

return gameobject
