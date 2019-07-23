local graphics = require("milk.graphics")
local tiny = require("thirdparty.tiny")
local gui = require("utils.gui")

local unpack = table.unpack
local format = string.format
local setdrawcolor = graphics.set_draw_color
local drawrect = graphics.draw_rect

return function(editor, game)
    local tools =
        tiny.system(
        {
            filter = function()
                return false
            end
        }
    )

    -- luacheck: push ignore self
    function tools:postWrap(_)
        gui:end_draw()
    end

    function tools:update(_)
        if editor.grid.show then
            -- we transform the initial draw point once to avoid performing this costly operation for every single cell.
            local x, y = editor.camera:transform_point(0, 0)
            local advancex, advancey = x, y
            local scaledcellsz = editor.grid.cell_size * editor.camera.zoom
            local mapwidth = editor.level.tilemap.width
            local mapheight = editor.level.tilemap.height

            setdrawcolor(unpack(editor.grid.color))
            for _ = 1, mapheight do
                for _ = 1, mapwidth do
                    drawrect(advancex, advancey, scaledcellsz, scaledcellsz)
                    advancex = advancex + scaledcellsz
                end
                advancex = x
                advancey = advancey + scaledcellsz
            end
        end

        local cam = editor.camera

        -- bottom pannel
        gui:panel(0, 345, 640, 15)

        -- draw level name
        gui:label(350, 5, editor.level.name)

        -- draw fps
        gui:label(590, 5, format("FPS: %.0f", game.fps))

        -- mouse pos
        local msx, msy = cam:screen2world(editor.mouse_state.x, editor.mouse_state.y)
        gui:label(10, 350, format("+ %.0f, %.0f", msx, msy))

        -- cam pos
        local cmx, cmy = cam.position[1], cam.position[2]
        gui:label(80, 350, format("[ ] %.0f, %.0f", cmx, cmy))

        -- draw current layer num
        local selectedlayer = editor.map.selected_layer
        local numlayers = #editor.level.tilemap.layers
        if editor.map.onion then
            setdrawcolor(1, 1, 0, 1)
        end
        gui:label(160, 350, format("// %d/%d", selectedlayer, numlayers))

        -- zoom
        setdrawcolor(1, 1, 1, 1)
        gui:label(615, 350, format("%.0f%%", cam:get_zoom_percentage()))
    end
    -- luacheck: pop

    return tools
end
