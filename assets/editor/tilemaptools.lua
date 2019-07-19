local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons

local tilemaptools = {
    display_name = "tile",
    current_tile = 0,
    tile_grid = {},
    selected_tile_src = {}
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

function tilemaptools:draw(editstate)
    -- panel and title
    local panelw, panelh = 128 + 10, 640
    gui:panel(0, 0, panelw, panelh)
    gui:label(5, 5, "Tiles")

    -- draw tile pickers
    local tilesheet = editstate.tilesheet
    local cellsz = editstate.grid_cell_size
    local xoffset = 5
    local yoffset = 15
    for i = 1, #self.tile_grid do
        for j = 1, #self.tile_grid[i] do
            local src = self.tile_grid[i][j].src
            graphics.drawx(tilesheet, xoffset, yoffset, src.x, src.y, cellsz, cellsz, 1, 1, 0)
            xoffset = xoffset + cellsz
        end
        xoffset = 5
        yoffset = yoffset + cellsz
    end

    if mouse.is_button_pressed(mousebuttons.LEFT) then
        -- handling picking tile
        local tilex = (math.floor((editstate.mouse_state.x - 5) / editstate.grid_cell_size) + 1)
        local tiley = (math.floor((editstate.mouse_state.y - 15) / editstate.grid_cell_size) + 1)
        if self.tile_grid[tiley] and self.tile_grid[tiley][tilex] then
            self.current_tile = self.tile_grid[tiley][tilex].id
            self.selected_tile_src.x, self.selected_tile_src.y = ((tilex - 1) * cellsz) + 5, ((tiley - 1) * cellsz) + 15
        end
    elseif mouse.is_button_down(mousebuttons.LEFT) and self.current_tile ~= 0 then
        -- or painting tile
        local msx, msy = editstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)
        local gridx = math.floor(msx / editstate.grid_cell_size) + 1
        local gridy = math.floor(msy / editstate.grid_cell_size) + 1
        local tiles = editstate.level.tilemap.tiles
        if tiles[gridy] and tiles[gridy][gridx] then
            tiles[gridy][gridx] = self.current_tile
        end
    end
    if self.current_tile ~= 0 then
        graphics.set_draw_color(1, 1, 1, 1)
        graphics.draw_rect(self.selected_tile_src.x, self.selected_tile_src.y, cellsz, cellsz)
    end
end

return tilemaptools
