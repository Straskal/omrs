local milk = require("milk")
local window = require("milk.window")
local time = require("milk.time")
local graphics = require("milk.graphics")

-- set extra search path for assets
package.path = package.path .. ";assets/?.lua"

local game = require("core.game")

local start = game.start or function()
    end
local tick = game.tick or function()
    end
local draw = game.draw or function()
    end
local stop = game.stop or function()
    end

-- initialize milk and it's libraries
milk.init()

-- initialize game
start(game)

window.show()

local TARGET_FPS = 60
local SECONDS_PER_TICK = 1 / TARGET_FPS
local frame_start_time = 0
local frame_time
local accumulated_frame_time = 0

-- run at fixed time step of SECONDS_PER_TICK
while not window.should_close() do
    local t = time.get_total()
    frame_time = t - frame_start_time
    frame_start_time = t
    accumulated_frame_time = accumulated_frame_time + frame_time

    -- we most likely hit a breakpoint if a complete frame takes a whole second.
    if accumulated_frame_time > 1 then
        accumulated_frame_time = 1
    end

    while accumulated_frame_time >= SECONDS_PER_TICK do
        window.poll()

        -- game logic
        tick(game, SECONDS_PER_TICK)

        -- draw logic
        draw(game, SECONDS_PER_TICK)

        graphics.present()
        accumulated_frame_time = accumulated_frame_time - SECONDS_PER_TICK
    end
end

-- shutdown
stop(game)

-- this should always be the last line of code executed.
milk.quit()
