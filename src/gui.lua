local mouse = require("milk.mouse")
local graphics = require("milk.graphics")
local font = require("font")
local mouse_buttons = mouse.buttons

local unpack = table.unpack
local setdrawcolor = graphics.set_draw_color
local drawrect = graphics.draw_rect
local drawfillrect = graphics.draw_filled_rect

local gui = {}

function gui:init()
    self.state = {
        mousex = 0,
        mousey = 0,
        is_down = false,
        hot_id = -1,
        active_id = -1
    }
    self.style = {
        font_color = {1, 1, 1, 1},
        font = font.new(graphics.new_image("assets/font.png"), -11, -3, 0.2),
        panel = {
            color = {0, 0, 0, 0.75}
        },
        button = {
            default_color = {0.3, 0.3, 0.3, 1},
            hot_color = {0.5, 0.1, 0.1, 1},
            active_color = {0.1, 0.2, 0.8, 1},
            disabled_color = {0.3, 0.3, 0.3, 1}
        }
    }
end

function gui:begin_draw()
    self.hot_id = 0
    self.mousex, self.mousey = mouse.get_position()
    self.is_down = mouse.is_button_down(mouse_buttons.LEFT)
end

function gui:end_draw()
    if not self.is_down then
        self.active_id = 0
    elseif self.active_id == 0 then
        self.active_id = -1
    end
end

-- CONTROLS
--==========================================================
local function is_mouse_over(mx, my, x, y, w, h)
    return mx > x and mx <= x + w and my > y and my <= y + h
end

--==========================================================
-- LABEL
--==========================================================
function gui:label(x, y, txt)
    graphics.set_draw_color(unpack(self.style.font_color))
    self.style.font:print(x, y, txt)
end

--==========================================================
-- PANEL
--==========================================================
-- luacheck: push ignore self
function gui:panel(x, y, w, h)
    setdrawcolor(table.unpack(gui.style.panel.color))
    drawfillrect(x, y, w, h)
    setdrawcolor(1, 1, 1, 1)
end
-- luacheck: pop

function gui:checkbox(id, obj, boolprop, x, y, w, h)
    if is_mouse_over(self.mousex, self.mousey, x, y, w, h) then
        self.hot_id = id
        if self.active_id == 0 and self.is_down then
            self.active_id = id
        end
    end

    local clicked = not self.is_down and self.hot_id == id and self.active_id == id
    if clicked then
        obj[boolprop] = not obj[boolprop]
    end

    setdrawcolor(1, 1, 1, 1)
    if obj[boolprop] then
        drawfillrect(x, y, w, h)
    else
        drawrect(x, y, w, h)
    end
end

--==========================================================
-- BUTTON
--==========================================================
function gui:button(id, x, y, w, h, text)
    if is_mouse_over(self.mousex, self.mousey, x, y, w, h) then
        self.hot_id = id
        if self.active_id == 0 and self.is_down then
            self.active_id = id
        end
    end
    if self.hot_id == id then
        if self.active_id == id then
            setdrawcolor(table.unpack(gui.style.button.active_color))
        else
            setdrawcolor(table.unpack(gui.style.button.hot_color))
        end
    else
        setdrawcolor(table.unpack(gui.style.button.default_color))
    end
    drawfillrect(x, y, w, h)
    setdrawcolor(1, 1, 1, 1)
    gui.style.font:print_bound(x, y, w, h, text)
    -- if button is not down but control is hot and active then the user has clicked this button
    return not self.is_down and self.hot_id == id and self.active_id == id
end

return gui
