local graphics = require("milk.graphics")
local mouse = require("milk.mouse")
local keyboard = require("milk.keyboard")
local gui = require("utils.gui")
local mousebuttons = mouse.buttons
local keys = keyboard.keys

local tilemaptools = {
    current_tile = 1
}

function tilemaptools:open(editstate)
end

function tilemaptools:handle_input(editstate)
    editstate.camera:calc_matrix()
    local msx, msy = editstate.camera:screen2world(editstate.mousex, editstate.mousey)

    if mouse.is_button_down(mousebuttons.LEFT) then
        local gridx = math.floor(msx / editstate.GRID_CELL_SIZE) + 1
        local gridy = math.floor(msy / editstate.GRID_CELL_SIZE) + 1
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
    gui:panel(0, 0, 128, 640)

    local src = editstate.tileset.tiledefinitions[self.current_tile].src
    graphics.drawx(
        editstate.tilesheet,
        10,
        10,
        src.x,
        src.y,
        editstate.GRID_CELL_SIZE,
        editstate.GRID_CELL_SIZE,
        1,
        1,
        0
    )
end

return tilemaptools
