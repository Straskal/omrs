local tiny = require("thirdparty.tiny")
local graphics = require("milk.graphics")

local function new()
    local render = tiny.sortedProcessingSystem()
    render.filter = tiny.requireAll("image")

    -- luacheck: push ignore self
    function render:compare(e1, e2)
        local e1layer = e1.image.layer or 0
        local e2layer = e2.image.layer or 0
        return e1layer < e2layer
    end

    function render:onAdd(e, _)
        if not e.image.data then
            e.image.data = graphics.new_image(e.image.file)
        end
    end

    function render:process(e, _)
        local p = e.position
        local s = e.image.src
        graphics.drawx(e.image.data, p[1], p[2], s[1], s[2], s[3], s[4], 1, 1, 0)
    end
    -- luacheck: pop

    return render
end

return {
    new = new
}
