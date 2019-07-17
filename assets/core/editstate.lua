local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local camera = require("utils.camera")
local font = require("utils.font")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

local editstate = {
    camera = camera.new(),
    mousex = 0,
    mousey = 0,
    pmousex = 0,
    pmousey = 0,
    options = {
        showgrid = true,
        panspeed = 40
    }
}

local function update_mouse(self)
    self.pmousex, self.pmousey = self.mousex, self.mousey
    self.mousex, self.mousey = mouse.get_position()
    self.font = font.new(graphics.new_image("assets/utils/font.png"), -11, -3, 0.35)
end

local function handle_input(self, dt)
    update_mouse(self)

    local scroll = mouse.get_scroll()
    if scroll > 0 then
        self.camera:zoom_in(0.5)
    elseif scroll < 0 then
        self.camera:zoom_out(0.5)
    end

    if mouse.is_button_down(mousebuttons.RIGHT) then
        local pmsx, pmsy = self.pmousex, self.pmousey
        local panspeed = self.options.panspeed
        local new_cam_posx = (pmsx - self.mousex) * panspeed * dt
        local new_cam_posy = (pmsy - self.mousey) * panspeed * dt
        self.camera:move(new_cam_posx, new_cam_posy)
    end

    if keyboard.is_key_down(keys.LSHIFT) then
        if keyboard.is_key_released(keys.G) then
            self.showgrid = not self.showgrid
        end
    end
end

function editstate:on_enter()
    local resw, resh = graphics.get_resolution()
    self.camera.positionx, self.camera.positiony = resw / 2, resh / 2
    self.image = graphics.new_image("assets/player/omrs.png")
    self.imagepos = {0, 0}

    self.mousex, self.mousey = mouse.get_position()
    self.pmousex, self.pmousey = self.mousex, self.mousey
end

function editstate:on_tick(_, dt)
    handle_input(self, dt)
    self.camera:calc_matrix()
    local msx, msy = mouse.get_position()
    local scrnmsx, scrnmsy = self.camera:screen2world(msx, msy)
    print(scrnmsx .. ":" .. scrnmsy)
end

function editstate:on_draw(_, _)
    if self.showgrid then
        graphics.set_draw_color(0.1, 0.1, 0.1, 1)
        for i = 1, 15 do
            for j = 1, 20 do
                self.camera:draw_rect((j - 1) * 32, (i - 1) * 32, 32, 32)
            end
        end
    end
    graphics.set_draw_color(1, 1, 1, 1)
    self.camera:draw(self.image, self.imagepos[1], self.imagepos[2], 0, 0, 32, 32)
end

-- luacheck: ignore
function editstate:on_stop(_, dt)
end
-- luacheck: pop

return editstate
