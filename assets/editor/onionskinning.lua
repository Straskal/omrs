local tiny = require("thirdparty.tiny")

local function new(editor)
    local render =
        tiny.system(
        {
            filter = function()
                return false
            end
        }
    )

    -- luacheck: push ignore self
    function render:update(_)
        local layers = editor.level.tilemap.layers
        local selectedlayer = editor.map.selected_layer

        for i = 1, #layers do
            local color = layers[i].color

            if editor.map.onion then
                if i < selectedlayer then
                    color[1], color[2], color[3], color[4] = 0.25, 0.25, 0.25, 1
                elseif i > selectedlayer then
                    color[1], color[2], color[3], color[4] = 0.4, 0.4, 0.4, 0.07
                else
                    color[1], color[2], color[3], color[4] = 1, 1, 1, 1
                end
            else
                color[1], color[2], color[3], color[4] = 1, 1, 1, 1
            end
        end
    end
    -- luacheck: pop

    return render
end

return new
