local keyboard = require("milk.keyboard")
local mouse = require("milk.mouse")
local tiny = require("thirdparty.tiny")
local keys = keyboard.keys
local mousebuttons = mouse.buttons

local function new(editor)
    local input =
        tiny.system(
        {
            filter = function()
                return false
            end
        }
    )

    function input:update(dt)
        -- capture previous and current positions
        local ms = editor.mouse_state
        ms.prevx, ms.prevy = ms.x, ms.y
        ms.x, ms.y = mouse.get_position()

        -- zoom
        ms.scroll = mouse.get_scroll()

        -- only zoom if control is not being pressed.
        -- this allows for other controls to use control+ shortcuts without zooming.
        ms.scroll = mouse.get_scroll()
        if not keyboard.is_key_down(keys.LCTRL) then
            if ms.scroll > 0 then
                editor.camera:zoom_in(editor.navigation.zoom_speed * dt)
            elseif ms.scroll < 0 then
                editor.camera:zoom_out(editor.navigation.zoom_speed * dt)
            end
        end

        -- pan
        if mouse.is_button_down(mousebuttons.MIDDLE) then
            local pmsx, pmsy = ms.prevx, ms.prevy
            local pan_speed = editor.navigation.pan_speed
            local new_cam_posx = (pmsx - ms.x) * pan_speed * dt
            local new_cam_posy = (pmsy - ms.y) * pan_speed * dt
            editor.camera:move(new_cam_posx, new_cam_posy)
        end

        -- CTRL+
        if keyboard.is_key_down(keys.LCTRL) then
            -- G: toggle grid
            if keyboard.is_key_released(keys.G) then
                editor.grid.show = not editor.grid.show
            end
            -- O: toggle map onion layers
            if keyboard.is_key_released(keys.O) then
                editor.map.onion = not editor.map.onion
            end
            -- DOWN: add row to map
            if keyboard.is_key_released(keys.DOWN) then
                local tilemap = editor.level.tilemap
                tilemap.height = tilemap.height + 1

                for i = 1, #tilemap.layers do
                    tilemap.layers[i][tilemap.height] = {}

                    for j = 1, tilemap.width do
                        tilemap.layers[i][tilemap.height][j] = 0
                    end
                end
            end
            -- UP: remove row from map
            if keyboard.is_key_released(keys.UP) then
                local tilemap = editor.level.tilemap

                for i = 1, #tilemap.layers do
                    tilemap.layers[i][tilemap.height] = nil
                end
                tilemap.height = tilemap.height - 1
            end
            -- RIGHT: add column to map
            if keyboard.is_key_released(keys.RIGHT) then
                editor.level.tilemap.width = editor.level.tilemap.width + 1
                for i = 1, #editor.level.tilemap.layers do
                    for j = 1, #editor.level.tilemap.layers[i] do
                        editor.level.tilemap.layers[i][j][editor.level.tilemap.width] = 0
                    end
                end
            end
            -- LEFT: remove column from map
            if keyboard.is_key_released(keys.LEFT) then
                for i = 1, #editor.level.tilemap.layers do
                    for j = 1, #editor.level.tilemap.layers[i] do
                        editor.level.tilemap.layers[i][j][editor.level.tilemap.width] = nil
                    end
                end
                editor.level.tilemap.width = editor.level.tilemap.width - 1
            end
        end

        -- toggle layer
        if keyboard.is_key_released(keys.TAB) then
            local nextlayer = editor.map.selected_layer + 1
            if nextlayer > #editor.level.tilemap.layers then
                nextlayer = 1
            end
            editor.map.selected_layer = nextlayer
        end

        -- pan with WASD
        if keyboard.is_key_down(keys.W) then
            editor.camera:move(0, -editor.navigation.kpan_speed * dt)
        end
        if keyboard.is_key_down(keys.S) then
            editor.camera:move(0, editor.navigation.kpan_speed * dt)
        end
        if keyboard.is_key_down(keys.A) then
            editor.camera:move(-editor.navigation.kpan_speed * dt, 0)
        end
        if keyboard.is_key_down(keys.D) then
            editor.camera:move(editor.navigation.kpan_speed * dt, 0)
        end

        -- zoom with arrows
        if keyboard.is_key_down(keys.E) then
            editor.camera:zoom_in(editor.navigation.kzoom_speed * dt)
        end
        if keyboard.is_key_down(keys.Q) then
            editor.camera:zoom_out(editor.navigation.kzoom_speed * dt)
        end
    end

    return input
end

return new
