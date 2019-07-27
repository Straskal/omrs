local body = {}

local function new()
    return setmetatable({}, {__index = body})
end

-- luacheck: push ignore self
function body:update(go, world)
    local velx, vely = go.vel[1], go.vel[2]
    local newposx, newposy = go.position[1] + velx, go.position[2] + vely
    local actualx, actualy, colls, len = world:move(go, newposx, newposy)

    go.position[1], go.position[2] = actualx, actualy

    if len > 0 and go.on_collision then
        return colls[1]
    end
    return nil
end
-- luacheck: pop

return {
    new = new
}
