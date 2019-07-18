local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local camera = require("utils.camera")
local gui = require("utils.gui")
local tilemaptools = require("editor.tilemaptools")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

local editstate = {
    GRID_CELL_SIZE = 32,
    camera = camera.new(),
    mousex = 0,
    mousey = 0,
    pmousex = 0,
    pmousey = 0,
    options = {
        showgrid = true,
        panspeed = 40
    },
    leveldata = nil
}

local function handle_mouse(self, dt)
    -- update previous and current positions
    self.pmousex, self.pmousey = self.mousex, self.mousey
    self.mousex, self.mousey = mouse.get_position()

    -- zoom
    local scroll = mouse.get_scroll()
    if scroll > 0 then
        self.camera:zoom_in(0.5)
    elseif scroll < 0 then
        self.camera:zoom_out(0.5)
    end

    -- pan
    if mouse.is_button_down(mousebuttons.RIGHT) then
        local pmsx, pmsy = self.pmousex, self.pmousey
        local panspeed = self.options.panspeed
        local new_cam_posx = (pmsx - self.mousex) * panspeed * dt
        local new_cam_posy = (pmsy - self.mousey) * panspeed * dt
        self.camera:move(new_cam_posx, new_cam_posy)
    end
end

local function handle_keyboard(self)
    if keyboard.is_key_down(keys.LSHIFT) then
        if keyboard.is_key_released(keys.G) then
            self.showgrid = not self.showgrid
        end
    end
end

function editstate:on_enter()
    -- load level
    self.level = dofile("assets/core/test.lvl.lua")
    self.tileset = dofile(self.level.tilemap.tileset)
    self.tilesheet = graphics.new_image(self.tileset.tilesheet)

    local resw, resh = graphics.get_resolution()
    self.camera.position[1], self.camera.position[2] = resw / 2, resh / 2
    self.mousex, self.mousey = mouse.get_position()
    self.pmousex, self.pmousey = self.mousex, self.mousey
end

function editstate:on_tick(_, dt)
    handle_mouse(self, dt)
    handle_keyboard(self)
    tilemaptools:handle_input(self)
end

local function draw_grid(self)
    if self.showgrid then
        graphics.set_draw_color(0.5, 0.1, 0.1, 0.5)
        for i = 1, #self.level.tilemap.tiles do
            for j = 1, #self.level.tilemap.tiles[1] do
                self.camera:draw_rect(
                    (j - 1) * self.GRID_CELL_SIZE,
                    (i - 1) * self.GRID_CELL_SIZE,
                    self.GRID_CELL_SIZE,
                    self.GRID_CELL_SIZE
                )
            end
        end
    end
end

local function draw_map(self)
    graphics.set_draw_color(1, 1, 1, 1)
    local h = #self.level.tilemap.tiles
    for i = 1, h do
        local w = #self.level.tilemap.tiles[i]
        for j = 1, w do
            local tileid = self.level.tilemap.tiles[i][j]
            if tileid > 0 then
                local tilesrc = self.tileset.tiledefinitions[tileid].src
                self.camera:draw(
                    self.tilesheet,
                    (j - 1) * self.GRID_CELL_SIZE,
                    (i - 1) * self.GRID_CELL_SIZE,
                    tilesrc.x,
                    tilesrc.y,
                    self.GRID_CELL_SIZE,
                    self.GRID_CELL_SIZE
                )
            end
        end
    end
end

function editstate:on_draw(_, _)
    self.camera:calc_matrix()
    draw_map(self)
    draw_grid(self)
    tilemaptools:draw(self)

    local msx, msy = self.camera:screen2world(self.mousex, self.mousey)
    gui:label(10, 340, string.format("Mouse: %0.2f, %0.2f", msx, msy))
end

-- luacheck: ignore
function editstate:on_stop(_, dt)
end
-- luacheck: pop

return editstate
