local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local tiny = require("thirdparty.tiny")
local camera = require("editor.camera")
local updatecallback = require("gameplay.updatecallback")
local animationcontroller = require("gameplay.animationcontroller")
local levelrenderer = require("gameplay.levelrenderer")
local editor = require("editor.editor")
local keys = keyboard.keys

local gameplay = {}

local function new(levelfile)
    local instance = {
        camera = camera.new(),
        levelfile = levelfile
    }
    setmetatable(instance, {__index = gameplay})
    return instance
end

function gameplay:on_enter()
    window.set_title("Old Man Rage Strength")

    self.level = dofile(self.levelfile)
    self.level.tilemap.tileset = dofile(self.level.tilemap.tilesetfile)
    self.level.tilemap.tilesheet = graphics.new_image(self.level.tilemap.tileset.tilesheetfile)

    -- create world with systems
    self.world =
        tiny.world(
        updatecallback(),
        animationcontroller(),
        levelrenderer(
            self.camera,
            self.level.tilemap,
            self.level.tilemap.tileset.tiledefinitions,
            self.level.tilemap.tilesheet
        )
    )

    -- load all gameobjects
    local loaded = {}
    for i = 1, #self.level.gameobjects do
        local file = self.level.gameobjects[i].file
        if not loaded[file] then
            loaded[file] = loadfile(file)
        end
        local e = loaded[file](self.level.gameobjects[i].file)
        e.position = self.level.gameobjects[i].position

        self.world:addEntity(e)
    end
end

function gameplay:on_tick(game, dt)
    if keyboard.is_key_pressed(keys.TILDE) then
        game:switch_state(editor)
    end
    graphics.set_draw_color(0, 0, 0, 1)
    graphics.clear()
    graphics.set_draw_color(1, 1, 1, 1)
    self.world:update(dt)
end

return {
    new = new
}
