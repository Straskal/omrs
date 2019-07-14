local gamestate = require("assets.core.gamestate")
local editorstate = require("assets.core.editorstate")
local keyboard = require("milk.keyboard")
local level = require("assets.core.level")
local player = require("assets.player.player")
local keys = keyboard.keys

local playstate = {}
local PlayState_mt = gamestate.new()

function PlayState_mt:enter()
    self.level = level.new()
    self.level:spawn(player)
end

function PlayState_mt:tick(game, dt)
    self.level:tick(dt)
    if keyboard.is_key_released(keys.TILDE) then
        game:push_state(editorstate.new())
    end
end

function PlayState_mt:draw(_, dt)
    self.level:draw(dt)
end

function PlayState_mt:stop(_, dt)
    self.level:stop(dt)
end

function playstate.new()
    local self = {}
    setmetatable(self, {__index = PlayState_mt})
    return self
end

return playstate
