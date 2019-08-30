local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local levelstate = require("levelstate")
local gui = require("gui")
local tilemaptools = require("editor.tilemaptools")
require("libs.persistence") -- global

--=================================================
-- locals
--=================================================
local unpack = table.unpack
local format = string.format
local mousebuttons = mouse.buttons
local keys = keyboard.keys

local editstate = {}

--=================================================
-- EDITOR STATE
--[[
    TODO:
    - command queue, undo and redo
    - auto populate level data for empty files
    - show/hide gameobjects
--]]
--=================================================
local function new(levelfile)
    return setmetatable(
        {
            --[[
                the level state is loaded and inserted underneath the editor state.
                it is only drawn, not updated.
            --]]
            levelstate = levelstate.new(levelfile),
            updatebelow = false,
            drawbelow = true,
            --[[
                the current tool is an editor state. There can only be one active at a time.
                the editor defaults to the tilemap toolset.
            --]]
            toolset = tilemaptools.new(),
            background_color = {0.2, 0.2, 0.31, 1},
            grid = {
                show = true,
                cell_size = 32,
                color = {0, 0, 0, 0.09}
            },
            mouse_state = {
                x = 0,
                y = 0,
                prevx = 0,
                prevy = 0,
                scroll = 0
            },
            navigation = {
                pan_speed = 40,
                zoom_speed = 1,
                kpan_speed = 200,
                kzoom_speed = 0.8
            }
        },
        {__index = editstate}
    )
end

local function handleinput(self, dt)
    -- capture previous and current positions
    local ms = self.mouse_state
    ms.prevx, ms.prevy = ms.x, ms.y
    ms.x, ms.y = mouse.get_position()
    ms.scroll = mouse.get_scroll()

    -- CTRL+
    if keyboard.is_key_down(keys.LCTRL) then
        -- S: save map data and overwrite currently edited file
        if keyboard.is_key_released(keys.S) then
            _G.persistence.store(self.levelstate.file, self.levelstate.data)
        end

        -- G: toggle grid
        if keyboard.is_key_released(keys.G) then
            self.grid.show = not self.grid.show
        end
    else
        -- zoom
        if ms.scroll > 0 then
            self.levelstate.camera:zoom_in(self.navigation.zoom_speed * dt)
        elseif ms.scroll < 0 then
            self.levelstate.camera:zoom_out(self.navigation.zoom_speed * dt)
        end

        -- pan
        if mouse.is_button_down(mousebuttons.MIDDLE) then
            local pmsx, pmsy = ms.prevx, ms.prevy
            local pan_speed = self.navigation.pan_speed
            local new_cam_posx = (pmsx - ms.x) * pan_speed * dt
            local new_cam_posy = (pmsy - ms.y) * pan_speed * dt

            self.levelstate.camera:move(new_cam_posx, new_cam_posy)
        end

        -- pan with WASD
        if keyboard.is_key_down(keys.W) then
            self.levelstate.camera:move(0, -self.navigation.kpan_speed * dt)
        end
        if keyboard.is_key_down(keys.S) then
            self.levelstate.camera:move(0, self.navigation.kpan_speed * dt)
        end
        if keyboard.is_key_down(keys.A) then
            self.levelstate.camera:move(-self.navigation.kpan_speed * dt, 0)
        end
        if keyboard.is_key_down(keys.D) then
            self.levelstate.camera:move(self.navigation.kpan_speed * dt, 0)
        end

        -- zoom with arrows
        if keyboard.is_key_down(keys.E) then
            self.levelstate.camera:zoom_in(self.navigation.kzoom_speed * dt)
        end
        if keyboard.is_key_down(keys.Q) then
            self.levelstate.camera:zoom_out(self.navigation.kzoom_speed * dt)
        end
    end
end

local function drawgrid(self)
    if self.grid.show then
        -- we transform the initial draw point once to avoid performing this costly operation for every single cell.
        local x, y = self.levelstate.camera:transform_point(0, 0)
        local advancex, advancey = x, y
        local scaledcellsz = self.grid.cell_size * self.levelstate.camera.zoom
        local mapwidth = self.levelstate.data.tilemap.width
        local mapheight = self.levelstate.data.tilemap.height

        graphics.set_draw_color(unpack(self.grid.color))

        for _ = 1, mapheight do
            for _ = 1, mapwidth do
                graphics.draw_rect(advancex, advancey, scaledcellsz, scaledcellsz)
                advancex = advancex + scaledcellsz
            end
            advancex = x
            advancey = advancey + scaledcellsz
        end
    end
end

local function drawcommontools(self)
    local cam = self.levelstate.camera
    local resw, resh = graphics.get_resolution()

    -- bottom pannel
    local panelh = resh * 0.05
    gui:panel(0, resh - panelh, resw, panelh)

    -- draw fps
    gui:label(resw * 0.9, 5, format("FPS: %.0f", self.game.fps))

    -- mouse pos
    local msx, msy = cam:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(resw * 0.02, resh * 0.97, format("+ %.0f, %.0f", msx, msy))

    -- cam pos
    local cmx, cmy = cam.position[1], cam.position[2]
    gui:label(resw * 0.13, resh * 0.97, format("[ ] %.0f, %.0f", cmx, cmy))

    -- zoom
    graphics.set_draw_color(1, 1, 1, 1)
    gui:label(resw * 0.95, resh * 0.97, format("%.0f%%", cam:get_zoom_percentage()))
end

function editstate:enter(game)
    window.set_title("OMRS Editor")
    game.background_color = self.background_color
    self.game:insert(self.levelstate, 1)
    self.toolset:enter(self)
end

function editstate:update(dt)
    handleinput(self, dt)
    self.toolset:handle_input(self, dt)
    self.toolset:update(self, dt)

    -- we don't want to update the scene, but we still need to refresh the go lists.
    self.levelstate:refreshgolists()
end

function editstate:draw()
    drawgrid(self)
    drawcommontools(self)
    self.toolset:draw(self)
end

return {
    new = new
}
