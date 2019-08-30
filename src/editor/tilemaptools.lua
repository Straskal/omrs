local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local gui = require("gui")

--=================================================
-- locals
--=================================================
local keys = keyboard.keys
local mousebuttons = mouse.buttons
local floor = math.floor
local setdrawcolor = graphics.set_draw_color
local drawx = graphics.drawx
local drawrect = graphics.draw_rect

local tilemaptools = {}

local function new()
    return setmetatable(
        {
            panel = {
                rect = {
                    x = 0,
                    y = 0,
                    w = 0.25,
                    h = 0.95 -- because of the lower tool bar common control.
                }
            },
            brush = {
                size = 1
            },
            tile_picker = {
                offset = {x = 0.01, y = 0.05},
                grid = {},
                selected = 0,
                selected_src = {},
                selected_color = {1, 1, 1, 1}
            },
            map = {
                selected_layer = 1,
                onion = false
            }
        },
        {__index = tilemaptools}
    )
end

local function is_mouse_over(mx, my, x, y, w, h)
    return (mx > x) and (mx <= x + w) and (my > y) and (my <= y + h)
end

local function construct_tile_picker_grid(self, editstate)
    -- create grid from array of tile definitions
    local resw, _ = graphics.get_resolution()
    local panelw = resw * self.panel.rect.w
    local cellsz = editstate.grid.cell_size
    local tiledefs = editstate.levelstate.tilesets[self.map.selected_layer].tiledefs
    local grid = self.tile_picker.grid
    local columns = math.min(floor(panelw / cellsz), 8)

    local panel_grid_diff_inpixels = (panelw - (cellsz * columns))
    self.tile_picker.offset.x = (panel_grid_diff_inpixels / 2) / resw

    local curr = 1
    local col = 1
    local row = 1
    grid[row] = {}

    while curr <= #tiledefs do
        grid[row][col] = tiledefs[curr]
        col = col + 1
        curr = curr + 1
        if col > columns then
            col = 1
            row = row + 1
            grid[row] = {}
        end
    end
end

function tilemaptools:handle_input(editstate, _)
    local ms = editstate.mouse_state

    -- toggle layer
    if keyboard.is_key_released(keys.TAB) then
        local nextlayer = self.map.selected_layer + 1
        if nextlayer > #editstate.levelstate.data.tilemap.layers then
            nextlayer = 1
        end
        self.map.selected_layer = nextlayer
        self.tile_picker.selected = 0

        -- we show the current tileset associated with the selected layer
        construct_tile_picker_grid(self, editstate)
    end

    -- CRTL+
    if keyboard.is_key_down(keys.LCTRL) then
        -- SCROLL: change brush size
        if ms.scroll > 0 and self.brush.size > 1 then
            self.brush.size = self.brush.size - 1
        elseif ms.scroll < 0 and self.brush.size < 10 then
            self.brush.size = self.brush.size + 1
        end

        -- O: toggle map onion layers
        if keyboard.is_key_released(keys.O) then
            self.map.onion = not self.map.onion
        end

        -- DOWN: add row to map
        if keyboard.is_key_released(keys.DOWN) then
            local tilemap = editstate.levelstate.data.tilemap

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
            local tilemap = editstate.levelstate.data.tilemap

            for i = 1, #tilemap.layers do
                tilemap.layers[i].tiles[tilemap.height] = nil
            end
            tilemap.height = tilemap.height - 1
        end

        -- RIGHT: add column to map
        if keyboard.is_key_released(keys.RIGHT) then
            local tilemap = editstate.levelstate.data.tilemap

            tilemap.width = tilemap.width + 1
            for i = 1, #tilemap.layers do
                for j = 1, #tilemap.layers[i].tiles do
                    tilemap.layers[i].tiles[j][tilemap.width] = 0
                end
            end
        end

        -- LEFT: remove column from map
        if keyboard.is_key_released(keys.LEFT) then
            local tilemap = editstate.levelstate.data.tilemap

            for i = 1, #tilemap.layers do
                for j = 1, #tilemap.layers[i].tiles do
                    tilemap.layers[i].tiles[j][tilemap.width] = nil
                end
            end
            tilemap.width = tilemap.width - 1
        end
    end
end

-- LEFT PANEL
--=================================================
local function draw_left_panel(self)
    local resw, resh = graphics.get_resolution()
    local panel = self.panel.rect

    gui:panel(panel.x, panel.y, panel.w * resw, panel.h * resh)
    gui:label(5, 5, "Tiles")
end

