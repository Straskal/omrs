local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local levelstate = require("levelstate")
local gui = require("gui")
local persistence = require("libs.persistence")
local mousebuttons = mouse.buttons
local keys = keyboard.keys

--=================================================
-- local functions
--=================================================
local unpack = table.unpack
local format = string.format
local floor = math.floor
local setdrawcolor = graphics.set_draw_color
local drawx = graphics.drawx
local drawrect = graphics.draw_rect

local function is_mouse_over(mx, my, x, y, w, h)
    return mx > x and mx <= x + w and my > y and my <= y + h
end

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
                onion = false
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
            brushsize = 1,
            tile_picker = {
                grid = {},
                selected = 0,
                selected_src = {},
                offset = {x = 5, y = 15},
                selected_color = {1, 1, 1, 1}
            }
        },
        {__index = editstate}
    )
end

local function construct_tile_picker_grid(self)
    -- create grid from array of tile definitions
    local tiledefs = self.levelstate.tilesets[self.map.selected_layer].tiledefs
    local grid = self.tile_picker.grid

    -- we want to display the tiles in rows of 4
    local columns = math.ceil(#tiledefs / 4)

    local curr = 1
    for i = 1, columns do
        grid[i] = {}
        for j = 1, 4 do
            if curr > #tiledefs then
                break
            end
            grid[i][j] = tiledefs[curr]
            curr = curr + 1
        end
    end
end

local function handleinput(self, dt)
    -- capture previous and current positions
    local ms = self.mouse_state
    ms.prevx, ms.prevy = ms.x, ms.y
    ms.x, ms.y = mouse.get_position()

    -- zoom
    ms.scroll = mouse.get_scroll()

    -- only zoom if control is not being pressed.
    -- this allows for other controls to use control+ shortcuts without zooming.
    ms.scroll = mouse.get_scroll()
    if not keyboard.is_key_down(keys.LCTRL) then
        if ms.scroll > 0 then
            self.levelstate.camera:zoom_in(self.navigation.zoom_speed * dt)
        elseif ms.scroll < 0 then
            self.levelstate.camera:zoom_out(self.navigation.zoom_speed * dt)
        end
    end

    -- pan
    if mouse.is_button_down(mousebuttons.MIDDLE) then
        local pmsx, pmsy = ms.prevx, ms.prevy
        local pan_speed = self.navigation.pan_speed
        local new_cam_posx = (pmsx - ms.x) * pan_speed * dt
        local new_cam_posy = (pmsy - ms.y) * pan_speed * dt

        self.levelstate.camera:move(new_cam_posx, new_cam_posy)
    end

    -- CTRL+
    if keyboard.is_key_down(keys.LCTRL) then
        -- S: save map data and overwrite currently edited file
        if keyboard.is_key_released(keys.S) then
            _G.persistence.store(self.levelstate.file, self.levelstate.data)
        end
        -- G: toggle grid
        if keyboard.is_key_released(keys.G) then
            self.grid.show = not self.grid.show
        end
        -- O: toggle map onion layers
        if keyboard.is_key_released(keys.O) then
            self.map.onion = not self.map.onion
        end
        -- DOWN: add row to map
        if keyboard.is_key_released(keys.DOWN) then
            local tilemap = self.levelstate.data.tilemap
            tilemap.height = tilemap.height + 1

            for i = 1, #tilemap.layers do
                tilemap.layers[i].tiles[tilemap.height] = {}

                for j = 1, tilemap.width do
                    tilemap.layers[i].tiles[tilemap.height][j] = 0
                end
            end
        end
        -- UP: remove row from map
        if keyboard.is_key_released(keys.UP) then
            local tilemap = self.levelstate.data.tilemap

            for i = 1, #tilemap.layers do
                tilemap.layers[i].tiles[tilemap.height] = nil
            end
            tilemap.height = tilemap.height - 1
        end
        -- RIGHT: add column to map
        if keyboard.is_key_released(keys.RIGHT) then
            self.levelstate.data.tilemap.width = self.levelstate.data.tilemap.width + 1
            for i = 1, #self.levelstate.data.tilemap.layers do
                for j = 1, #self.levelstate.data.tilemap.layers[i].tiles do
                    self.levelstate.data.tilemap.layers[i].tiles[j][self.levelstate.data.tilemap.width] = 0
                end
            end
        end
        -- LEFT: remove column from map
        if keyboard.is_key_released(keys.LEFT) then
            for i = 1, #self.levelstate.data.tilemap.layers do
                for j = 1, #self.levelstate.data.tilemap.layers[i].tiles do
                    self.levelstate.data.tilemap.layers[i].tiles[j][self.levelstate.data.tilemap.width] = nil
                end
            end
            self.levelstate.data.tilemap.width = self.levelstate.data.tilemap.width - 1
        end
    end

    -- toggle layer
    if keyboard.is_key_released(keys.TAB) then
        local nextlayer = self.map.selected_layer + 1
        if nextlayer > #self.levelstate.data.tilemap.layers then
            nextlayer = 1
        end
        self.map.selected_layer = nextlayer
        self.tile_picker.selected = 0
        construct_tile_picker_grid(self)
    end

    -- pan with WASD
    if keyboard.is_key_down(keys.W) then
        self.levelstate.camera:move(0, -self.navigation.kpan_speed * dt)
    end
    if keyboard.is_key_down(keys.S) then
        self.levelstate.camera:move(0, self.navigation.kpan_speed * dt)
    end
    if keyboard.is_key_down(keys.A) then
        self.levelstate.camera:move(-self.navigation.kpan_speed * dt, 0)
    end
    if keyboard.is_key_down(keys.D) then
        self.levelstate.camera:move(self.navigation.kpan_speed * dt, 0)
    end

    -- zoom with arrows
    if keyboard.is_key_down(keys.E) then
        self.levelstate.camera:zoom_in(self.navigation.kzoom_speed * dt)
    end
    if keyboard.is_key_down(keys.Q) then
        self.levelstate.camera:zoom_out(self.navigation.kzoom_speed * dt)
    end
end

local function drawgrid(self)
    if self.grid.show then
        -- we transform the initial draw point once to avoid performing this costly operation for every single cell.
        local x, y = self.levelstate.camera:transform_point(0, 0)
        local advancex, advancey = x, y
        local scaledcellsz = self.grid.cell_size * self.levelstate.camera.zoom
        local mapwidth = self.levelstate.data.tilemap.width
        local mapheight = self.levelstate.data.tilemap.height

        graphics.set_draw_color(unpack(self.grid.color))
        for _ = 1, mapheight do
            for _ = 1, mapwidth do
                graphics.draw_rect(advancex, advancey, scaledcellsz, scaledcellsz)
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
    end
end

local function drawcommontools(self)
    local cam = self.levelstate.camera
    local resw, resh = graphics.get_resolution()

    -- bottom pannel
    local panelh = resh * 0.05
    gui:panel(0, resh - panelh, resw, panelh)

    -- draw fps
    gui:label(resw * 0.9, 5, format("FPS: %.0f", self.game.fps))

    -- mouse pos
    local msx, msy = cam:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(resw * 0.02, resh * 0.97, format("+ %.0f, %.0f", msx, msy))

    -- cam pos
    local cmx, cmy = cam.position[1], cam.position[2]
    gui:label(resw * 0.13, resh * 0.97, format("[ ] %.0f, %.0f", cmx, cmy))

    -- draw current layer num
    local selectedlayer = self.map.selected_layer
    local numlayers = #self.levelstate.data.tilemap.layers

    if self.map.onion then
        graphics.set_draw_color(1, 1, 0, 1)
    end
    gui:label(resw * 0.25, resh * 0.97, format("// %d/%d", selectedlayer, numlayers))

    -- zoom
    graphics.set_draw_color(1, 1, 1, 1)
    gui:label(resw * 0.95, resh * 0.97, format("%.0f%%", cam:get_zoom_percentage()))
end

-- LEFT PANEL
--=================================================
local function draw_left_panel()
    local resw, resh = graphics.get_resolution()
    gui:panel(0, 0, resw * 0.3, resh * 0.95)
    gui:label(5, 5, "Tiles")
end

--=================================================
-- TILE PICKER
--=================================================
local function draw_tile_picker(self)
    local grid = self.tile_picker.grid
    local tilesheet = self.levelstate.tilesheets[self.map.selected_layer]
    local cellsz = self.grid.cell_size
    local xoffset = self.tile_picker.offset.x
    local yoffset = self.tile_picker.offset.y

    for i = 1, #grid do
        for j = 1, #grid[i] do
            local src = grid[i][j].src
            drawx(tilesheet, xoffset, yoffset, src[1], src[2], cellsz, cellsz, 1, 1, 0)
            xoffset = xoffset + cellsz
        end
        xoffset = 5
        yoffset = yoffset + cellsz
    end
end

-- TODO: make command
local function try_pick_tile(self)
    local grid = self.tile_picker.grid
    local xoffset = self.tile_picker.offset.x
    local yoffset = self.tile_picker.offset.y
    local cellsz = self.grid.cell_size
    local tilex = (floor((self.mouse_state.x - xoffset) / cellsz) + 1)
    local tiley = (floor((self.mouse_state.y - yoffset) / cellsz) + 1)

    if grid[tiley] and grid[tiley][tilex] then
        self.tile_picker.selected = grid[tiley][tilex].id
        self.tile_picker.selected_src.x, self.tile_picker.selected_src.y =
            ((tilex - 1) * cellsz) + xoffset,
            ((tiley - 1) * cellsz) + yoffset
    end
end

local function highlight_selected_tile(self)
    if self.tile_picker.selected ~= 0 then
        setdrawcolor(table.unpack(self.tile_picker.selected_color))
        drawrect(
            self.tile_picker.selected_src.x,
            self.tile_picker.selected_src.y,
            self.grid.cell_size,
            self.grid.cell_size
        )
    end
end

--=================================================
-- PAINTING
--=================================================
-- TODO: make command
local function try_paint(self)
    local msx, msy = self.levelstate.camera:screen2world(self.mouse_state.x, self.mouse_state.y)
    local gridx = floor(msx / self.grid.cell_size) + 1
    local gridy = floor(msy / self.grid.cell_size) + 1
    local tiles = self.levelstate.data.tilemap.layers[self.map.selected_layer].tiles

    if mouse.is_button_down(mousebuttons.RIGHT) and tiles[gridy] and tiles[gridy][gridx] then
        -- erase and don't emulate selected tile on grid so we can see what we're erasing
        for i = 1, self.brushsize do
            local row = tiles[gridy + (i - 1)]
            for j = 1, self.brushsize do
                if row and row[gridx + (j - 1)] then
                    row[gridx + (j - 1)] = 0
                end
            end
        end
        return
    end

    if self.tile_picker.selected == 0 then
        return
    end

    if tiles[gridy] and tiles[gridy][gridx] then
        local tiledefs = self.levelstate.tilesets[self.map.selected_layer].tiledefs
        local tilesheet = self.levelstate.tilesheets[self.map.selected_layer]
        local selected = self.tile_picker.selected
        local tilesrc = tiledefs[selected].src
        local zoom = self.levelstate.camera.zoom
        local cellsz = self.grid.cell_size
        local scellsz = cellsz * zoom
        local x, y = self.levelstate.camera:transform_point(0, 0)

        -- emulate selected tile on grid
        graphics.set_draw_color(1, 1, 1, 0.5)
        drawx(
            tilesheet,
            x + ((gridx - 1) * scellsz),
            y + ((gridy - 1) * scellsz),
            tilesrc[1],
            tilesrc[2],
            cellsz,
            cellsz,
            zoom * self.brushsize,
            zoom * self.brushsize,
            0
        )

        if mouse.is_button_down(mousebuttons.LEFT) then
            -- paint
            for i = 1, self.brushsize do
                local row = tiles[gridy + (i - 1)]
                for j = 1, self.brushsize do
                    if row and row[gridx + (j - 1)] then
                        row[gridx + (j - 1)] = selected
                    end
                end
            end
        end
    end
end

function editstate:enter()
    window.set_title("OMRS Editor")

    self.game:insert(self.levelstate, 1)

    construct_tile_picker_grid(self)
end

function editstate:update(dt)
    handleinput(self, dt)

    local layers = self.levelstate.data.tilemap.layers
    local selectedlayer = self.map.selected_layer

    for i = 1, #layers do
        local color = layers[i].color

        if self.map.onion then
            if i < selectedlayer then
                color[1], color[2], color[3], color[4] = 0.25, 0.25, 0.25, 1
            elseif i > selectedlayer then
                color[1], color[2], color[3], color[4] = 0.4, 0.4, 0.4, 0.07
            else
                color[1], color[2], color[3], color[4] = 1, 1, 1, 1
            end
        else
            color[1], color[2], color[3], color[4] = 1, 1, 1, 1
        end
    end

    -- we don't want to update the scene, but we still need to refresh the go lists.
    self.levelstate:refreshgolists()
end

function editstate:draw()
    local resw, resh = graphics.get_resolution()

    drawgrid(self)
    drawcommontools(self)
    draw_left_panel()
    draw_tile_picker(self)

    -- only focus on the left panel if we are hovering over it, else focus on the map editing
    if is_mouse_over(self.mouse_state.x, self.mouse_state.y, 0, 0, resw * 0.3, resh * 0.95) then
        if mouse.is_button_pressed(mousebuttons.LEFT) then
            try_pick_tile(self)
        end
    else
        try_paint(self, editstate)
    end

    highlight_selected_tile(self)
end

return {
    new = new
}
