local gamestate = {}
local GameState_mt = {}

-- luacheck: push ignore self game dt
function GameState_mt:enter(game)
end
function GameState_mt:tick(game, dt)
end
function GameState_mt:draw(game, dt)
end
function GameState_mt:exit(game)
end
-- luacheck: pop

function gamestate.new(o)
    local self = o or {}
    setmetatable(self, {__index = GameState_mt})
    return self
end

return gamestate