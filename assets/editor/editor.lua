local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local camera = require("editor.camera")
local tilemaptools = require("editor.tilemaptools")
local gui = require("utils.gui")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

--=================================================
-- local functions
--=================================================
local unpack = table.unpack
local format = string.format
local iskeydown = keyboard.is_key_down
local iskeypressed = keyboard.is_key_pressed
local iskeyreleased = keyboard.is_key_released
local setdrawcolor = graphics.set_draw_color
local drawx = graphics.drawx
local drawrect = graphics.draw_rect
local drawfillrect = graphics.draw_filled_rect

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
        color = {0, 0, 0, 0.05}
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
-- MOUSE
--=================================================
local function handle_mouse(self, dt)
    local ms = self.mouse_state

    -- capture previous and current positions
    ms.prevx, ms.prevy = ms.x, ms.y
    ms.x, ms.y = mouse.get_position()

    -- zoom
    ms.scroll = mouse.get_scroll()

    -- only zoom if control is not being pressed.
    -- this allows for other controls to use control+ shortcuts without zooming.
    if not iskeydown(keys.LCTRL) then
        if ms.scroll > 0 then
            self.camera:zoom_in(self.navigation.zoom_speed * dt)
        elseif ms.scroll < 0 then
            self.camera:zoom_out(self.navigation.zoom_speed * dt)
        end
    end

    -- pan
    if mouse.is_button_down(mousebuttons.MIDDLE) then
        local pmsx, pmsy = ms.prevx, ms.prevy
        local pan_speed = self.navigation.pan_speed
        local new_cam_posx = (pmsx - ms.x) * pan_speed * dt
        local new_cam_posy = (pmsy - ms.y) * pan_speed * dt
        self.camera:move(new_cam_posx, new_cam_posy)
    end
end

--=================================================
-- KEYBOARD
--=================================================
local function handle_keyboard(self, dt)
    -- SHIFT +
    if iskeydown(keys.LCTRL) then
        -- G: toggle grid
        if iskeyreleased(keys.G) then
            self.grid.show = not self.grid.show
        end
        -- O: toggle map onion layers
        if iskeyreleased(keys.O) then
            self.map.onion = not self.map.onion
        end
        -- DOWN: add row to map
        if iskeyreleased(keys.DOWN) then
            local tilemap = self.level.tilemap
            tilemap.height = tilemap.height + 1

            for i = 1, #tilemap.layers do
                tilemap.layers[i][tilemap.height] = {}

                for j = 1, tilemap.width do
                    tilemap.layers[i][tilemap.height][j] = 0
                end
            end
        end
        -- UP: remove row from map
        if iskeyreleased(keys.UP) then
            local tilemap = self.level.tilemap

            for i = 1, #tilemap.layers do
                tilemap.layers[i][tilemap.height] = nil
            end
            tilemap.height = tilemap.height - 1
        end
        -- RIGHT: add column to map
        if iskeyreleased(keys.RIGHT) then
            self.level.tilemap.width = self.level.tilemap.width + 1
            for i = 1, #self.level.tilemap.layers do
                for j = 1, #self.level.tilemap.layers[i] do
                    self.level.tilemap.layers[i][j][self.level.tilemap.width] = 0
                end
            end
        end
        -- LEFT: remove column from map
        if iskeyreleased(keys.LEFT) then
            for i = 1, #self.level.tilemap.layers do
                for j = 1, #self.level.tilemap.layers[i] do
                    self.level.tilemap.layers[i][j][self.level.tilemap.width] = nil
                end
            end
            self.level.tilemap.width = self.level.tilemap.width - 1
        end
    end

    -- toggle layer
    if iskeypressed(keys.TAB) then
        local nextlayer = self.map.selected_layer + 1
        if nextlayer > #self.level.tilemap.layers then
            nextlayer = 1
        end
        self.map.selected_layer = nextlayer
    end

    -- pan with WASD
    if iskeydown(keys.W) then
        self.camera:move(0, -self.navigation.kpan_speed * dt)
    end
    if iskeydown(keys.S) then
        self.camera:move(0, self.navigation.kpan_speed * dt)
    end
    if iskeydown(keys.A) then
        self.camera:move(-self.navigation.kpan_speed * dt, 0)
    end
    if iskeydown(keys.D) then
        self.camera:move(self.navigation.kpan_speed * dt, 0)
    end

    -- zoom with arrows
    if iskeydown(keys.E) then
        self.camera:zoom_in(self.navigation.kzoom_speed * dt)
    end
    if iskeydown(keys.Q) then
        self.camera:zoom_out(self.navigation.kzoom_speed * dt)
    end
end

