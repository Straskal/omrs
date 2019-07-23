local graphics = require("milk.graphics")
local tiny = require("thirdparty.tiny")
local gui = require("utils.gui")

local unpack = table.unpack
local setdrawcolor = graphics.set_draw_color
local drawfillrect = graphics.draw_filled_rect

local function new(editor)
    local shadow =
        tiny.system(
        {
            filter = function()
                return false
            end
        }
    )

    -- luacheck: push ignore self
    function shadow:update(_)
        editor.camera:calc_matrix()

        local mapwidth = editor.level.tilemap.width
        local mapheight = editor.level.tilemap.height
        local zoom = editor.camera.zoom
        local cellsz = editor.grid.cell_size
        local scaledcellsz = cellsz * editor.camera.zoom

        gui:begin_draw()

        -- draw map shadow
        setdrawcolor(unpack(editor.map.shadow.color))
        local shadowoffset = editor.map.shadow.offset
        local shadowx, shadowy = editor.camera:transform_point(shadowoffset, shadowoffset)

        drawfillrect(
            shadowx,
            shadowy,
            (mapwidth * scaledcellsz) + (shadowoffset * zoom),
            (mapheight * scaledcellsz) + (shadowoffset * zoom)
        )
    end
    -- luacheck: pop

    return shadow
end

return new
