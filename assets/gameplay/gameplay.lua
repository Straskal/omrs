local tiny = require("thirdparty.tiny")
local graphics = require("milk.graphics")
local camera = require("editor.camera")
local updatesystem = require("systems.updatesystem")
local animationsystem = require("systems.animationsystem")
local rendersystem = require("systems.rendersystem")

local gameplay = {
    camera = camera.new(),
}

function gameplay:on_enter()
    -- TODO: this all needs to be refactored in a way where we can dynamically load levels
    self.level = dofile("assets/core/test.lvl.lua")
    self.level.tilemap.tileset = dofile(self.level.tilemap.tilesetfile)
    self.level.tilemap.tilesheet = graphics.new_image(self.level.tilemap.tileset.tilesheetfile)

    self.world = tiny.world()
    self.world:addSystem(updatesystem.new())
    self.world:addSystem(animationsystem.new())
    self.world:addSystem(rendersystem.new(self.camera, self.level.tilemap))

    for i = 1, #self.level.gameobjects do
        local e = dofile(self.level.gameobjects[i].file)
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

return gameplay
