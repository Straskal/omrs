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
    grid_color = {0, 0, 0, 0.05},
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
        kpanspeed = 200,
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
local function handle_keyboard(self, dt)
    -- SHIFT +
    if keyboard.is_key_down(keys.LSHIFT) then
        -- G: toggle grid
        if keyboard.is_key_released(keys.G) then
            self.options.showgrid = not self.options.showgrid
        end
    end
    -- pan with arrows
    if keyboard.is_key_down(keys.W) then
        self.camera:move(0, -self.options.kpanspeed * dt)
    end
    if keyboard.is_key_down(keys.S) then
        self.camera:move(0, self.options.kpanspeed * dt)
    end
    if keyboard.is_key_down(keys.A) then
        self.camera:move(-self.options.kpanspeed * dt, 0)
    end
    if keyboard.is_key_down(keys.D) then
        self.camera:move(self.options.kpanspeed * dt, 0)
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
    handle_keyboard(self, dt)
    self.current_toolset:handle_input(self)
end

--=================================================
-- DRAWING THE MAP
--=================================================
local function draw_map(self)
    -- we transform the initial draw point of the map one time. we want avoid doing this alot.
    local x, y = self.camera:transform_point(0, 0)
    -- used advance the next draw position
    local advancex, advancey = x, y
    local tiles = self.level.tilemap.tiles
    local tiledefs = self.tileset.tiledefinitions
    local h = #tiles
    local w = #tiles[1]
    local zoom = self.camera.zoom
    local cellsz = self.grid_cell_size
    local scaledcellsz = cellsz * self.camera.zoom

    -- draw map shadow - a rect with an x and y offset of 5
    graphics.set_draw_color(0, 0, 0, 0.2)
    local shadowx, shadowy = self.camera:transform_point(5, 5)
    graphics.draw_filled_rect(shadowx, shadowy, (w * scaledcellsz) + (5 * zoom), (h * scaledcellsz) + (5 * zoom))

    -- draw painted tiles
    graphics.set_draw_color(1, 1, 1, 1)
    for i = 1, #tiles do
        for j = 1, #tiles[1] do
            local tileid = tiles[i][j]
            -- 0 is not a valid id
            if tileid > 0 then
                local tilesrc = tiledefs[tileid].src
                graphics.drawx(self.tilesheet, advancex, advancey, tilesrc.x, tilesrc.y, cellsz, cellsz, zoom, zoom, 0)
            end
            advancex = advancex + scaledcellsz
        end
        advancex = x
        advancey = advancey + scaledcellsz
    end
end

--=================================================
-- DRAWING THE GRID
--=================================================
local function draw_grid(self)
    if self.options.showgrid then
        -- we transform the initial draw point of the map one time. we want avoid doing this alot.
        local x, y = self.camera:transform_point(0, 0)
        -- used advance the next draw position
        local advancex, advancey = x, y
        local tiles = self.level.tilemap.tiles
        local scaledcellsz = self.grid_cell_size * self.camera.zoom

        graphics.set_draw_color(table.unpack(self.grid_color))
        for _ = 1, #tiles do
            for _ = 1, #tiles[1] do
                graphics.draw_rect(advancex, advancey, scaledcellsz, scaledcellsz)
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
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

    -- draw cam pos, mouse pos, and zoom
    gui:label(580, 345, string.format("Zoom: %.0f%%", self.camera:get_zoom_percentage()))
    local cmx, cmy = self.camera.position[1], self.camera.position[2]
    gui:label(10, 335, string.format("Camera: %0.2f, %0.2f", cmx, cmy))
    local msx, msy = self.camera:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(10, 345, string.format(" Mouse: %0.2f, %0.2f", msx, msy))
    gui:end_draw()
end

-- luacheck: ignore
function editor:on_stop(_, dt)
end
-- luacheck: pop

return editor
