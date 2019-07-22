local tiny = require("thirdparty.tiny")
local graphics = require("milk.graphics")
local updatesystem = require("systems.updatesystem")
local rendersystem = require("systems.rendersystem")

local gameplay = {}

function gameplay:on_enter()

    self.world = tiny.world()
    self.world:addSystem(updatesystem.new())
    self.world:addSystem(rendersystem.new())

    self.level = dofile("assets/core/test.lvl.lua")
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

function gameplay:on_draw()
end

return gameplay
