local mouse = require("milk.mouse")
local graphics = require("milk.graphics")
local font = require("assets.utils.font")
local mouse_buttons = mouse.buttons

-- TODO
local gui = {}
local Layer_mt = {}

function gui.init()
    gui.style = {
        font = font.new_font(graphics.new_image("assets/utils/font.png"), -11, -3, 0.35),
        panel = {
            color = {0.3, 0.3, 0.3, 0.7}
        },
        button = {
            default_color = {0.3, 0.3, 0.3, 1},
            hot_color = {0.5, 0.1, 0.1, 1},
            active_color = {0.1, 0.2, 0.8, 1},
            disabled_color = {0.3, 0.3, 0.3, 1}
        }
    }
    gui.layers = 0
end

local function is_mouse_hover(mx, my, x, y, w, h)
    return mx > x and mx <= x + w and my > y and my <= y + h
end

local function push_id()
    gui.layers = gui.layers + 1
    return gui.layers
end

local function pop_id()
    gui.layers = gui.layers - 1
end

local function enabled(layer_id)
    return layer_id == gui.layers
end

function gui.new_layer()
    local self = {}
    self.layer_id = push_id()
    self.mousex = 0
    self.mousey = 0
    self.is_down = false
    self.hot_id = -1
    self.active_id = -1
    setmetatable(self, {__index = Layer_mt})
    return self
end

function Layer_mt:begin_frame()
    self.hot_id = 0
    self.mousex, self.mousey = mouse.get_position()
    self.is_down = mouse.is_button_down(mouse_buttons.LEFT)
end

function Layer_mt:end_frame()
    if not self.is_down then
        self.active_id = 0
    elseif self.active_id == 0 then
        self.active_id = -1
    end
end

-- luacheck: push ignore self
function Layer_mt:pop()
    pop_id()
end

function Layer_mt:panel(x, y, w, h)
    graphics.set_draw_color(table.unpack(gui.style.panel.color))
    graphics.draw_filled_rect(x, y, w, h)
end
-- luacheck: pop

function Layer_mt:button(id, x, y, w, h, text)
    if not enabled(self.layer_id) then
        graphics.set_draw_color(table.unpack(gui.style.button.disabled_color))
        graphics.draw_filled_rect(x, y, w, h)
        graphics.set_draw_color(1, 1, 1, 1)
        gui.style.font:printx(x + 10, y + 10, text, w / gui.style.font.spacex)
        return false
    end
    if is_mouse_hover(self.mousex, self.mousey, x, y, w, h) then
        self.hot_id = id
        if self.active_id == 0 and self.is_down then
            self.active_id = id
        end
    end
    if self.hot_id == id then
        if self.active_id == id then
            graphics.set_draw_color(table.unpack(gui.style.button.active_color))
        else
            graphics.set_draw_color(table.unpack(gui.style.button.hot_color))
        end
    else
        graphics.set_draw_color(table.unpack(gui.style.button.default_color))
    end
    graphics.draw_filled_rect(x, y, w, h)
    graphics.set_draw_color(1, 1, 1, 1)
    gui.style.font:print_bound(x, y, w, h, text)
    -- if button is not down but control is hot and active then the user has clicked this button
    return not self.is_down and self.hot_id == id and self.active_id == id
end

function Layer_mt:imagebutton(id, x, y, image, src_rect)
    if not enabled(self.layer_id) then
        graphics.set_draw_color(table.unpack(gui.style.button.disabled_color))
        graphics.drawx(image, x, y, src_rect.x, src_rect.y, src_rect.w, src_rect.h, 1, 1, 0)
        return false
    end
    if is_mouse_hover(self.mousex, self.mousey, x, y, src_rect.w, src_rect.h) then
        self.hot_id = id
        if self.active_id == 0 and self.is_down then
            self.active_id = id
        end
    end
    if self.hot_id == id then
        if self.active_id == id then
            graphics.set_draw_color(table.unpack(gui.style.button.active_color))
        else
            graphics.set_draw_color(table.unpack(gui.style.button.hot_color))
        end
    else
        graphics.set_draw_color(table.unpack(gui.style.button.default_color))
    end
    graphics.drawx(image, x, y, src_rect.x, src_rect.y, src_rect.w, src_rect.h, 1, 1, 0)
    -- if button is not down but control is hot and active then the user has clicked this button
    return not self.is_down and self.hot_id == id and self.active_id == id
end

return gui
