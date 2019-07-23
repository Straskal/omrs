local graphics = require("milk.graphics")
local camera = require("camera")

local unpack = table.unpack
local drawx = graphics.drawx

local levelstate = {}

local function new(levelfile)
    local instance = {
        camera = camera.new(),
        file = levelfile,
        data = {},
        tilesets = {},
        tilesheets = {}
    }
    setmetatable(instance, {__index = levelstate})
    return instance
end

function levelstate:enter(_)
    -- load level and resources
    local data = dofile(self.file)
    local layers = data.tilemap.layers

    for i = 1, #layers do
        local tileset = dofile(layers[i].tilesetfile)
        self.tilesets[i] = tileset
        self.tilesheets[i] = graphics.new_image(tileset.imagefile)
    end

    self.data = data
end

local function draw_tilemap(self)
    local cam = self.camera
    local tilemap = self.data.tilemap
    local tilesets = self.tilesets
    local tilesheets = self.tilesheets
    local x, y = cam:transform_point(0, 0)
    local advancex, advancey = x, y
    local mapwidth = tilemap.width
    local mapheight = tilemap.height
    local cellsz = tilemap.cellsize
    local scaledcellsz = cellsz * cam.zoom
    local numlayers = #tilemap.layers

    for i = 1, numlayers do
        local tiles = tilemap.layers[i].tiles
        local defs = tilesets[i].tiledefs
        local sheet = tilesheets[i]

        graphics.set_draw_color(unpack(tilemap.layers[i].color))

        for j = 1, mapheight do
            for k = 1, mapwidth do
                local tiledef = tiles[j][k]
                -- if there is no tile here, skip drawing
                if tiledef > 0 then
                    local tilesrc = defs[tiledef].src
                    drawx(sheet, advancex, advancey, tilesrc[1], tilesrc[2], cellsz, cellsz, cam.zoom, cam.zoom, 0)
                end
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
        advancex, advancey = x, y
    end
end

-- luacheck: push ignore
function levelstate:update(game, dt)
end

function levelstate:draw(game, dt)
    draw_tilemap(self)
end

function levelstate:exit(game)
end
-- luacheck: pop

return new
