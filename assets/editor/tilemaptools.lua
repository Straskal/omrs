local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local tiny = require("thirdparty.tiny")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons
local keys = keyboard.keys

--=================================================
-- local functions
--=================================================
local floor = math.floor
local setdrawcolor = graphics.set_draw_color
local drawx = graphics.drawx
local drawrect = graphics.draw_rect

local function is_mouse_over(mx, my, x, y, w, h)
    return mx > x and mx <= x + w and my > y and my <= y + h
end

local function handle_input(self, editstate)
    local ms = editstate.mouse_state

    if keyboard.is_key_down(keys.LCTRL) then
        if ms.scroll < 0 and self.brushsize < 10 then
            self.brushsize = self.brushsize + 1
        elseif ms.scroll > 0 and self.brushsize > 1 then
            self.brushsize = self.brushsize - 1
        end
    end
end

-- LEFT PANEL
--=================================================
local function draw_left_panel(self)
    local panelw, panelh = self.panel.w, self.panel.h
    gui:panel(0, 0, panelw, panelh)
    gui:label(5, 5, "Tiles")
end

--=================================================
-- TILE PICKER
--=================================================
local function draw_tile_picker(self, editstate)
    local grid = self.tile_picker.grid
    local tilesheet = editstate.tilesheet
    local cellsz = editstate.grid.cell_size
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
local function try_pick_tile(self, editstate)
    local grid = self.tile_picker.grid
    local xoffset = self.tile_picker.offset.x
    local yoffset = self.tile_picker.offset.y
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
    local msx, msy = editstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)
    local gridx = floor(msx / editstate.grid.cell_size) + 1
    local gridy = floor(msy / editstate.grid.cell_size) + 1
    local tiles = editstate.level.tilemap.layers[editstate.map.selected_layer].tiles

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
        local tiledefs = editstate.tileset.tiledefinitions
        local selected = self.tile_picker.selected
        local tilesrc = tiledefs[selected].src
        local zoom = editstate.camera.zoom
        local cellsz = editstate.grid.cell_size
        local scellsz = cellsz * zoom
        local x, y = editstate.camera:transform_point(0, 0)

        -- emulate selected tile on grid
        drawx(
            editstate.tilesheet,
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

--=================================================
-- TILE MAP TOOL STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
    - bucket tools
    - brush size
    - line drawing
    - square drawing
--]]
--=================================================
return function(editstate)
    local tools =
        tiny.system(
        {
            panel = {w = 138, h = 345},
            brushsize = 1,
            tile_picker = {
                grid = {},
                selected = 0,
                selected_src = {},
                offset = {x = 5, y = 30},
                selected_color = {1, 1, 1, 1}
            },
            filter = function()
                return false
            end
        }
    )

    function tools:onAddToWorld(_)
        -- create grid from array of tile definitions
        local tiledefs = editstate.tileset.tiledefinitions
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

    function tools:update(_)
        handle_input(self, editstate)
        draw_left_panel(self)
        draw_tile_picker(self, editstate)

        -- only focus on the left panel if we are hovering over it, else focus on the map editing
        if is_mouse_over(editstate.mouse_state.x, editstate.mouse_state.y, 0, 0, self.panel.w, self.panel.h) then
            if mouse.is_button_pressed(mousebuttons.LEFT) then
                try_pick_tile(self, editstate)
            end
        else
            try_paint(self, editstate)
        end

        highlight_selected_tile(self, editstate)
    end

    return tools
end
