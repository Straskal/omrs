-- luacheck: ignore

local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local camera = require("camera")
local levelstate = require("levelstate")
local keys = keyboard.keys

--=================================================
-- local functions
--=================================================
local unpack = table.unpack
local iskeypressed = keyboard.is_key_pressed

local editstate = {}

--=================================================
-- EDITOR STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
    - auto populate level data for empty files
    - show/hide gameobjects
--]]
--=================================================
local function new(levelfile)
    return setmetatable(
        {
            levelstate = levelstate.new(levelfile),
            updatebelow = false,
            drawbelow = true,
            background_color = {0.2, 0.2, 0.31, 1},
            grid = {
                show = true,
                cell_size = 32,
                color = {0, 0, 0, 0.09}
            },
            map = {
                default_width = 100,
                default_height = 100,
                selected_layer = 1,
                onion = false,
                shadow = {
                    offset = 5,
                    color = {0, 0, 0, 0.2}
                }
            },
            mouse_state = {
                x = 0,
                y = 0,
                prevx = 0,
                prevy = 0,
                scroll = 0
            },
            navigation = {
                pan_speed = 40,
                zoom_speed = 1,
                kpan_speed = 200,
                kzoom_speed = 0.8
            },
        },
        {__index = editstate}
    )
end

function editstate:enter()
    window.set_title("OMRS Editor")
    self.game:insert(self.levelstate, 1)
end

function editstate:update(dt)
    self.levelstate:refreshgolists()
end

function editstate:draw()
end

return {
    new = new
}