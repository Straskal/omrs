local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons

--=================================================
-- TILE MAP TOOL STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
    - layers
    - bucket tools
    - brush size
    - line drawing
    - square drawing
--]]
--=================================================
local tilemaptools = {
    panel = {w = 138, h = 345},
    tile_picker = {
        grid = {},
        selected = 0,
        selected_src = {},
        offset = {x = 5, y = 15},
        selected_color = {1, 1, 1, 1}
    }
}

function tilemaptools:open(editstate)
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

-- luacheck: push ignore
function tilemaptools:handle_input(editstate)
end

function tilemaptools:tick(editstate)
end
-- luacheck: pop

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
            graphics.drawx(tilesheet, xoffset, yoffset, src.x, src.y, cellsz, cellsz, 1, 1, 0)
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
    local tilex = (math.floor((editstate.mouse_state.x - xoffset) / cellsz) + 1)
    local tiley = (math.floor((editstate.mouse_state.y - yoffset) / cellsz) + 1)

    if grid[tiley] and grid[tiley][tilex] then
        self.tile_picker.selected = grid[tiley][tilex].id
        self.tile_picker.selected_src.x, self.tile_picker.selected_src.y =
            ((tilex - 1) * cellsz) + xoffset,
            ((tiley - 1) * cellsz) + yoffset
    end
end

local function highlight_selected_tile(self, editstate)
    if self.tile_picker.selected ~= 0 then
        graphics.set_draw_color(table.unpack(self.tile_picker.selected_color))
        graphics.draw_rect(
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
local function switch_tile_at_mouse(editstate, newtile)
    local msx, msy = editstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)
    local gridx = math.floor(msx / editstate.grid.cell_size) + 1
    local gridy = math.floor(msy / editstate.grid.cell_size) + 1
    local tiles = editstate.level.tilemap.tiles

    if tiles[gridy] and tiles[gridy][gridx] and tiles[gridy][gridx] ~= newtile then
        tiles[gridy][gridx] = newtile
    end
end

--=================================================
-- DRAW
--=================================================
local function is_mouse_over(mx, my, x, y, w, h)
    return mx > x and mx <= x + w and my > y and my <= y + h
end

function tilemaptools:draw(editstate)
    draw_left_panel(self)
    draw_tile_picker(self, editstate)

    -- only focus on the left panel if we are hovering over it, else focus on the map editing
    if is_mouse_over(editstate.mouse_state.x, editstate.mouse_state.y, 0, 0, self.panel.w, self.panel.h) then
        if mouse.is_button_pressed(mousebuttons.LEFT) then
            try_pick_tile(self, editstate)
        end
    elseif mouse.is_button_down(mousebuttons.LEFT) and self.tile_picker.selected ~= 0 then
        -- paint
        switch_tile_at_mouse(editstate, self.tile_picker.selected)
    elseif mouse.is_button_down(mousebuttons.RIGHT) then
        -- erase
        switch_tile_at_mouse(editstate, 0)
    end

    highlight_selected_tile(self, editstate)
end

return tilemaptools
