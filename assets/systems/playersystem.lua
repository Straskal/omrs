local tiny = require("thirdparty.tiny")
local keyboard = require("milk.keyboard")
local keys = keyboard.keys

local function new()
    local player = tiny.processingSystem()
    player.filter = tiny.requireAll("player")

    -- luacheck: push ignore self
    function player:process(e, dt)
        if keyboard.is_key_down(keys.W) then
            e.position[2] = e.position[2] - e.player.speed * dt
        end
        if keyboard.is_key_down(keys.A) then
            e.position[1] = e.position[1] - e.player.speed * dt
        end
        if keyboard.is_key_down(keys.S) then
            e.position[2] = e.position[2] + e.player.speed * dt
        end
        if keyboard.is_key_down(keys.D) then
            e.position[1] = e.position[1] + e.player.speed * dt
        end
    end
    -- luacheck: pop

    return player
end

return {
    new = new
}
