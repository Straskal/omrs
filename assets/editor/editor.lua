local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local camera = require("utils.camera")
local gui = require("utils.gui")
local tilemaptools = require("editor.tilemaptools")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

--=================================================
-- EDITOR STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
--]]
--=================================================
local editor = {
    grid_cell_size = 32,
    grid_color = {0, 0, 0, 0.13},
    background_color = {0.2, 0.2, 0.31, 1},
    camera = camera.new(),
    mouse_state = {
        x = 0,
        y = 0,
        prevx = 0,
        prevy = 0,
        scroll = 0
    },
    options = {
        showgrid = true,
        panspeed = 40,
        zoomspeed = 2
    },
    leveldata = nil,
    current_toolset = tilemaptools
}

--=================================================
-- MOUSE
--=================================================
local function handle_mouse(self, dt)
    local ms = self.mouse_state

    -- previous and current positions
    ms.prevx, ms.prevy = ms.x, ms.y
    ms.x, ms.y = mouse.get_position()

    -- zoom
    ms.scroll = mouse.get_scroll()
    if ms.scroll > 0 then
        self.camera:zoom_in(self.options.zoomspeed * dt)
    elseif ms.scroll < 0 then
        self.camera:zoom_out(self.options.zoomspeed * dt)
    end

    -- pan
    if mouse.is_button_down(mousebuttons.MIDDLE) then
        local pmsx, pmsy = ms.prevx, ms.prevy
        local panspeed = self.options.panspeed
        local new_cam_posx = (pmsx - ms.x) * panspeed * dt
        local new_cam_posy = (pmsy - ms.y) * panspeed * dt
        self.camera:move(new_cam_posx, new_cam_posy)
    end
end

--=================================================
-- KEYBOARD SHORTCUTS
--=================================================
local function handle_keyboard(self)
    -- SHIFT +
    if keyboard.is_key_down(keys.LSHIFT) then
        -- G: toggle grid
        if keyboard.is_key_released(keys.G) then
            self.options.showgrid = not self.options.showgrid
        end
    end
end

--=================================================
-- OPENING THE EDITOR
--=================================================
function editor:on_enter()
    -- load level
    self.level = dofile("assets/core/test.lvl.lua")
    self.tileset = dofile(self.level.tilemap.tileset)
    self.tilesheet = graphics.new_image(self.tileset.tilesheet)

    -- center camera on level
    local h = #self.level.tilemap.tiles * self.grid_cell_size
    local w = #self.level.tilemap.tiles[1] * self.grid_cell_size
    self.camera.position[1], self.camera.position[2] = w / 2, h / 2
    self.mousex, self.mousey = mouse.get_position()
    self.pmousex, self.pmousey = self.mousex, self.mousey

    self.current_toolset:open(self)
end

--=================================================
-- TICKING
--=================================================
function editor:on_tick(_, dt)
    handle_mouse(self, dt)
    handle_keyboard(self)
    self.current_toolset:handle_input(self)
end

--=================================================
-- DRAWING
--=================================================
local function draw_grid(self)
    graphics.set_draw_color(table.unpack(self.grid_color))
    local tiles = self.level.tilemap.tiles

    if self.options.showgrid then
        for i = 1, #tiles do
            for j = 1, #tiles[1] do
                -- TODO: draw_lines
                self.camera:draw_rect(
                    (j - 1) * self.grid_cell_size,
                    (i - 1) * self.grid_cell_size,
                    self.grid_cell_size,
                    self.grid_cell_size
                )
            end
        end
    else
        local h = #tiles
        local w = #tiles[1]
        self.camera:draw_rect(0, 0, self.grid_cell_size * w, self.grid_cell_size * h)
    end
end

local function draw_map(self)
    local tiles = self.level.tilemap.tiles
    local tiledefs = self.tileset.tiledefinitions
    local h = #tiles
    local w = #tiles[1]

    -- draw tilemap shadow
    graphics.set_draw_color(0, 0, 0, 0.2)
    self.camera:draw_filled_rect(5, 5, (w * self.grid_cell_size) + 5, (h * self.grid_cell_size) + 5)

    -- draw map
    graphics.set_draw_color(1, 1, 1, 1)
    for i = 1, h do
        for j = 1, w do
            local tileid = tiles[i][j]
            if tileid > 0 then
                local tilesrc = tiledefs[tileid].src
                self.camera:draw(
                    self.tilesheet,
                    (j - 1) * self.grid_cell_size,
                    (i - 1) * self.grid_cell_size,
                    tilesrc.x,
                    tilesrc.y,
                    self.grid_cell_size,
                    self.grid_cell_size
                )
            end
        end
    end
end

function editor:on_draw(_, _)
    gui:begin_draw()
    graphics.set_draw_color(table.unpack(self.background_color))
    graphics.clear()
    graphics.set_draw_color(1, 1, 1, 1)

    self.camera:calc_matrix()

    draw_map(self)
    draw_grid(self)
    self.current_toolset:draw(self)

    -- draw mouse pos
    local msx, msy = self.camera:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(10, 340, string.format("Mouse: %0.2f, %0.2f", msx, msy))
    gui:end_draw()
end

-- luacheck: ignore
function editor:on_stop(_, dt)
end
-- luacheck: pop

return editor
