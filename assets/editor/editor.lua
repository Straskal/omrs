local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local camera = require("editor.camera")
local tiny = require("thirdparty.tiny")
local input = require("editor.input")
local onionskinning = require("editor.onionskinning")
local tilemapshadow = require("editor.tilemapshadow")
local levelrenderer = require("gameplay.levelrenderer")
local commontools = require("editor.commontools")
local tilemaptools = require("editor.tilemaptools")
local keys = keyboard.keys

--=================================================
-- local functions
--=================================================
local unpack = table.unpack
local iskeypressed = keyboard.is_key_pressed

--=================================================
-- EDITOR STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
    - auto populate level data for empty files
    - show/hide gameobjects
--]]
--=================================================
local editor = {
    camera = camera.new(),
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
    current_toolset = tilemaptools
}

--=================================================
-- OPENING THE EDITOR
--=================================================
function editor:on_enter(game)
    window.set_title("OMRS Editor")

    -- load level
    self.level = dofile("assets/core/test.lvl.lua")
    self.tileset = dofile(self.level.tilemap.tilesetfile)
    self.tilesheet = graphics.new_image(self.tileset.tilesheetfile)

    self.level.tilemap.width = self.level.tilemap.width or self.map.default_width
    self.level.tilemap.height = self.level.tilemap.height or self.map.default_height

    -- center camera on level
    local w = self.level.tilemap.width * self.grid.cell_size
    local h = self.level.tilemap.height * self.grid.cell_size
    self.camera.position[1], self.camera.position[2] = w * 0.5, h * 0.5

    self.systems =
        tiny.world(
        input(self),
        onionskinning(self),
        tilemapshadow(self),
        levelrenderer(self.camera, self.level.tilemap, self.tileset.tiledefinitions, self.tilesheet),
        commontools(self, game),
        tilemaptools(self)
    )
end

--=================================================
-- TICKING
--=================================================
function editor:on_tick(game, dt)
    graphics.set_draw_color(unpack(self.background_color))
    graphics.clear()
    graphics.set_draw_color(1, 1, 1, 1)
    self.systems:update(dt)
    graphics.present()

    if iskeypressed(keys.TILDE) then
        game:load_level("assets/core/test.lvl.lua")
    end
end

return editor
