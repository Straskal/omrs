local milk = require("milk")
local window = require("milk.window")
local time = require("milk.time")

-- set extra search path for assets
package.path = package.path .. ";assets/?.lua"

local game = require("game")

local start = game.start or function()
    end
local update = game.update or function()
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
local SEC_PER_UPDATE = 1 / TARGET_FPS
local frame_start_time = 0
local accumulated_frame_time = 0
local num_frames = 0
local frame_count_start = time.get_total()

-- run at fixed time step of SEC_PER_UPDATE
while not window.should_close() do
    local t = time.get_total()
    local frame_time = t - frame_start_time
    frame_start_time = t
    accumulated_frame_time = accumulated_frame_time + frame_time

    -- it a complete frame takes over a second, it's like that we've hit a breakpoint.
    if accumulated_frame_time > 1 then
        accumulated_frame_time = 1
    end

    while accumulated_frame_time >= SEC_PER_UPDATE do
        window.poll()

        -- game logic
        update(game, SEC_PER_UPDATE)

        -- draw logic
        draw(game, SEC_PER_UPDATE)

        accumulated_frame_time = accumulated_frame_time - SEC_PER_UPDATE

        game.fps = num_frames / (time.get_total() - frame_count_start)
        num_frames = num_frames + 1
    end
end

-- shutdown
stop(game)

-- this should always be the last line of code executed.
milk.quit()