--=================================================
-- TILE PICKER
--=================================================
local function draw_tile_picker(self, editstate)
    local resw, resh = graphics.get_resolution()
    local grid = self.tile_picker.grid
    local selected_layer = self.map.selected_layer
    local tilesheet = editstate.levelstate.tilesheets[selected_layer]
    local cellsz = editstate.grid.cell_size
    local xoffset = self.tile_picker.offset.x * resw
    local yoffset = self.tile_picker.offset.y * resh

    for i = 1, #grid do
        for j = 1, #grid[i] do
            local src = grid[i][j].src

            drawx(tilesheet, xoffset, yoffset, src[1], src[2], cellsz, cellsz, 1, 1, 0)
            xoffset = xoffset + cellsz
        end
        xoffset = self.tile_picker.offset.x * resw
        yoffset = yoffset + cellsz
    end
end

-- TODO: make command
local function try_pick_tile(self, editstate)
    local resw, resh = graphics.get_resolution()
    local grid = self.tile_picker.grid
    local xoffset = self.tile_picker.offset.x * resw
    local yoffset = self.tile_picker.offset.y * resh
    local cellsz = editstate.grid.cell_size
    local tilex = (floor((editstate.mouse_state.x - xoffset) / cellsz) + 1)
    local tiley = (floor((editstate.mouse_state.y - yoffset) / cellsz) + 1)

    if grid[tiley] and grid[tiley][tilex] then
        self.tile_picker.selected = grid[tiley][tilex].id
        self.tile_picker.selected_src.x, self.tile_picker.selected_src.y =
            ((tilex - 1) * cellsz) + xoffset,
            ((tiley - 1) * cellsz) + yoffset
    end
end

local function highlight_selected_tile(self, editstate)
    if self.tile_picker.selected ~= 0 then
        setdrawcolor(table.unpack(self.tile_picker.selected_color))
        drawrect(
            self.tile_picker.selected_src.x,
            self.tile_picker.selected_src.y,
            editstate.grid.cell_size,
            editstate.grid.cell_size
        )
    end
end

--=================================================
-- PAINTING
--=================================================
-- TODO: make command
local function try_paint(self, editstate)
    local msx, msy = editstate.levelstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)
    local gridx = floor(msx / editstate.grid.cell_size) + 1
    local gridy = floor(msy / editstate.grid.cell_size) + 1
    local tiles = editstate.levelstate.data.tilemap.layers[self.map.selected_layer].tiles

    if mouse.is_button_down(mousebuttons.RIGHT) and tiles[gridy] and tiles[gridy][gridx] then
        -- erase and don't emulate selected tile on grid so we can see what we're erasing
        for i = 1, self.brush.size do
            local row = tiles[gridy + (i - 1)]
            for j = 1, self.brush.size do
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
        local tiledefs = editstate.levelstate.tilesets[self.map.selected_layer].tiledefs
        local tilesheet = editstate.levelstate.tilesheets[self.map.selected_layer]
        local selected = self.tile_picker.selected
        local tilesrc = tiledefs[selected].src
        local zoom = editstate.levelstate.camera.zoom
        local cellsz = editstate.grid.cell_size
        local scellsz = cellsz * zoom
        local x, y = editstate.levelstate.camera:transform_point(0, 0)

        -- emulate selected tile on grid
        setdrawcolor(1, 1, 1, 0.5)
        drawx(
            tilesheet,
            x + ((gridx - 1) * scellsz),
            y + ((gridy - 1) * scellsz),
            tilesrc[1],
            tilesrc[2],
            cellsz,
            cellsz,
            zoom * self.brush.size,
            zoom * self.brush.size,
            0
        )

        if mouse.is_button_down(mousebuttons.LEFT) then
            -- paint
            for i = 1, self.brush.size do
                local row = tiles[gridy + (i - 1)]
                for j = 1, self.brush.size do
                    if row and row[gridx + (j - 1)] then
                        row[gridx + (j - 1)] = selected
                    end
                end
            end
        end
    end
end

function tilemaptools:enter(editstate)
    construct_tile_picker_grid(self, editstate)
end

function tilemaptools:update(editstate, _)
    local layers = editstate.levelstate.data.tilemap.layers
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
end

function tilemaptools:draw(editstate)
    local resw, resh = graphics.get_resolution()

    draw_left_panel(self)
    draw_tile_picker(self, editstate)

    -- only focus on the left panel if we are hovering over it, else focus on the map editing
    if is_mouse_over(editstate.mouse_state.x, editstate.mouse_state.y, 0, 0, resw * 0.3, resh * 0.95) then
        if mouse.is_button_pressed(mousebuttons.LEFT) then
            try_pick_tile(self, editstate)
        end
    else
        try_paint(self, editstate)
    end

    highlight_selected_tile(self, editstate)
end

return {
    new = new
}