--=================================================
-- OPENING THE EDITOR
--=================================================
function editor:on_enter()
    window.set_title("OMRS Editor")

    -- load level
    self.level = dofile("assets/core/test.lvl.lua")
    self.tileset = dofile(self.level.tilemap.tileset)
    self.tilesheet = graphics.new_image(self.tileset.tilesheet)

    self.level.tilemap.width = self.level.tilemap.width or self.map.default_width
    self.level.tilemap.height = self.level.tilemap.height or self.map.default_height

    -- center camera on level
    local w = self.level.tilemap.width * self.grid.cell_size
    local h = self.level.tilemap.height * self.grid.cell_size
    self.camera.position[1], self.camera.position[2] = w * 0.5, h * 0.5

    -- open default tools
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
    -- we transform the initial draw point once to avoid performing this costly operation for every single cell.
    local x, y = self.camera:transform_point(0, 0)
    local advancex, advancey = x, y
    local tilesheet = self.tilesheet
    local tiledefs = self.tileset.tiledefinitions
    local mapwidth = self.level.tilemap.width
    local mapheight = self.level.tilemap.height
    local zoom = self.camera.zoom
    local cellsz = self.grid.cell_size
    local scaledcellsz = cellsz * self.camera.zoom
    local numlayers = #self.level.tilemap.layers

    -- draw map shadow
    setdrawcolor(unpack(self.map.shadow.color))
    local shadowoffset = self.map.shadow.offset
    local shadowx, shadowy = self.camera:transform_point(shadowoffset, shadowoffset)
    drawfillrect(
        shadowx,
        shadowy,
        (mapwidth * scaledcellsz) + (shadowoffset * zoom),
        (mapheight * scaledcellsz) + (shadowoffset * zoom)
    )

    -- draw painted layers
    for i = 1, numlayers do
        -- for onion skinning, draw all layers beneath a tad darker.
        -- draw all layers above with uber transparency
        -- this makes it easier to focus on the current layer thats being edited
        if (self.map.onion) then
            if i < self.map.selected_layer then
                setdrawcolor(0.25, 0.25, 0.25, 1)
            elseif i > self.map.selected_layer then
                setdrawcolor(0.4, 0.4, 0.4, 0.07)
            else
                setdrawcolor(1, 1, 1, 1)
            end
        else
            setdrawcolor(1, 1, 1, 1)
        end

        local layer = self.level.tilemap.layers[i]
        for j = 1, mapheight do
            for k = 1, mapwidth do
                local tileid = layer[j][k]
                -- if there is no tile here, skip drawing
                if tileid > 0 then
                    local tilesrc = tiledefs[tileid].src
                    drawx(tilesheet, advancex, advancey, tilesrc[1], tilesrc[2], cellsz, cellsz, zoom, zoom, 0)
                end
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
        advancex, advancey = x, y
    end
end

--=================================================
-- DRAWING THE GRID
--=================================================
local function draw_grid(self)
    if self.grid.show then
        -- we transform the initial draw point once to avoid performing this costly operation for every single cell.
        local x, y = self.camera:transform_point(0, 0)
        local advancex, advancey = x, y
        local scaledcellsz = self.grid.cell_size * self.camera.zoom
        local mapwidth = self.level.tilemap.width
        local mapheight = self.level.tilemap.height

        setdrawcolor(unpack(self.grid.color))
        for _ = 1, mapheight do
            for _ = 1, mapwidth do
                drawrect(advancex, advancey, scaledcellsz, scaledcellsz)
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
    end
end

--=================================================
-- DRAWING COMMON INFO
--=================================================
local function draw_common_info(self, game)
    local cam = self.camera

    -- bottom pannel
    gui:panel(0, 345, 640, 15)

    -- draw level name
    gui:label(350, 5, self.level.name)

    -- draw fps
    gui:label(590, 5,format("FPS: %.0f", game.fps))

    -- draw cam pos, mouse pos, and zoom
    local msx, msy = cam:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(10, 350, format("+ %.0f, %.0f", msx, msy))

    local cmx, cmy = cam.position[1], cam.position[2]
    gui:label(80, 350, format("[ ] %.0f, %.0f", cmx, cmy))

    -- draw current layer num
    local selectedlayer = self.map.selected_layer
    local numlayers = #self.level.tilemap.layers
    if self.map.onion then
        setdrawcolor(1, 1, 0, 1)
    end
    gui:label(160, 350, format("// %d/%d", selectedlayer, numlayers))

    setdrawcolor(1, 1, 1, 1)
    gui:label(615, 350, format("%.0f%%", cam:get_zoom_percentage()))
end

function editor:on_draw(game, _)
    gui:begin_draw()
    setdrawcolor(unpack(self.background_color))
    graphics.clear()
    setdrawcolor(1, 1, 1, 1)
    self.camera:calc_matrix()
    draw_map(self)
    draw_grid(self)
    self.current_toolset:draw(self)
    draw_common_info(self, game)
    gui:end_draw()
end

-- luacheck: ignore
function editor:on_stop(_, dt)
end
-- luacheck: pop

return editor
