local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local camera = require("utils.camera")
local gui = require("utils.gui")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

local GRID_CELL_SIZE = 32

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

local function handle_mouse(self, dt)
    -- update previous and current positions
    self.pmousex, self.pmousey = self.mousex, self.mousey
    self.mousex, self.mousey = mouse.get_position()

    -- zoom
    local scroll = mouse.get_scroll()
    if scroll > 0 then
        self.camera:zoom_in(0.5)
    elseif scroll < 0 then
        self.camera:zoom_out(0.5)
    end

    -- pan
    if mouse.is_button_down(mousebuttons.RIGHT) then
        local pmsx, pmsy = self.pmousex, self.pmousey
        local panspeed = self.options.panspeed
        local new_cam_posx = (pmsx - self.mousex) * panspeed * dt
        local new_cam_posy = (pmsy - self.mousey) * panspeed * dt
        self.camera:move(new_cam_posx, new_cam_posy)
    end
end

local function handle_keyboard(self)
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
    handle_mouse(self, dt)
    handle_keyboard(self)
end

local function draw_grid(self)
    if self.showgrid then
        graphics.set_draw_color(0.1, 0.1, 0.1, 1)
        for i = 1, 15 do
            for j = 1, 20 do
                self.camera:draw_rect(
                    (j - 1) * GRID_CELL_SIZE,
                    (i - 1) * GRID_CELL_SIZE,
                    GRID_CELL_SIZE,
                    GRID_CELL_SIZE
                )
            end
        end
    end

    local msx, msy = self.camera:screen2world(self.mousex, self.mousey)
    gui:label(10, 340, string.format("Mouse: %0.2f, %0.2f", msx, msy))
end

function editstate:on_draw(_, _)
    draw_grid(self)

    self.camera:calc_matrix()
    self.camera:draw(self.image, self.imagepos[1], self.imagepos[2], 0, 0, 32, 32)
end

-- luacheck: ignore
function editstate:on_stop(_, dt)
end
-- luacheck: pop

return editstate
