local EditState = {}
EditState.__index = EditState

local function new()
    local instance = {}
    setmetatable(instance, EditState)
    return instance
end

-- luacheck: ignore
function EditState:enter()
end

function EditState:tick(_, dt)
end

function EditState:draw(_, dt)
end

function EditState:stop(_, dt)
end
-- luacheck: pop

return {
    new = new
}
