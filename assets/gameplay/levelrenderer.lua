local tiny = require("thirdparty.tiny")
local graphics = require("milk.graphics")

local drawx = graphics.drawx
local unpack = table.unpack

local function draw_tilemap(camera, tilemap, tiledefs, tilesheet)
    local x, y = camera:transform_point(0, 0)
    local advancex, advancey = x, y
    local mapwidth = tilemap.width
    local mapheight = tilemap.height
    local cellsz = tilemap.cellsize
    local scaledcellsz = cellsz * camera.zoom
    local numlayers = #tilemap.layers

    for i = 1, numlayers do
        local tiles = tilemap.layers[i].tiles

        graphics.set_draw_color(unpack(tilemap.layers[i].color))

        for j = 1, mapheight do
            for k = 1, mapwidth do
                local tiledef = tiles[j][k]
                -- if there is no tile here, skip drawing
                if tiledef > 0 then
                    local tilesrc = tiledefs[tiledef].src
                    drawx(
                        tilesheet,
                        advancex,
                        advancey,
                        tilesrc[1],
                        tilesrc[2],
                        cellsz,
                        cellsz,
                        camera.zoom,
                        camera.zoom,
                        0
                    )
                end
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
        advancex, advancey = x, y
    end
end

local function new(camera, tilemap, tiledefs, tilesheet)
    local render =
        tiny.sortedProcessingSystem(
        {
            clearcolor = {0, 0, 0, 1}
        }
    )
    render.filter = tiny.requireAll("image")

    -- luacheck: push ignore self
    function render:compare(e1, e2)
        local e1layer = e1.image.layer or 0
        local e2layer = e2.image.layer or 0
        return e1layer < e2layer
    end

    function render:onAdd(e, _)
        if not e.image.data then
            e.image.data = graphics.new_image(e.image.file)
        end
    end

    function render:preProcess(_)
        graphics.set_draw_color(unpack(self.clearcolor))
        graphics.clear()
        graphics.set_draw_color(1, 1, 1, 1)
        camera:calc_matrix()

        draw_tilemap(camera, tilemap, tiledefs, tilesheet)
    end

    function render:process(e, _)
        local px, py = camera:transform_point(unpack(e.position))
        local s = e.image.src
        graphics.drawx(e.image.data, px, py, s[1], s[2], s[3], s[4], 1, 1, 0)
    end
    -- luacheck: pop

    return render
end

return new
