local tiny = require("thirdparty.tiny")
local graphics = require("milk.graphics")
local camera = require("editor.camera")
local updatesystem = require("systems.updatesystem")
local animationsystem = require("systems.animationsystem")
local rendersystem = require("systems.rendersystem")

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
    self.level = dofile(self.levelfile)
    self.level.tilemap.tileset = dofile(self.level.tilemap.tilesetfile)
    self.level.tilemap.tilesheet = graphics.new_image(self.level.tilemap.tileset.tilesheetfile)

    -- create world with systems
    self.world =
        tiny.world(updatesystem.new(), animationsystem.new(), rendersystem.new(self.camera, self.level.tilemap))

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

function gameplay:on_tick(_, dt)
    graphics.set_draw_color(0, 0, 0, 1)
    graphics.clear()
    graphics.set_draw_color(1, 1, 1, 1)
    self.world:update(dt)
end

-- luacheck: push ignore
function gameplay:on_draw()
end
-- luacheck: pop

return {
    new = new
}
