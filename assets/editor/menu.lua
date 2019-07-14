local graphics = require("milk.graphics")
local gui = require("assets.utils.gui")

local menu = {
    isopen = false
}

local function open()
    menu.gui_layer = gui.new_layer()
    menu.isopen = true
end

local function close()
    menu.gui_layer:pop()
    menu.isopen = false
end

local function toggle()
    if menu.isopen then
        close()
    else
        open()
    end
end

local function draw()
    if menu.isopen then
        menu.gui_layer:begin_frame()
        menu.gui_layer:panel(0, 0, _G.RESOLUTION.w * 0.22, _G.RESOLUTION.h * 1)
        if menu.gui_layer:button(1, _G.RESOLUTION.w * 0.01, _G.RESOLUTION.h * 0.01, 60, 20, "lvls") then
        end
        if menu.gui_layer:button(2, _G.RESOLUTION.w * 0.11, _G.RESOLUTION.h * 0.01, 60, 20, "tiles") then
        end
        if menu.gui_layer:button(3, _G.RESOLUTION.w * 0.01, _G.RESOLUTION.h * 0.07, 60, 20, "objs") then
        end
        menu.gui_layer:end_frame()

        graphics.set_draw_color(0.8, 0, 0, 1)
        gui.style.font:printx(15, _G.RESOLUTION.h * 0.95, "OMRS [defcolor] editor")
    end
end

return {
    toggle = toggle,
    draw = draw
}
