local window = require("milk.window")
local graphics = require("milk.graphics")
local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local levelstate = require("levelstate")
local gui = require("gui")
local mousebuttons = mouse.buttons
local keys = keyboard.keys

--=================================================
-- local functions
--=================================================
local unpack = table.unpack
local format = string.format

local editstate = {}

--=================================================
-- EDITOR STATE
--[[
    TODO:
    - command queue, undo and redo @matt ames
    - auto populate level data for empty files
    - show/hide gameobjects
--]]
--=================================================
local function new(levelfile)
    return setmetatable(
        {
            levelstate = levelstate.new(levelfile),
            updatebelow = false,
            drawbelow = true,
            background_color = {0.2, 0.2, 0.31, 1},
            grid = {
                show = true,
                cell_size = 32,
                color = {0, 0, 0, 0.09}
            },
            map = {
                default_width = 100,
                default_height = 100,
                selected_layer = 1,
                onion = false
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

    -- zoom
    ms.scroll = mouse.get_scroll()

    -- only zoom if control is not being pressed.
    -- this allows for other controls to use control+ shortcuts without zooming.
    ms.scroll = mouse.get_scroll()
    if not keyboard.is_key_down(keys.LCTRL) then
        if ms.scroll > 0 then
            self.levelstate.camera:zoom_in(self.navigation.zoom_speed * dt)
        elseif ms.scroll < 0 then
            self.levelstate.camera:zoom_out(self.navigation.zoom_speed * dt)
        end
    end

    -- pan
    if mouse.is_button_down(mousebuttons.MIDDLE) then
        local pmsx, pmsy = ms.prevx, ms.prevy
        local pan_speed = self.navigation.pan_speed
        local new_cam_posx = (pmsx - ms.x) * pan_speed * dt
        local new_cam_posy = (pmsy - ms.y) * pan_speed * dt

        self.levelstate.camera:move(new_cam_posx, new_cam_posy)
    end

    -- CTRL+
    if keyboard.is_key_down(keys.LCTRL) then
        -- G: toggle grid
        if keyboard.is_key_released(keys.G) then
            self.grid.show = not self.grid.show
        end
        -- O: toggle map onion layers
        if keyboard.is_key_released(keys.O) then
            self.map.onion = not self.map.onion
        end
        -- DOWN: add row to map
        if keyboard.is_key_released(keys.DOWN) then
            local tilemap = self.levelstate.data.tilemap
            tilemap.height = tilemap.height + 1

            for i = 1, #tilemap.layers do
                tilemap.layers[i].tiles[tilemap.height] = {}

                for j = 1, tilemap.width do
                    tilemap.layers[i].tiles[tilemap.height][j] = 0
                end
            end
        end
        -- UP: remove row from map
        if keyboard.is_key_released(keys.UP) then
            local tilemap = self.levelstate.data.tilemap

            for i = 1, #tilemap.layers do
                tilemap.layers[i].tiles[tilemap.height] = nil
            end
            tilemap.height = tilemap.height - 1
        end
        -- RIGHT: add column to map
        if keyboard.is_key_released(keys.RIGHT) then
            self.levelstate.data.tilemap.width = self.levelstate.data.tilemap.width + 1
            for i = 1, #self.levelstate.data.tilemap.layers do
                for j = 1, #self.levelstate.data.tilemap.layers[i].tiles do
                    self.levelstate.data.tilemap.layers[i].tiles[j][self.levelstate.data.tilemap.width] = 0
                end
            end
        end
        -- LEFT: remove column from map
        if keyboard.is_key_released(keys.LEFT) then
            for i = 1, #self.levelstate.data.tilemap.layers do
                for j = 1, #self.levelstate.data.tilemap.layers[i].tiles do
                    self.levelstate.data.tilemap.layers[i].tiles[j][self.levelstate.data.tilemap.width] = nil
                end
            end
            self.levelstate.data.tilemap.width = self.levelstate.data.tilemap.width - 1
        end
    end

    -- toggle layer
    if keyboard.is_key_released(keys.TAB) then
        local nextlayer = self.map.selected_layer + 1
        if nextlayer > #self.levelstate.data.tilemap.layers then
            nextlayer = 1
        end
        self.map.selected_layer = nextlayer
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
    gui:label(590, 5, format("FPS: %.0f", self.game.fps))

    -- mouse pos
    local msx, msy = cam:screen2world(self.mouse_state.x, self.mouse_state.y)
    gui:label(10, 350, format("+ %.0f, %.0f", msx, msy))

    -- cam pos
    local cmx, cmy = cam.position[1], cam.position[2]
    gui:label(80, 350, format("[ ] %.0f, %.0f", cmx, cmy))

    -- draw current layer num
    local selectedlayer = self.map.selected_layer
    local numlayers = #self.levelstate.data.tilemap.layers
    if self.map.onion then
        graphics.set_draw_color(1, 1, 0, 1)
    end
    gui:label(160, 350, format("// %d/%d", selectedlayer, numlayers))

    -- zoom
    graphics.set_draw_color(1, 1, 1, 1)
    gui:label(615, 350, format("%.0f%%", cam:get_zoom_percentage()))
end

function editstate:enter()
    window.set_title("OMRS Editor")

    self.game:insert(self.levelstate, 1)
end

function editstate:update(dt)
    handleinput(self, dt)

    -- we don't want to update the scene, but we still need to refresh the go lists.
    self.levelstate:refreshgolists()
end

function editstate:draw()
    drawgrid(self)
    drawcommontools(self)
end

return {
    new = new
}
