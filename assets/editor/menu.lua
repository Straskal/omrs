local graphics = require("milk.graphics")
local gui = require("assets.utils.gui")

local menu = {}

local function open()
    menu.gui_layer = gui.new_layer()
end

-- TODO: Make these extensions of gui
local function btn_chill_left(guilayer, id, w, h, y, text)
    return guilayer:button(id, 15, y, w, h, text)
end

local function draw()
    graphics.set_draw_color(0.8, 0, 0, 1)
    gui.style.font:printx(15, _G.RESOLUTION.h * 0.95, "OMRS [defcolor] editor")

    menu.gui_layer:begin_frame()
    btn_chill_left(menu.gui_layer, 1, 60, 20, _G.RESOLUTION.h * 0.05, "file")
    btn_chill_left(menu.gui_layer, 2, 60, 20, _G.RESOLUTION.h * 0.12, "tiles")
    btn_chill_left(menu.gui_layer, 3, 60, 20, _G.RESOLUTION.h * 0.19, "objects")
    menu.gui_layer:end_frame()
end

return {
    open = open,
    draw = draw
}
