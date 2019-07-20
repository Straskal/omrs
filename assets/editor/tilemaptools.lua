local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons

--=================================================
-- TILE MAP TOOL STATE
--[[
    TODO:
    - undo, redo for paint tools @matt ames
--]]
--=================================================
local tilemaptools = {
    panel = {w = 138, h = 640},
    tile_grid = {},
    selected_tile = 0,
    selected_tile_src = {},
    tilepicker_offset = {x = 5, y = 15}
}

function tilemaptools:open(editstate)
    -- create grid from tile definitions
    local tiledefs = editstate.tileset.tiledefinitions
    local rows = math.ceil(#tiledefs / 4)

    local curr = 1
    for i = 1, rows do
        self.tile_grid[i] = {}
        for j = 1, 4 do
            if curr > #tiledefs then
                break
            end
            self.tile_grid[i][j] = tiledefs[curr]
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
    local tilesheet = editstate.tilesheet
    local cellsz = editstate.grid_cell_size
    local xoffset = self.tilepicker_offset.x
    local yoffset = self.tilepicker_offset.y
    for i = 1, #self.tile_grid do
        for j = 1, #self.tile_grid[i] do
            local src = self.tile_grid[i][j].src
            graphics.drawx(tilesheet, xoffset, yoffset, src.x, src.y, cellsz, cellsz, 1, 1, 0)
            xoffset = xoffset + cellsz
        end
        xoffset = 5
        yoffset = yoffset + cellsz
    end
end

local function try_pick_tile(self, editstate)
    local xoffset = self.tilepicker_offset.x
    local yoffset = self.tilepicker_offset.y
    local tilex = (math.floor((editstate.mouse_state.x - xoffset) / editstate.grid_cell_size) + 1)
    local tiley = (math.floor((editstate.mouse_state.y - yoffset) / editstate.grid_cell_size) + 1)
    if self.tile_grid[tiley] and self.tile_grid[tiley][tilex] then
        self.selected_tile = self.tile_grid[tiley][tilex].id
        self.selected_tile_src.x, self.selected_tile_src.y =
            ((tilex - 1) * editstate.grid_cell_size) + xoffset,
            ((tiley - 1) * editstate.grid_cell_size) + yoffset
    end
end

local function highlight_selected_tile(self, editstate)
    if self.selected_tile ~= 0 then
        graphics.set_draw_color(1, 1, 1, 1)
        graphics.draw_rect(
            self.selected_tile_src.x,
            self.selected_tile_src.y,
            editstate.grid_cell_size,
            editstate.grid_cell_size
        )
    end
end

--=================================================
-- PAINTING
--=================================================
local function switch_tile_at_mouse(editstate, newtile)
    local msx, msy = editstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)
    local gridx = math.floor(msx / editstate.grid_cell_size) + 1
    local gridy = math.floor(msy / editstate.grid_cell_size) + 1
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
    elseif mouse.is_button_down(mousebuttons.LEFT) and self.selected_tile ~= 0 then
        switch_tile_at_mouse(editstate, self.selected_tile)
    elseif mouse.is_button_down(mousebuttons.RIGHT) then
        switch_tile_at_mouse(editstate, 0)
    end

    highlight_selected_tile(self, editstate)
end

return tilemaptools
