local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local keyboard = require("milk.keyboard")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons
local keys = keyboard.keys

local tilemaptools = {
    display_name = "tile",
    current_tile = 1
}

function tilemaptools:open(editstate)
end

function tilemaptools:handle_input(editstate)
    editstate.camera:calc_matrix()
    local msx, msy = editstate.camera:screen2world(editstate.mouse_state.x, editstate.mouse_state.y)

    if mouse.is_button_down(mousebuttons.LEFT) then
        local gridx = math.floor(msx / editstate.grid_cell_size) + 1
        local gridy = math.floor(msy / editstate.grid_cell_size) + 1
        local tiles = editstate.level.tilemap.tiles
        if tiles[gridy] and tiles[gridy][gridx] then
            tiles[gridy][gridx] = self.current_tile
        end
    end

    local tiletoggle = 0
    if keyboard.is_key_pressed(keys.UP) then
        tiletoggle = 1
    end
    if keyboard.is_key_pressed(keys.DOWN) then
        tiletoggle = -1
    end
    if tiletoggle ~= 0 then
        local newtile = self.current_tile + tiletoggle
        local numtiles = #editstate.tileset.tiledefinitions
        if newtile > numtiles then
            newtile = 1
        else
            newtile = numtiles
        end
        self.current_tile = newtile
    end
end

function tilemaptools:tick(editstate)
end

function tilemaptools:draw(editstate)
    local panelw, panelh = 128, 640
    gui:panel(0, 0, panelw, panelh)

    local xpos = 0
    local ypos = 0
    local tiledefs = editstate.tileset.tiledefinitions
    for i = 1, #tiledefs do
        local src = tiledefs[i].src
        graphics.drawx(
            editstate.tilesheet,
            xpos,
            ypos,
            src.x,
            src.y,
            editstate.grid_cell_size,
            editstate.grid_cell_size,
            1,
            1,
            0
        )
        xpos = xpos + editstate.grid_cell_size
        if xpos + editstate.grid_cell_size > panelw then
            xpos = 0
            ypos = ypos + editstate.grid_cell_size
        end
    end
end

return tilemaptools
